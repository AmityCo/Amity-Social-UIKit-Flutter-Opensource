import 'dart:io';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/components/custom_user_avatar.dart';
import 'package:animation_wrappers/animation_wrappers.dart';
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

class MyVideoPlayer2 extends StatefulWidget {
  final String url;
  final AmityPost post;
  final bool isInFeed;
  final bool isEnableVideoTools;
  const MyVideoPlayer2(
      {Key? key,
      required this.url,
      required this.isInFeed,
      required this.isEnableVideoTools,
      required this.post})
      : super(key: key);

  @override
  State<MyVideoPlayer2> createState() => _MyVideoPlayer2State();
}

class _MyVideoPlayer2State extends State<MyVideoPlayer2> {
  String? thumbnailURL;
  late VideoPlayerController videoPlayerController;
  ChewieController? chewieController;

  @override
  void initState() {
    var postData = widget.post.data as VideoData;
    if (postData.thumbnail != null) {
      thumbnailURL = postData.thumbnail!.fileUrl;
    }
    if (!widget.isInFeed) {
      initializePlayer();
    }
    super.initState();
  }

  @override
  void dispose() {
    if (!widget.isInFeed) {
      videoPlayerController.dispose();
    }
    if (!widget.isInFeed) {
      if (chewieController != null) {
        chewieController!.dispose();
      }
    }

    super.dispose();
  }

  Future<void> initializePlayer() async {
    var videoUrl = "";
    final videoData = widget.post.data as VideoData;

    await videoData.getVideo(AmityVideoQuality.HIGH).then((AmityVideo video) {
      if (mounted) {
        setState(() {
          videoUrl = video.fileUrl!;
        });
      }
    });

    videoPlayerController = VideoPlayerController.network(videoUrl);
    await videoPlayerController.initialize();

    var chewieProgressColors = ChewieProgressColors(
        // backgroundColor: Theme.of(context).primaryColor,
        // bufferedColor: Theme.of(context).primaryColor
        // ignore: use_build_context_synchronously
        handleColor: Theme.of(context).primaryColor,
        // ignore: use_build_context_synchronously
        playedColor: Theme.of(context).primaryColor);

    ChewieController controller = ChewieController(
      showControlsOnInitialize: false,
      materialProgressColors: chewieProgressColors,
      cupertinoProgressColors: chewieProgressColors,
      showControls: widget.isInFeed ? false : true,
      videoPlayerController: videoPlayerController,
      autoPlay: widget.isInFeed ? false : true,
      allowPlaybackSpeedChanging: false,
      deviceOrientationsAfterFullScreen: [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown
      ],
      looping: true,
    );

    if (widget.isInFeed) {
      controller.setVolume(0.0);
    } else {
      controller.setVolume(50);
    }

    setState(() {
      chewieController = controller;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FadeAnimation(
      child: Center(
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(widget.isInFeed ? 10 : 0),
              child: Container(
                height: 250,
                color: const Color.fromRGBO(0, 0, 0, 1),
                child: Center(
                    child: !widget.isInFeed
                        ? chewieController != null &&
                                chewieController!
                                    .videoPlayerController.value.isInitialized
                            ? GestureDetector(
                                onDoubleTap: (() {
                                  chewieController!.enterFullScreen();
                                }),
                                child: Chewie(
                                  controller: chewieController!,
                                ),
                              )
                            : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // CircularProgressIndicator(
                                  //   color: Theme.of(context).primaryColor,
                                  // )
                                ],
                              )
                        : Expanded(
                            child: Row(
                            children: [
                              Expanded(
                                child: Image(
                                  image: getImageProvider(thumbnailURL),
                                  fit: BoxFit.fitHeight,
                                ),
                              ),
                            ],
                          ))),
              ),
            ),
            widget.isInFeed
                ? CircleAvatar(
                    backgroundColor: Theme.of(context).highlightColor,
                    child: Icon(
                      Icons.play_arrow,
                      color: Theme.of(context).primaryColor,
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final List<AmityPost> files;

  const VideoPlayerScreen({Key? key, required this.files}) : super(key: key);

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
    _controllers = await Future.wait(
      widget.files.map((file) async {
        var videoData = file.data
            as VideoData; // Assuming VideoData is a type from your code
        var fileURL = await videoData.getVideo(AmityVideoQuality.MEDIUM);
        var controller =
            VideoPlayerController.networkUrl(Uri.parse(fileURL.fileUrl!));
        await controller.initialize();
        return controller;
      }),
    );
    setState(() {});
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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('${_currentIndex + 1}/${widget.files.length}'),
        leading: IconButton(
          icon: const Icon(Icons.close),
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
                              image:
                                  NetworkImage(videoData.thumbnail!.fileUrl!),
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
