part of 'story_video_player_bloc.dart';

abstract class StoryVideoPlayerEvent extends Equatable {
  const StoryVideoPlayerEvent();

  @override
  List<Object> get props => [];
}


class InitializeStoryVideoPlayerEvent extends StoryVideoPlayerEvent {
  final File? file; 
  final String? url;
  final bool looping;
  final StoryVideoMetadata? metadata;
  const InitializeStoryVideoPlayerEvent({required this.file , required this.url, required this.looping, this.metadata});

  @override
  List<Object> get props => [file ?? "", url ?? "", looping, metadata ?? 0];
}


class PlayStoryVideoEvent extends StoryVideoPlayerEvent {
  const PlayStoryVideoEvent();

  @override
  List<Object> get props => [];
}

class DisposeStoryVideoPlayerEvent extends StoryVideoPlayerEvent {
  const DisposeStoryVideoPlayerEvent();

  @override
  List<Object> get props => [];
}

class PauseStoryVideoEvent extends StoryVideoPlayerEvent {
  const PauseStoryVideoEvent();

  @override
  List<Object> get props => [];
}


class VolumeChangedEvent extends StoryVideoPlayerEvent {
  const VolumeChangedEvent();

  @override
  List<Object> get props => [];
}
