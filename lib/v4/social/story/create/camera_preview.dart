import 'dart:async';
import 'dart:io';
import 'package:amity_uikit_beta_service/amity_sle_uikit.dart';
import 'package:amity_uikit_beta_service/amity_uikit.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:image/image.dart' as img;

class CameraPreviewWidget extends StatefulWidget {
  final bool isVideoMode;
  final Function(File) onVideoCaptured;
  final Function(File, bool) onImageCaptured;
  final Function() onCloseClicked;

  const CameraPreviewWidget({
    super.key,
    required this.isVideoMode,
    required this.onVideoCaptured,
    required this.onImageCaptured,
    required this.onCloseClicked,
  });

  @override
  State<CameraPreviewWidget> createState() => _CameraPreviewWidgetState();
}

class _CameraPreviewWidgetState extends State<CameraPreviewWidget> with WidgetsBindingObserver, TickerProviderStateMixin {
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
  bool isRecording = false;
  double captureButtonSize = 60;
  double captureButtonSizeRingSize = 72;
  var isBackCamSelected = true;
  final int videoTimeInSeconds = 30;
  // Counting pointers (number of user fingers on screen)

  int _pointers = 0;
  bool isFlashOn = false;

  late Timer timer;
  var maxTimeInSeconds = 60;
  String pressDuration = "00:00";
  late DateTime lastButtonPress;
  late AnimationController animController;
  bool determinate = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    onNewCameraSelected(AmityUIKit.cameras.first);
    animController = AnimationController(
      /// [AnimationController]s can be created with `vsync: this` because of
      /// [TickerProviderStateMixin].
      vsync: this,
      duration: const Duration(seconds: 60),
    )..addListener(() {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        height: double.infinity,
        width: double.infinity,
        child: Stack(
          children: [
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: ClipRRect(
                borderRadius: const BorderRadius.all(
                  Radius.circular(20.0),
                ),
                child: _cameraPreviewWidget(constraints.maxHeight, constraints.maxWidth),
              ),
            ),
            Positioned(
              bottom: 48,
              right: 16,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    isBackCamSelected = !isBackCamSelected;
                    onNewCameraSelected(isBackCamSelected ? AmityUIKit.cameras.first : AmityUIKit.cameras.firstWhere((element) => element.lensDirection == CameraLensDirection.front));
                  });
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
                          turns: child.key == ValueKey("back_cam") ? Tween<double>(begin: 0.5, end: 1).animate(animation) : Tween<double>(begin: 1, end: 0.5).animate(animation),
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ))),
                      child: isBackCamSelected
                          ? SvgPicture.asset(
                              "assets/Icons/ic_camera_switch_white.svg",
                              package: 'amity_uikit_beta_service',
                              height: 30,
                              color: Colors.white,
                              key: const ValueKey(
                                "back_cam",
                              ),
                            )
                          : SvgPicture.asset(
                              "assets/Icons/ic_camera_switch_white.svg",
                              package: 'amity_uikit_beta_service',
                              height: 30,
                              color: Colors.white,
                              key: const ValueKey(
                                "front_cam",
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    isFlashOn = !isFlashOn;
                    setFlashMode(isFlashOn ? FlashMode.always : FlashMode.off);
                  });
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
                      child: isFlashOn
                          ? SvgPicture.asset(
                              "assets/Icons/ic_flash_on_white.svg",
                              package: 'amity_uikit_beta_service',
                              height: 15,
                              key: const ValueKey(
                                "flash_on",
                              ),
                            )
                          : SvgPicture.asset(
                              "assets/Icons/ic_flash_off_white.svg",
                              package: 'amity_uikit_beta_service',
                              height: 15,
                              key: const ValueKey(
                                "flash_off",
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    widget.onCloseClicked();
                  });
                },
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
            ),
            Positioned(
              bottom: 48,
              left: 16,
              child: GestureDetector(
                onTap: () async {
                  if (widget.isVideoMode) {
                    final video = await ImagePicker().pickVideo(source: ImageSource.gallery);
                    if (video != null) {
                      widget.onVideoCaptured(File(video.path));
                    }
                  } else {
                    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      widget.onImageCaptured(File(image.path), true);
                    }
                  }
                },
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
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 80,
                width: 80,
                child: Center(
                  child: GestureDetector(
                    onLongPress: () {
                      setState(() {
                        setState(() {
                          isRecording = true;
                          lastButtonPress = DateTime.now();
                          startVideoTimer();
                        });
                        if (widget.isVideoMode) {
                          captureButtonSizeRingSize = 80;
                          captureButtonSize = 64;
                        }
                        onVideoRecordButtonPressed();
                      });
                    },
                    onLongPressEnd: (details) {
                      setState(() {
                        if (widget.isVideoMode) {
                          captureButtonSizeRingSize = 72;
                          captureButtonSize = 60;
                        }
                        resetTime();
                        onVideoRecordButtonReleased();
                      });
                    },
                    onTap: () {
                      if (!widget.isVideoMode) {
                        onTakePictureButtonPressed();
                      }
                    },
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
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
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
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: widget.isVideoMode
                                      ? isRecording
                                          ? Colors.white
                                          : Colors.red
                                      : Colors.white,
                                ),
                                // child: isRecording
                                //     ? SizedBox(
                                //         width: 38,
                                //         height: 38,
                                //         child: Container(
                                //           width: 38,
                                //           height: 38,
                                //           decoration: BoxDecoration(
                                //             color: Colors.red,
                                //             borderRadius: BorderRadius.circular(
                                //               10,
                                //             ),
                                //           ),
                                //         ),
                                //       )
                                //     : Container(),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            widget.isVideoMode
                ? Positioned(
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
                            color: isRecording ? Colors.red : Colors.transparent,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: Text(
                              pressDuration,
                              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600, fontFamily: "'SF Pro Text'"),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
      );
    });
  }

  Widget _cameraPreviewWidget(double height, double width) {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return Container();
    } else {
      var camera = controller!.value;
      setFlashMode(isFlashOn ? FlashMode.always : FlashMode.off);
      
      var scale = (width / height) * camera.aspectRatio;
      
      if (scale < 1) scale = 1 / scale;

      return Listener(
        onPointerDown: (_) => _pointers++,
        onPointerUp: (_) => _pointers--,
        child: ClipRRect(
          borderRadius: const BorderRadius.all(
            Radius.circular(20.0),
          ),
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
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (controller == null) {
      return;
    }

    final CameraController cameraController = controller!;

    final Offset offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    cameraController.setExposurePoint(offset);
    cameraController.setFocusPoint(offset);
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _baseScale = _currentScale;
  }

  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    // When there are not exactly two fingers on screen don't scale
    if (controller == null || _pointers != 2) {
      return;
    }

    _currentScale = (_baseScale * details.scale).clamp(_minAvailableZoom, _maxAvailableZoom);

    await controller!.setZoomLevel(_currentScale);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller?.dispose();
    videoController?.dispose();
    animController.dispose();
    super.dispose();
  }

  // #docregion AppLifecycle
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCameraController(cameraController.description);
    }
  }

  Future<void> _initializeCameraController(CameraDescription cameraDescription) async {
    final CameraController cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.max,
      enableAudio: enableAudio,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    controller = cameraController;
    cameraController.lockCaptureOrientation(DeviceOrientation.portraitUp);
    controller!.lockCaptureOrientation(DeviceOrientation.portraitUp);
    // controller!.value = controller!.value.copyWith(previewSize: Size(300,600));

    // If the controller is updated then update the UI.
    cameraController.addListener(() {
      if (mounted) {
        setState(() {});
      }
      if (cameraController.value.hasError) {
        print('Camera error ${cameraController.value.errorDescription}');
      }
    });

    try {
      await cameraController.initialize();
      await Future.wait(<Future<Object?>>[
        cameraController.getMaxZoomLevel().then((double value) => _maxAvailableZoom = value),
        cameraController.getMinZoomLevel().then((double value) => _minAvailableZoom = value),
      ]);
    } on CameraException catch (e) {
      switch (e.code) {
        case 'CameraAccessDenied':
          print('You have denied camera access.');
          break;
        case 'CameraAccessDeniedWithoutPrompt':
          // iOS only
          print('Please go to Settings app to enable camera access.');
          break;
        case 'CameraAccessRestricted':
          // iOS only
          print('Camera access is restricted.');
          break;
        case 'AudioAccessDenied':
          print('You have denied audio access.');
          break;
        case 'AudioAccessDeniedWithoutPrompt':
          // iOS only
          print('Please go to Settings app to enable audio access.');
          break;
        case 'AudioAccessRestricted':
          // iOS only
          print('Audio access is restricted.');
          break;
        default:
          // _showCameraException(e);
          break;
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  /* DO  NOT REMOVE THIS BLOCK */
  void onTakePictureButtonPressed() {
    takePicture().then((XFile? file) async {
      if (mounted) {
        setState(() {
          imageFile = file;
          videoController?.dispose();
          videoController = null;
        });
        if (file != null) {
          widget.onImageCaptured(File(file.path), false);
        }
      }
    });
  }

  /* DO  NOT REMOVE ABOVE BLOCK */

  Future<void> onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      return controller!.setDescription(cameraDescription);
    } else {
      return _initializeCameraController(cameraDescription);
    }
  }

  /* DO  NOT REMOVE THIS BLOCK */

  Future<void> startVideoRecording() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      print('Error: select a camera first.');
      return;
    }

    setFlashMode(isFlashOn ? FlashMode.torch : FlashMode.off);
    

    if (cameraController.value.isRecordingVideo) {
      // A recording is already started, do nothing.
      return;
    }

    try {
      await cameraController.startVideoRecording();
      setState(() {
        isRecording = true;
      });
    } on CameraException catch (e) {
      // _showCameraException(e);
      return;
    }
  }
  /* DO  NOT REMOVE ABOVE BLOCK */

  /* DO  NOT REMOVE THIS BLOCK */

  Future<XFile?> stopVideoRecording() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return null;
    }
    setFlashMode( FlashMode.off);

    try {
      setState(() {
        isRecording = false;
      });
      return cameraController.stopVideoRecording();
    } on CameraException catch (e) {
      // _showCameraException(e);
      return null;
    }
  }

  /* DO  NOT REMOVE ABOVE BLOCK */

  Future<void> setFlashMode(FlashMode mode) async {
    if (controller == null) {
      return;
    }

    try {
      await controller!.setFlashMode(mode);
    } on CameraException catch (e) {
      // _showCameraException(e);
      rethrow;
    }
  }

  Future<void> setFocusMode(FocusMode mode) async {
    if (controller == null) {
      return;
    }

    try {
      await controller!.setFocusMode(mode);
    } on CameraException catch (e) {
      // _showCameraException(e);
      rethrow;
    }
  }

  Future<void> _startVideoPlayer() async {
    if (videoFile == null) {
      return;
    }

    final VideoPlayerController vController = kIsWeb ? VideoPlayerController.networkUrl(Uri.parse(videoFile!.path)) : VideoPlayerController.file(File(videoFile!.path));

    videoPlayerListener = () {
      if (videoController != null) {
        // Refreshing the state to update video player with the correct ratio.
        if (mounted) {
          setState(() {});
        }
        videoController!.removeListener(videoPlayerListener!);
      }
    };
    vController.addListener(videoPlayerListener!);
    await vController.setLooping(true);
    await vController.initialize();
    await videoController?.dispose();
    if (mounted) {
      setState(() {
        imageFile = null;
        videoController = vController;
      });
    }
    await vController.play();
  }

  /* DO  NOT REMOVE THIS BLOCK */
  Future<XFile?> takePicture() async {
    final CameraController? cameraController = controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      print('Error: select a camera first.');
      return null;
    }

    if (cameraController.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      final XFile file = await cameraController.takePicture();
      return file;
    } on CameraException catch (e) {
      // _showCameraException(e);
      return null;
    }
  }
  /* DO  NOT REMOVE ABOVE BLOCK */

  void startVideoTimer() {
    animController.forward(from: 0.0);
    timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) {
        _updateTimer();
        if (timer.tick == maxTimeInSeconds) {
          timer.cancel();
        }
      },
    );
  }

  void onVideoRecordButtonPressed() {
    startVideoRecording().then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void onVideoRecordButtonReleased() {
    stopVideoRecording().then((XFile? file) {
      if (mounted) {
        setState(() {});
      }
      if (file != null) {
        widget.onVideoCaptured(File(file.path));
        print('Video recorded to ${file.path}');
        videoFile = file;
        _startVideoPlayer();
      }
    });
  }

  void resetTime() {
    pressDuration = "00:00";
    animController.stop();
    timer.cancel();
  }

  void _updateTimer() {
    final duration = DateTime.now().difference(lastButtonPress);
    final newDuration = _formatDuration(duration);
    setState(() {
      pressDuration = newDuration;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    // return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}
