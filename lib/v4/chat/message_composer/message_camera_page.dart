import 'dart:io';

import 'package:amity_uikit_beta_service/components/custom_user_avatar.dart';
import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:video_player/video_player.dart';

class AmityMessageCameraScreen extends StatefulWidget {
  FileType? selectedFileType;
  String? avatarUrl;

  AmityMessageCameraScreen(
      {Key? key, required this.selectedFileType, required this.avatarUrl})
      : super(key: key);

  @override
  _AmityMessageCameraScreenState createState() =>
      _AmityMessageCameraScreenState(selectedFileType: selectedFileType);
}

class _AmityMessageCameraScreenState extends State<AmityMessageCameraScreen> {
  CameraController? controller;
  List<CameraDescription>? cameras;
  bool isVideoMode = false;
  bool isRecording = false;
  bool isFlashMode = false;
  String elapsedTime = "00:00:00";
  Duration duration = Duration();
  int selectedCameraIndex = 0;

  FileType? selectedFileType;
  AmityCameraResult? result;

  VideoPlayerController? _controller;
  Future<void>? _initializeVideoPlayerFuture;

  _AmityMessageCameraScreenState({
    Key? key,
    this.selectedFileType,
  }) {
    selectedFileType = selectedFileType;
    if (selectedFileType != null) {
      if (selectedFileType == FileType.image) {
        isVideoMode = false;
      } else {
        isVideoMode = true;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    cameras = await availableCameras();
    selectedCameraIndex = 0; // Start with the first camera
    controller = CameraController(
      cameras![selectedCameraIndex],
      ResolutionPreset.high,
    );
    await controller?.initialize();
    setState(() {});
  }

  Future<void> switchCamera() async {
    if (cameras != null && cameras!.isNotEmpty) {
      selectedCameraIndex = (selectedCameraIndex + 1) % 2;

      await controller?.dispose();
      controller = CameraController(
        cameras![selectedCameraIndex],
        ResolutionPreset.high,
      );
      await controller?.initialize();
      setState(() {});
    }
  }

  void initializeVideoPlayer(String filePath) {
    setState(() {
      _controller = VideoPlayerController.file(File(filePath));
      _initializeVideoPlayerFuture = _controller!.initialize();
      _controller!.setLooping(true);
      _controller!.play();
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return Container();
    }
    if (result != null) {
      return SafeArea(
        child: Scaffold(
          body: Stack(
            alignment: Alignment.topLeft,
            children: [
              Container(
                color: Colors.black,
                child: Column(
                  children: [
                    if (result!.type == FileType.image)
                      Expanded(
                        child: Image.file(
                          File(result!.file.path),
                          fit: BoxFit.cover,
                        ),
                      ),
                    if (result!.type == FileType.video && _controller == null)
                      Expanded(
                        child: Container(
                          color: Colors.black,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                    if (result!.type == FileType.video && _controller != null)
                      Expanded(
                        child: FutureBuilder(
                          future: _initializeVideoPlayerFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              return AspectRatio(
                                aspectRatio: _controller!.value.aspectRatio,
                                child: VideoPlayer(_controller!),
                              );
                            } else {
                              return Container();
                            }
                          },
                        ),
                      ),
                    _buildSendButton(widget.avatarUrl),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      result = null;
                      isRecording = false;
                      elapsedTime = "00:00:00";
                      duration = Duration();
                    });
                  },
                  child: SizedBox(
                    width: 32,
                    height: 32,
                    child: SvgPicture.asset(
                      'assets/Icons/amity_ic_circular_back_button.svg',
                      package: 'amity_uikit_beta_service',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return SafeArea(
        child: Scaffold(
          body: Container(
            color: Colors.black,
            child: Stack(
              children: [
                CameraPreview(controller!),
                _buildOverlayUI(),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _buildOverlayUI() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTopBar(),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(isFlashMode ? Icons.flash_on : Icons.flash_off,
                color: Colors.white),
            onPressed: () {
              controller?.setFlashMode(isFlashMode
                  ? FlashMode.off
                  : FlashMode.torch); // Toggle flash mode
              setState(() {
                isFlashMode = !isFlashMode;
              });
            },
          ),
          if (isVideoMode)
            Container(
              decoration: BoxDecoration(
                color: isRecording ? Colors.red : Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(5),
              ),
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: Text(
                elapsedTime,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    Color buttonColor;
    if (!isVideoMode) {
      buttonColor = Colors.white;
    } else {
      if (isRecording) {
        buttonColor = Colors.black;
      } else {
        buttonColor = Colors.red;
      }
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildModeSwitcher(),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  context.l10n.general_cancel,
                  style: TextStyle(color: Colors.white),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  if (isVideoMode) {
                    if (isRecording) {
                      XFile? video = await stopRecording();
                      if (video != null) {
                        AmityCameraResult cameraResult = AmityCameraResult(
                            file: video, type: FileType.video);
                        initializeVideoPlayer(cameraResult.file.path);
                        setState(() {
                          result = cameraResult;
                        });
                      }
                    } else {
                      startRecording();
                    }
                  } else {
                    try {
                      XFile? image = await controller?.takePicture();
                      if (image != null) {
                        AmityCameraResult cameraResult = AmityCameraResult(
                            file: image, type: FileType.image);
                        setState(() {
                          result = cameraResult;
                        });

                        // Navigator.of(context).pop(result);
                      }
                    } catch (e) {
                      // Handle any errors
                    }
                  }
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.black,
                          width: 3,
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: buttonColor,
                          border: Border.all(
                            color: Colors.black,
                            width: 2,
                          ),
                        ),
                        child: isVideoMode && isRecording
                            ? Container(
                                margin: const EdgeInsets.all(15),
                                width: 30,
                                height: 30,
                                color: Colors.red,
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 70,
                height: 70,
                child: IconButton(
                  icon: const Icon(
                    Icons.cached,
                    color: Colors.white, // Update icon color
                  ),
                  onPressed: () {
                    switchCamera(); // Call the switchCamera method
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeSwitcher() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (selectedFileType == FileType.video || selectedFileType == null)
          Padding(
            padding: EdgeInsets.only(right: selectedFileType == null ? 20 : 0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isVideoMode = true;
                });
              },
              child: Text(
                context.l10n.general_video.toUpperCase(),
                style: TextStyle(
                  color: isVideoMode ? Colors.yellow : Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        if (selectedFileType == FileType.image || selectedFileType == null)
          GestureDetector(
            onTap: () {
              setState(() {
                isVideoMode = false;
              });
            },
            child: Text(
              context.l10n.general_photo.toUpperCase(),
              style: TextStyle(
                color: !isVideoMode ? Colors.yellow : Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  void startRecording() async {
    if (controller != null && !isRecording) {
      try {
        await controller!.startVideoRecording();

        setState(() {
          isRecording = true;
        });
        // Start a timer to update the elapsed time
        updateElapsedTime();
      } catch (e) {
        // Handle any errors
      }
    }
  }

  Future<XFile?> stopRecording() async {
    if (controller != null && isRecording) {
      try {
        XFile videoFile = await controller!.stopVideoRecording();
        setState(() {
          isRecording = false;
        });
        return videoFile;
      } catch (e) {
        // Handle any errors
      }
    }
    return null;
  }

  void updateElapsedTime() {
    Future.delayed(const Duration(seconds: 1), () {
      if (isRecording) {
        duration = Duration(seconds: duration.inSeconds + 1);
        setState(() {
          elapsedTime = _formatDuration(duration);
        });
        updateElapsedTime();
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  Widget _buildSendButton(String? avatarUrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                  onTap: () async {
                    Navigator.of(context).pop(result);
                  },
                  child: Container(
                    // width: 97,
                    height: 40,
                    padding: const EdgeInsets.only(
                        top: 6, left: 4, right: 16, bottom: 6),
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              getAvatarImage(avatarUrl ?? "",
                                  radius: 16, fileId: null),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                context.l10n.message_send,
                                style: TextStyle(
                                  color: Color(0xFF292B32),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.24,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ],
      ),
    );
  }
}

class AmityCameraResult {
  XFile file;
  FileType type;

  AmityCameraResult({required this.file, required this.type});
}
