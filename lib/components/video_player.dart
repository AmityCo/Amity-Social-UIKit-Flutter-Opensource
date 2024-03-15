import 'dart:io';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class LocalVideoPlayer extends StatefulWidget {
  final File file;
  const LocalVideoPlayer({Key? key, required this.file}) : super(key: key);

  @override
  State<LocalVideoPlayer> createState() => _LocalVideoPlayerState();
}

class _LocalVideoPlayerState extends State<LocalVideoPlayer> {
  late VideoPlayerController videoPlayerController;
  ChewieController? chewieController;

  @override
  void initState() {
    super.initState();
    initializePlayer();
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    chewieController?.dispose();
    super.dispose();
  }

  Future<void> initializePlayer() async {
    videoPlayerController = VideoPlayerController.file(widget.file);
    await videoPlayerController.initialize();
    ChewieController controller = ChewieController(
      showControlsOnInitialize: true,
      videoPlayerController: videoPlayerController,
      autoPlay: true,
      deviceOrientationsAfterFullScreen: [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown
      ],
      looping: true,
    );

    controller.setVolume(0.0);

    setState(() {
      chewieController = controller;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 250,
        color: const Color.fromRGBO(0, 0, 0, 1),
        child: Center(
          child: chewieController != null &&
                  chewieController!.videoPlayerController.value.isInitialized
              ? Chewie(
                  controller: chewieController!,
                )
              : const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text('Loading',
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    SizedBox(height: 20),
                  ],
                ),
        ),
      ),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final List<AmityPost> files;
  final bool isFillScreen;
  const VideoPlayerScreen(
      {Key? key, required this.files, this.isFillScreen = false})
      : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  List<VideoPlayerController>? _controllers; // Changed from late to nullable

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  Future<void> _initializeControllers() async {
    print("_initializeControllers");
    _controllers = await Future.wait(
      widget.files.map((file) async {
        var videoData = file.data
            as VideoData; // Assuming VideoData is a type from your code
        var fileURL = await videoData.getVideo(AmityVideoQuality.MEDIUM);
        print(fileURL.getFileProperties!.fileUrl);
        print("  ");
        var controller =
            VideoPlayerController.networkUrl(Uri.parse(fileURL.fileUrl!));
        await controller.initialize();
        return controller;
      }),
    );
    setState(() {
      print("success");
    });
  }

  @override
  void dispose() {
    _controllers?.forEach((controller) {
      controller.dispose();
    });
    _pageController.dispose();
    super.dispose();
  }

  void _openFullScreenVideo(VideoPlayerController controller) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) =>
          FullScreenVideoPlayerWidget(videoPlayerController: controller),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return widget.isFillScreen
        ? _controllers != null && _controllers!.isNotEmpty
            ? FullScreenVideoPlayerWidget(
                videoPlayerController: _controllers![0])
            : Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.black,
                  leading: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                backgroundColor: Colors.black,
                body: const Center(child: CircularProgressIndicator()))
        : Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              title: Text('${_currentIndex + 1}/${widget.files.length}'),
              leading: IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: _controllers != null && _controllers!.isNotEmpty
                ? PageView.builder(
                    controller: _pageController,
                    itemCount: widget.files.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      var controller = _controllers![index];
                      var videoData = widget.files[index].data as VideoData;
                      return GestureDetector(
                        onTap: () {
                          _openFullScreenVideo(controller);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(
                                        videoData.thumbnail!.fileUrl!),
                                    fit: BoxFit.fitWidth,
                                  ),
                                ),
                              ),
                              const Align(
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.play_arrow,
                                  size: 70.0,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : const Center(child: CircularProgressIndicator()),
          );
  }
}

class FullScreenVideoPlayerWidget extends StatefulWidget {
  final VideoPlayerController videoPlayerController;

  const FullScreenVideoPlayerWidget(
      {Key? key, required this.videoPlayerController})
      : super(key: key);

  @override
  _FullScreenVideoPlayerWidgetState createState() =>
      _FullScreenVideoPlayerWidgetState();
}

class _FullScreenVideoPlayerWidgetState
    extends State<FullScreenVideoPlayerWidget> {
  late ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    _chewieController = ChewieController(
      videoPlayerController: widget.videoPlayerController,
      aspectRatio: widget.videoPlayerController.value.aspectRatio,
      autoPlay: true,
      looping: true,
      // Additional Chewie configuration...
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
        maxChildSize: 1.0,
        minChildSize: 0.5,
        initialChildSize: 1.0,
        builder: (BuildContext context, ScrollController scrollController) {
          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              leading: IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: SafeArea(
              child: Chewie(
                controller: _chewieController,
              ),
            ),
          );
        });
  }

  @override
  void dispose() {
    _chewieController.dispose();
    widget.videoPlayerController.pause();

    super.dispose();
  }
}
