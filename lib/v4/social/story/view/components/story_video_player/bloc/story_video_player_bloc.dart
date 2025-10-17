import 'dart:io';

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

    emit(const StoryVideoPlayerInitial(videoController: null, chewieController: null, duration: 0));
    await _disposeControllers(previousVideoController, previousChewieController);

    VideoPlayerController? videoController;
    try {
      if (event.file != null) {
        videoController = VideoPlayerController.file(event.file!);
      } else if (event.url != null) {
        videoController = VideoPlayerController.networkUrl(Uri.parse(event.url!));
      }

      if (videoController == null) {
        emit(const StoryVideoPlayerDisposed(videoController: null, chewieController: null, duration: 0));
        return;
      }

      await videoController.initialize();
    } catch (_) {
      await _disposeControllers(videoController, null);
      emit(const StoryVideoPlayerDisposed(videoController: null, chewieController: null, duration: 0));
      return;
    }

    final chewieController = ChewieController(
      showControlsOnInitialize: false,
      videoPlayerController: videoController,
      autoPlay: true,
      showControls: false,
      autoInitialize: true,
      allowFullScreen: true,
      looping: event.looping,
    );

    emit(StoryVideoPlayerInitialized(
      videoController: videoController,
      chewieController: chewieController,
      duration: videoController.value.duration.inSeconds,
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

    emit(const StoryVideoPlayerDisposed(videoController: null, chewieController: null, duration: 0));
    await _disposeControllers(videoController, chewieController);
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
