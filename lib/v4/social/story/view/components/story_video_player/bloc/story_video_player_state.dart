part of 'story_video_player_bloc.dart';

abstract class StoryVideoPlayerState extends Equatable {
  final VideoPlayerController? videoController;
  final ChewieController? chewieController;
  final int duration;
  final StoryVideoMetadata? metadata;
  final int rotationDegrees;

  const StoryVideoPlayerState({
    required this.duration,
    required this.videoController,
    required this.chewieController,
    this.metadata,
    this.rotationDegrees = 0,
  });

  @override
  List<Object?> get props => [
        runtimeType,
        videoController,
        chewieController,
        duration,
        metadata,
        rotationDegrees,
      ];
}

class StoryVideoPlayerInitial extends StoryVideoPlayerState {
  const StoryVideoPlayerInitial({
    required super.videoController,
    required super.chewieController,
    required super.duration,
    super.metadata,
    super.rotationDegrees,
  });
}

class StoryVideoPlayerInitialized extends StoryVideoPlayerState {
  const StoryVideoPlayerInitialized({
    required super.videoController,
    required super.chewieController,
    required super.duration,
    super.metadata,
    super.rotationDegrees,
  });
}

class StoryVideoPlayerPlaying extends StoryVideoPlayerState {
  const StoryVideoPlayerPlaying({
    required super.videoController,
    required super.chewieController,
    required super.duration,
    super.metadata,
    super.rotationDegrees,
  });
}

class StoryVideoPlayerDisposed extends StoryVideoPlayerState {
  const StoryVideoPlayerDisposed({
    required super.videoController,
    required super.chewieController,
    required super.duration,
    super.metadata,
    super.rotationDegrees,
  });
}

class StoryVideoPlayerPaused extends StoryVideoPlayerState {
  const StoryVideoPlayerPaused({
    required super.videoController,
    required super.chewieController,
    required super.duration,
    super.metadata,
    super.rotationDegrees,
  });
}
