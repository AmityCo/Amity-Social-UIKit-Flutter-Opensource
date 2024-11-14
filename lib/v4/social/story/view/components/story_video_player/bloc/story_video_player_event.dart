part of 'story_video_player_bloc.dart';

abstract class StoryVideoPlayerEvent extends Equatable {
  const StoryVideoPlayerEvent();

  @override
  List<Object> get props => [];
}


class InitializeStoryVideoPlayerEvent extends StoryVideoPlayerEvent {
  final File? file; 
  final String? url;
  const InitializeStoryVideoPlayerEvent({required this.file , required this.url});

  @override
  List<Object> get props => [file??"" , url??""];
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
