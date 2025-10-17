import 'dart:io';
import 'package:amity_uikit_beta_service/v4/social/story/view/components/story_video_player/bloc/story_video_player_bloc.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visibility_detector/visibility_detector.dart';

class AmityStoryVideoPlayer extends StatefulWidget {
  final VoidCallback onInitialize;
  final VoidCallback onInitializing;
  final VoidCallback onPause;
  final VoidCallback onPlay;
  final bool showVolumeControl;
  final void Function(bool isFinalDispose) onWidgetDispose;
  final File? video;
  final String? url;
  final bool showLoadingPlaceholder;
  final bool loopVideo;
  const AmityStoryVideoPlayer({
    super.key,
    required this.video,
    required this.onInitializing,
    required this.url,
    required this.onInitialize,
    required this.onPause,
    required this.onPlay,
    required this.onWidgetDispose,
    this.showVolumeControl = false,
    this.showLoadingPlaceholder = true,
    this.loopVideo = false,
  });

  @override
  State<AmityStoryVideoPlayer> createState() => _AmityStoryVideoPlayerState();
}

class _AmityStoryVideoPlayerState extends State<AmityStoryVideoPlayer> {
  late final StoryVideoPlayerBloc _videoBloc;

  @override
  void initState() {
    super.initState();
    widget.onInitializing();
    _videoBloc = context.read<StoryVideoPlayerBloc>();
    _videoBloc.add(InitializeStoryVideoPlayerEvent(file: widget.video, url: widget.url, looping: widget.loopVideo));
  }

  @override
  void didUpdateWidget(covariant AmityStoryVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    final didChangeVideo = widget.video?.path != oldWidget.video?.path;
    final didChangeUrl = widget.url != oldWidget.url;

    if (didChangeVideo || didChangeUrl) {
      widget.onInitializing();
      _videoBloc.add(InitializeStoryVideoPlayerEvent(file: widget.video, url: widget.url, looping: widget.loopVideo));
    }
  }

  @override
  void dispose() {
    widget.onWidgetDispose(true);
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
            if (!mounted) return;
            if (info.visibleFraction == 0.0) {
              widget.onWidgetDispose(false);
              _videoBloc.add(const PauseStoryVideoEvent());
            } else if (info.visibleFraction > 0.0) {
              _videoBloc.add(const PlayStoryVideoEvent());
            }
          },
          key: const Key('story_video_player'),
          child: Container(
            height: double.infinity,
            width: double.infinity,
            color: const Color.fromRGBO(0, 0, 0, 1),
            child: Center(
              child: _buildPlayerChild(state),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlayerChild(StoryVideoPlayerState state) {
    final hasController = state.videoController != null && state.chewieController != null;
    final isLoadingState = state is StoryVideoPlayerInitial || !hasController;

    if (isLoadingState && !widget.showLoadingPlaceholder) {
      return const SizedBox.shrink();
    }

    if (!hasController) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text('Loading', style: TextStyle(fontWeight: FontWeight.w500)),
          SizedBox(height: 20),
        ],
      );
    }

    return AspectRatio(
      aspectRatio: state.videoController!.value.aspectRatio,
      child: Chewie(
        controller: state.chewieController!,
      ),
    );
  }
}
