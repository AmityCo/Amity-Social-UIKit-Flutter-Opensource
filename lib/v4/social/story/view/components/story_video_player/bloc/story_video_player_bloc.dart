import 'dart:io';

import 'package:amity_uikit_beta_service/v4/social/story/draft/amity_story_media_type.dart';
import 'package:chewie/chewie.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

part 'story_video_player_event.dart';
part 'story_video_player_state.dart';

class StoryVideoPlayerBloc extends Bloc<StoryVideoPlayerEvent, StoryVideoPlayerState> {
  StoryVideoPlayerBloc() : super(const StoryVideoPlayerInitial(videoController: null, chewieController: null, duration: 0)) {
  on<InitializeStoryVideoPlayerEvent>(_onInitialize);
    on<PlayStoryVideoEvent>(_onPlay);
    on<PauseStoryVideoEvent>(_onPause);
    on<VolumeChangedEvent>(_onVolumeChanged);
    on<DisposeStoryVideoPlayerEvent>(_onDispose);
  }

  Future<void> _onInitialize(InitializeStoryVideoPlayerEvent event, Emitter<StoryVideoPlayerState> emit) async {
  final previousVideoController = state.videoController;
  final previousChewieController = state.chewieController;

    emit(StoryVideoPlayerInitial(
      videoController: null,
      chewieController: null,
      duration: 0,
      metadata: event.metadata,
      rotationDegrees: 0,
    ));
    await _disposeControllers(previousVideoController, previousChewieController);

    VideoPlayerController? videoController;
    try {
      if (event.file != null) {
        videoController = VideoPlayerController.file(event.file!);
      } else if (event.url != null) {
        videoController = VideoPlayerController.networkUrl(Uri.parse(event.url!));
      }

      if (videoController == null) {
        emit(StoryVideoPlayerDisposed(
          videoController: null,
          chewieController: null,
          duration: 0,
          metadata: event.metadata,
          rotationDegrees: 0,
        ));
        return;
      }

      await videoController.initialize();
    } catch (_) {
      await _disposeControllers(videoController, null);
      emit(StoryVideoPlayerDisposed(
        videoController: null,
        chewieController: null,
        duration: 0,
        metadata: event.metadata,
        rotationDegrees: 0,
      ));
      return;
    }

    final rotationDegrees = videoController.value.rotationCorrection;
    final aspectRatio = _resolveAspectRatio(videoController, rotationDegrees);

    final chewieController = ChewieController(
      showControlsOnInitialize: false,
      videoPlayerController: videoController,
      autoPlay: true,
      showControls: false,
      autoInitialize: true,
      allowFullScreen: true,
      looping: event.looping,
      aspectRatio: aspectRatio,
    );

    emit(StoryVideoPlayerInitialized(
      videoController: videoController,
      chewieController: chewieController,
      duration: videoController.value.duration.inSeconds,
      metadata: event.metadata,
      rotationDegrees: rotationDegrees,
    ));
  }

  void _onPlay(PlayStoryVideoEvent event, Emitter<StoryVideoPlayerState> emit) {
    final controller = state.videoController;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    controller.play();
    emit(StoryVideoPlayerPlaying(
      videoController: controller,
      chewieController: state.chewieController,
      duration: controller.value.duration.inSeconds,
      metadata: state.metadata,
      rotationDegrees: state.rotationDegrees,
    ));
  }

  void _onPause(PauseStoryVideoEvent event, Emitter<StoryVideoPlayerState> emit) {
    final controller = state.videoController;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    controller.pause();
    emit(StoryVideoPlayerPaused(
      videoController: controller,
      chewieController: state.chewieController,
      duration: controller.value.duration.inSeconds,
      metadata: state.metadata,
      rotationDegrees: state.rotationDegrees,
    ));
  }

  void _onVolumeChanged(VolumeChangedEvent event, Emitter<StoryVideoPlayerState> emit) {
    final controller = state.videoController;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    final isVolumeOn = controller.value.volume == 1.0;
    controller.setVolume(isVolumeOn ? 0.0 : 1.0);
  }

  Future<void> _onDispose(DisposeStoryVideoPlayerEvent event, Emitter<StoryVideoPlayerState> emit) async {
    final videoController = state.videoController;
    final chewieController = state.chewieController;

    emit(StoryVideoPlayerDisposed(
      videoController: null,
      chewieController: null,
      duration: 0,
      metadata: state.metadata,
      rotationDegrees: state.rotationDegrees,
    ));
    await _disposeControllers(videoController, chewieController);
  }

  double _resolveAspectRatio(VideoPlayerController controller, int rotationDegrees) {
    final videoSize = controller.value.size;
    double aspectRatio;

    if (videoSize.width > 0 && videoSize.height > 0) {
      aspectRatio = videoSize.width / videoSize.height;
    } else if (controller.value.aspectRatio > 0) {
      aspectRatio = controller.value.aspectRatio;
    } else {
      aspectRatio = 9 / 16;
    }

    // Invert aspect ratio when video is rotated 90 or 270 degrees
    if (rotationDegrees == 90 || rotationDegrees == 270) {
      aspectRatio = 1 / aspectRatio;
    }

    return aspectRatio;
  }

  Future<void> _disposeControllers(VideoPlayerController? videoController, ChewieController? chewieController) async {
    try {
      chewieController?.dispose();
    } catch (_) {
      // Ignore dispose errors; controllers are being torn down.
    }

    if (videoController != null) {
      try {
        await videoController.dispose();
      } catch (_) {
        // Ignore dispose errors; controllers are being torn down.
      }
    }
  }

  @override
  Future<void> close() async {
    await _disposeControllers(state.videoController, state.chewieController);
    await super.close();
  }
}
