import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AmityPostCameraScreen extends StatefulWidget {
  FileType? selectedFileType;

  AmityPostCameraScreen({Key? key, FileType? selectedType}) : super(key: key) {
    selectedFileType = selectedType;
  }

  @override
  _AmityPostCameraScreenState createState() =>
      _AmityPostCameraScreenState(selectedFileType: selectedFileType);
}

class _AmityPostCameraScreenState extends State<AmityPostCameraScreen> {
  CameraController? controller;
  List<CameraDescription>? cameras;
  bool isVideoMode = false;
  bool isRecording = false;
  bool isFlashMode = false;
  String elapsedTime = "00:00:00";
  Duration duration = Duration();
  int selectedCameraIndex = 0;

  FileType? selectedFileType;

  _AmityPostCameraScreenState({
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

    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Stack(
          children: [
            CameraPreview(controller!),
            _buildOverlayUI(),
          ],
        ),
      ),
    );
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
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  if (isVideoMode) {
                    if (isRecording) {
                      XFile? video = await stopRecording();

                      if (video != null) {
                        AmityCameraResult result = AmityCameraResult(
                            file: video, type: FileType.video);
                        Navigator.of(context).pop(result);
                      }
                    } else {
                      startRecording();
                    }
                  } else {
                    try {
                      XFile? image = await controller?.takePicture();
                      if (image != null) {
                        AmityCameraResult result = AmityCameraResult(
                            file: image, type: FileType.image);
                        Navigator.of(context).pop(result);
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
                'VIDEO',
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
              'PHOTO',
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
}

class AmityCameraResult {
  XFile file;
  FileType type;

  AmityCameraResult({required this.file, required this.type});
}
