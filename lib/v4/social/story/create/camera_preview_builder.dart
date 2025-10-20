import 'dart:async';
import 'dart:io';
import 'package:amity_uikit_beta_service/amity_uikit.dart';
import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/social/story/create/bloc/camera_permission_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/story/create/bloc/camera_permission_event.dart';
import 'package:amity_uikit_beta_service/v4/social/story/create/bloc/camera_permission_state.dart';
import 'package:amity_uikit_beta_service/v4/social/story/draft/amity_story_media_type.dart';
import 'package:amity_uikit_beta_service/v4/utils/amity_dialog.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

/// Camera preview widget with full Bloc integration
/// Manages camera controller lifecycle and UI rendering based on Bloc state
class CameraPreviewBuilder extends StatefulWidget {
  final bool isVideoMode;
  final Function(File, StoryVideoMetadata) onVideoCaptured;
  final Function(File, bool) onImageCaptured;
  final Function() onCloseClicked;
  final AmityThemeColor? themeColor;

  const CameraPreviewBuilder({
    super.key,
    required this.isVideoMode,
    required this.onVideoCaptured,
    required this.onImageCaptured,
    required this.onCloseClicked,
    this.themeColor,
  });

  @override
  State<CameraPreviewBuilder> createState() => _CameraPreviewBuilderState();
}

class _CameraPreviewBuilderState extends State<CameraPreviewBuilder> 
    with WidgetsBindingObserver, TickerProviderStateMixin {
  // Camera controller - owned by widget but lifecycle controlled by Bloc
  CameraController? controller;
  XFile? imageFile;
  XFile? videoFile;
  VideoPlayerController? videoController;
  VoidCallback? videoPlayerListener;
  bool enableAudio = true;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _currentScale = 1.0;
  double _baseScale = 1.0;
  double captureButtonSize = 60;
  double captureButtonSizeRingSize = 72;
  final int videoTimeInSeconds = 30;
  int _pointers = 0;
  bool isRecording = false;
  bool _isInitializingCamera = false;
  
  Timer? timer;
  var maxTimeInSeconds = 15;
  String pressDuration = "00:00";
  late DateTime lastButtonPress;
  late AnimationController animController;
  bool determinate = false;
  CameraDescription? _currentCameraDescription;
  bool _galleryInProgress = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Initialize camera via Bloc
    context.read<CameraPermissionBloc>().add(
      InitializeCameraRequested(isVideoMode: widget.isVideoMode)
    );
    
    animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller?.dispose();
    videoController?.dispose();
    animController.dispose();
    timer?.cancel();
    super.dispose();
  }

  Future<void> _showCameraPermissionDialog(BuildContext context) async {
    await PermissionAlertV4Dialog().show(
      context: context,
      title: context.l10n.permission_camera_title,
      detailText: context.l10n.permission_camera_detail,
      bottomButtonText: context.l10n.general_cancel,
      topButtonText: context.l10n.permission_open_settings,
      onTopButtonAction: () {
        openAppSettings();
      },
    );
  }

  Future<void> _showMicrophonePermissionDialog(BuildContext context) async {
    await PermissionAlertV4Dialog().show(
      context: context,
      title: context.l10n.permission_microphone_title,
      detailText: context.l10n.permission_microphone_detail,
      bottomButtonText: context.l10n.general_cancel,
      topButtonText: context.l10n.permission_open_settings,
      onTopButtonAction: () {
        openAppSettings();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CameraPermissionBloc, CameraPermissionState>(
      listener: (context, state) {
        // Handle permission errors detected during camera controller initialization
        // These are caught by CameraException handler in _initializeCameraController
        
        // Initialize camera controller when Bloc is ready (assumes granted by default)
        if (state.cameraPermission == CameraPermissionStatus.granted &&
            state.initState == CameraInitializationStatus.notInitialized &&
            AmityUIKit.cameras.isNotEmpty) {
          _initializeCameraController(AmityUIKit.cameras.first);
        }
      },
      child: BlocBuilder<CameraPermissionBloc, CameraPermissionState>(
        builder: (context, state) {
          return LayoutBuilder(builder: (context, constraints) {
            return Container(
              height: double.infinity,
              width: double.infinity,
              child: Stack(
                children: [
                  // Camera preview
                  SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                      child: _buildCameraPreview(context, state, constraints.maxHeight, constraints.maxWidth),
                    ),
                  ),
                  // Camera flip button
                  _buildFlipCameraButton(context, state),
                  // Flash toggle button  
                  _buildFlashButton(context, state),
                  // Gallery button
                  _buildGalleryButton(context),
                  // Timer (video mode only)
                  _buildTimer(context, state),
                  // Top bar with close button
                  _buildTopBar(context),
                  // Bottom capture controls
                  _buildCaptureControls(context, state),
                ],
              ),
            );
          });
        },
      ),
    );
  }

  // Initialize camera controller and notify Bloc
  Future<void> _initializeCameraController(CameraDescription cameraDescription) async {
    // Prevent concurrent initialization
    if (_isInitializingCamera) {
      return;
    }
    
    _isInitializingCamera = true;
    _currentCameraDescription = cameraDescription;
    
    final previousController = controller;
    
    // Clear controller immediately to prevent rendering disposed controller
    if (mounted) {
      setState(() {
        controller = null;
      });
    }
    
    final CameraController cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      enableAudio: enableAudio,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await previousController?.dispose();

    try {
      await cameraController.initialize();
      
      // Lock orientation to portrait to ensure consistent video recording
      await cameraController.lockCaptureOrientation(DeviceOrientation.portraitUp);
      
      await cameraController.setFlashMode(FlashMode.off);
      _minAvailableZoom = await cameraController.getMinZoomLevel();
      _maxAvailableZoom = await cameraController.getMaxZoomLevel();

      if (mounted) {
        setState(() {
          controller = cameraController;
          _isInitializingCamera = false;
        });
        
        // Notify Bloc of successful initialization
        context.read<CameraPermissionBloc>().add(
          const CameraControllerInitialized(success: true)
        );
      } else {
        _isInitializingCamera = false;
      }
    } on CameraException catch (e) {
      
      // Handle permission errors
      if (mounted) {
        // Check if it's a microphone permission error
        if (e.code == 'AudioAccessDeniedWithoutPrompt' || 
            e.code == 'AudioAccessRestricted' ||
            e.code == 'AudioAccessDenied') {
          // Report to Bloc
          context.read<CameraPermissionBloc>().add(
            PermissionErrorDetected(isCameraError: false, errorCode: e.code)
          );
          
          // Show dialog
          await _showMicrophonePermissionDialog(context);
        } 
        // Check if it's a camera permission error
        else if (e.code == 'CameraAccessDeniedWithoutPrompt' || 
                 e.code == 'CameraAccessRestricted' ||
                 e.code == 'CameraAccessDenied') {
          // Report to Bloc
          context.read<CameraPermissionBloc>().add(
            PermissionErrorDetected(isCameraError: true, errorCode: e.code)
          );
          
          // Show dialog
          await _showCameraPermissionDialog(context);
        }
        
        _isInitializingCamera = false;
      }
      
      context.read<CameraPermissionBloc>().add(
        const CameraControllerInitialized(success: false)
      );
    } catch (e) {
      _isInitializingCamera = false;
      context.read<CameraPermissionBloc>().add(
        const CameraControllerInitialized(success: false)
      );
    }
  }

  Widget _buildCameraPreview(BuildContext context, CameraPermissionState state, double height, double width) {
    final CameraController? cameraController = controller;

    // Show empty container while loading or if controller is disposed
    if (cameraController == null || 
        !cameraController.value.isInitialized ||
        cameraController.value.isPreviewPaused) {
      return Container();
    }

    // Calculate scale to fill screen (matching old implementation)
    var camera = controller!.value;
    var scale = (width / height) * camera.aspectRatio;
    if (scale < 1) scale = 1 / scale;

    // Show camera preview with Transform.scale
    return Listener(
      onPointerDown: (_) => _pointers++,
      onPointerUp: (_) => _pointers--,
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(20.0)),
        child: Transform.scale(
          scale: scale,
          child: Center(
            child: CameraPreview(
              controller!,
              child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onScaleStart: _handleScaleStart,
                  onScaleUpdate: _handleScaleUpdate,
                  onTapDown: (TapDownDetails details) => onViewFinderTap(details, constraints),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFlipCameraButton(BuildContext context, CameraPermissionState state) {
    return Positioned(
      bottom: 48,
      right: 16,
      child: GestureDetector(
        onTap: () {
          if (!state.canCapture || AmityUIKit.cameras.length < 2) {
            return;
          }
          
          // Dispatch flip event to Bloc
          context.read<CameraPermissionBloc>().add(const CameraFlipped());
          
          // Select new camera
          final isBackCamera = !state.isBackCamera;
          final camera = isBackCamera
              ? AmityUIKit.cameras.first
              : AmityUIKit.cameras.firstWhere(
                  (element) => element.lensDirection == CameraLensDirection.front,
                  orElse: () => AmityUIKit.cameras.first,
                );
          
          _initializeCameraController(camera);
        },
        child: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              transitionBuilder: ((child, animation) => RotationTransition(
                turns: child.key == ValueKey("back_cam") 
                    ? Tween<double>(begin: 0.5, end: 1).animate(animation) 
                    : Tween<double>(begin: 1, end: 0.5).animate(animation),
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              )),
              child: state.isBackCamera
                  ? SvgPicture.asset(
                      "assets/Icons/ic_camera_switch_white.svg",
                      package: 'amity_uikit_beta_service',
                      height: 30,
                      color: Colors.white,
                      key: const ValueKey("back_cam"),
                    )
                  : SvgPicture.asset(
                      "assets/Icons/ic_camera_switch_white.svg",
                      package: 'amity_uikit_beta_service',
                      height: 30,
                      color: Colors.white,
                      key: const ValueKey("front_cam"),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFlashButton(BuildContext context, CameraPermissionState state) {
    if (!state.isBackCamera) return const SizedBox.shrink();
    
    return Positioned(
      top: 16,
      right: 16,
      child: GestureDetector(
        onTap: () {
          if (!state.canCapture) {
            return;
          }
          
          // Dispatch flash toggle event
          context.read<CameraPermissionBloc>().add(const FlashToggled());
          
          // Update controller flash mode
          if (controller != null) {
            controller!.setFlashMode(state.isFlashOn ? FlashMode.off : FlashMode.always);
          }
        },
        child: Container(
          height: 32,
          width: 32,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              transitionBuilder: ((child, animation) => FadeTransition(
                    opacity: animation,
                    child: child,
                  )),
              child: state.isFlashOn
                  ? SvgPicture.asset(
                      "assets/Icons/ic_flash_on_white.svg",
                      package: 'amity_uikit_beta_service',
                      height: 15,
                      key: const ValueKey("flash_on"),
                    )
                  : SvgPicture.asset(
                      "assets/Icons/ic_flash_off_white.svg",
                      package: 'amity_uikit_beta_service',
                      height: 15,
                      key: const ValueKey("flash_off"),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimer(BuildContext context, CameraPermissionState state) {
    if (!widget.isVideoMode) return const SizedBox.shrink();
    
    return Positioned(
      top: 20,
      left: 0,
      right: 0,
      child: Center(
        child: SizedBox(
          height: 20,
          width: 60,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            decoration: BoxDecoration(
              color: isRecording 
                  ? (widget.themeColor?.alertColor ?? Colors.red) 
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                pressDuration,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  fontFamily: "'SF Pro Text'",
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Positioned(
      top: 16,
      left: 16,
      child: GestureDetector(
        onTap: widget.onCloseClicked,
        child: Container(
          height: 32,
          width: 32,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: SvgPicture.asset(
              "assets/Icons/ic_close_white.svg",
              package: 'amity_uikit_beta_service',
              height: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCaptureControls(BuildContext context, CameraPermissionState state) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.only(bottom: 32),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCaptureButton(context, state),
          ],
        ),
      ),
    );
  }

  Widget _buildCaptureButton(BuildContext context, CameraPermissionState state) {
    if (widget.isVideoMode) {
      return GestureDetector(
        onLongPressStart: (_) => _onVideoRecordStart(context, state),
        onLongPressEnd: (_) => _onVideoRecordEnd(context, state),
        child: SizedBox(
          height: 80,
          width: 80,
          child: Center(
            child: AnimatedContainer(
              curve: Curves.easeIn,
              duration: const Duration(milliseconds: 300),
              height: captureButtonSizeRingSize,
              width: captureButtonSizeRingSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isRecording ? Colors.transparent : Colors.white,
                  width: 4,
                ),
              ),
              child: Center(
                child: isRecording
                    ? SizedBox(
                        width: captureButtonSizeRingSize,
                        height: captureButtonSizeRingSize,
                        child: Stack(
                          children: [
                            Center(
                              child: Container(
                                width: captureButtonSize,
                                height: captureButtonSize,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            Center(
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: captureButtonSizeRingSize,
                              width: captureButtonSizeRingSize,
                              child: CircularProgressIndicator(
                                color: Colors.red,
                                value: animController.value,
                                semanticsLabel: 'Circular progress indicator',
                              ),
                            ),
                          ],
                        ),
                      )
                    : AnimatedContainer(
                        curve: Curves.easeIn,
                        duration: const Duration(milliseconds: 300),
                        height: captureButtonSize,
                        width: captureButtonSize,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                      ),
              ),
            ),
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: () => _onTakePicture(context, state),
        child: Container(
          height: captureButtonSizeRingSize,
          width: captureButtonSizeRingSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
          ),
          child: Center(
            child: Container(
              height: captureButtonSize,
              width: captureButtonSize,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget _buildGalleryButton(BuildContext context) {
    return Positioned(
      bottom: 48,
      left: 16,
      child: GestureDetector(
        onTap: _onGalleryButtonPressed,
        child: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: SvgPicture.asset(
              "assets/Icons/ic_gallery_white.svg",
              package: 'amity_uikit_beta_service',
              height: 30,
              width: 30,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // Action handlers
  void _onTakePicture(BuildContext context, CameraPermissionState state) async {
    if (!state.canCapture) {
      return;
    }

    try {
      final image = await controller!.takePicture();
      if (mounted) {
        widget.onImageCaptured(File(image.path), state.isBackCamera);
      }
    } catch (e) {
      // Handle error silently
    }
  }

  void _onVideoRecordStart(BuildContext context, CameraPermissionState state) async {
    if (!state.canCaptureVideo) {
      return;
    }

    // Animate button size and set recording state immediately for UI
    setState(() {
      isRecording = true;
      captureButtonSizeRingSize = 80;
      captureButtonSize = 64;
    });

    // Set flash mode for video recording
    if (controller != null && state.isFlashOn) {
      await controller!.setFlashMode(FlashMode.torch);
    }

    // Dispatch recording started event
    context.read<CameraPermissionBloc>().add(const RecordingStarted());

    try {
      await controller!.startVideoRecording();
      _startTimer();
    } catch (e) {
      setState(() {
        isRecording = false;
        captureButtonSizeRingSize = 72;
        captureButtonSize = 60;
      });
      if (controller != null) {
        await controller!.setFlashMode(FlashMode.off);
      }
      context.read<CameraPermissionBloc>().add(const RecordingStopped());
    }
  }

  void _onVideoRecordEnd(BuildContext context, CameraPermissionState state) async {
    if (!isRecording) {
      return;
    }

    // Reset button size and recording state immediately for UI
    setState(() {
      isRecording = false;
      captureButtonSizeRingSize = 72;
      captureButtonSize = 60;
    });

    // Turn off flash after recording
    if (controller != null) {
      await controller!.setFlashMode(FlashMode.off);
    }

    // Dispatch recording stopped event
    context.read<CameraPermissionBloc>().add(const RecordingStopped());

    try {
      final video = await controller!.stopVideoRecording();
      _stopTimer();
      if (mounted) {
        final metadata = StoryVideoMetadata(isBackCamera: state.isBackCamera);
        widget.onVideoCaptured(File(video.path), metadata);
      }
    } catch (e) {
      // Handle error silently
    }
  }

  void _onGalleryButtonPressed() async {
    if (_galleryInProgress) return;
    
    _galleryInProgress = true;
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null && mounted) {
        widget.onImageCaptured(File(image.path), true);
      }
    } finally {
      _galleryInProgress = false;
    }
  }

  // Timer management
  void _startTimer() {
    timer?.cancel();
    pressDuration = "00:00";
    var startTime = DateTime.now();
    
    // Start animation controller for circular progress
    animController.forward(from: 0.0);
    
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          final elapsed = DateTime.now().difference(startTime);
          pressDuration = "${elapsed.inMinutes.toString().padLeft(2, '0')}:${(elapsed.inSeconds % 60).toString().padLeft(2, '0')}";
          
          if (timer.tick >= maxTimeInSeconds) {
            timer.cancel();
            _onVideoRecordEnd(context, context.read<CameraPermissionBloc>().state);
          }
        });
      }
    });
  }

  void _stopTimer() {
    timer?.cancel();
    timer = null;
    
    // Stop animation controller
    animController.stop();
    
    if (mounted) {
      setState(() {
        pressDuration = "00:00";
      });
    }
  }

  // Camera controls
  void _handleScaleStart(ScaleStartDetails details) {
    _baseScale = _currentScale;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) async {
    if (controller == null || _pointers != 2) {
      return;
    }

    _currentScale = (_baseScale * details.scale).clamp(_minAvailableZoom, _maxAvailableZoom);

    await controller!.setZoomLevel(_currentScale);
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (controller == null) {
      return;
    }

    final CameraController cameraController = controller!;

    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    cameraController.setExposurePoint(offset);
    cameraController.setFocusPoint(offset);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCameraController(_currentCameraDescription ?? AmityUIKit.cameras.first);
    }
  }
}
