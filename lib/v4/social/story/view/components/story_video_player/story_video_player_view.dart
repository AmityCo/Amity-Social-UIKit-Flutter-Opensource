import 'dart:io';
import 'package:amity_uikit_beta_service/v4/social/story/view/components/story_video_player/bloc/story_video_player_bloc.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:visibility_detector/visibility_detector.dart';

class AmityStoryVideoPlayer extends StatefulWidget {
  Function onInitialize;
  Function onInitializing;
  Function onPause;
  Function onPlay;
  bool? showVolumeControl;
  Function onWidgetDispose;
  final File? video;
  final String? url;
  AmityStoryVideoPlayer({super.key, required this.video, required this.onInitializing, required this.url, required this.onInitialize, required this.onPause, required this.onPlay, required this.onWidgetDispose, this.showVolumeControl = false});

  @override
  State<AmityStoryVideoPlayer> createState() => _AmityStoryVideoPlayerState();
}

class _AmityStoryVideoPlayerState extends State<AmityStoryVideoPlayer> {
  @override
  void initState() {
    widget.onInitializing();
    BlocProvider.of<StoryVideoPlayerBloc>(context).add(InitializeStoryVideoPlayerEvent(file: widget.video, url: widget.url));
    super.initState();
  }

  @override
  void dispose() {
    print("ShouldPauseStateVideo - > Dispose");
    // BlocProvider.of<StoryVideoPlayerBloc>(context).add(const DisposeStoryVideoPlayerEvent());
    widget.onWidgetDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StoryVideoPlayerBloc, StoryVideoPlayerState>(
      listener: (context, state) {
        if (state is StoryVideoPlayerInitialized) {
          widget.onInitialize();
        }
        if (state is StoryVideoPlayerPlaying) {
          widget.onPlay();
        }
        if (state is StoryVideoPlayerPaused) {
          widget.onPause();
        }
      },
      builder: (context, state) {
        return VisibilityDetector(
          onVisibilityChanged: (VisibilityInfo info) {
            print("ShouldPauseStateVideo visibility --------->: ${info.visibleFraction}");
            if (info.visibleFraction == 0.0) {
              widget.onWidgetDispose();
              BlocProvider.of<StoryVideoPlayerBloc>(context).add(const DisposeStoryVideoPlayerEvent());
              print("ShouldPauseStateVideo visibility --------->: PauseStoryVideoEvent");
            } else {
              BlocProvider.of<StoryVideoPlayerBloc>(context).add(const PlayStoryVideoEvent());
            }
          },
          key: const Key('story_video_player'),
          child: Container(
            height: double.infinity,
            width: double.infinity,
            color: const Color.fromRGBO(0, 0, 0, 1),
            child: Center(
              child: state is StoryVideoPlayerInitial
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 20),
                        Text('Loading', style: TextStyle(fontWeight: FontWeight.w500)),
                        SizedBox(height: 20),
                      ],
                    )
                  : state.videoController != null
                      ? AspectRatio(
                          aspectRatio: state.videoController!.value.aspectRatio,
                          child: Chewie(
                            controller: state.chewieController!,

                          ),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 20),
                            Text('Loading', style: TextStyle(fontWeight: FontWeight.w500)),
                            SizedBox(height: 20),
                          ],
                        ),
            ),
          ),
        );
      },
    );
  }
}
