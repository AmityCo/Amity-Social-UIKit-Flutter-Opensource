part of 'story_video_player_bloc.dart';

abstract class StoryVideoPlayerState extends Equatable {
  final VideoPlayerController? videoController;
  final ChewieController? chewieController;
  final int duration;
  const StoryVideoPlayerState( { required this.duration , required this.videoController , required this.chewieController });
  
  @override
  List<Object> get props => [];
}

class StoryVideoPlayerInitial extends StoryVideoPlayerState {
  const StoryVideoPlayerInitial( {required super.videoController, required super.chewieController, required super.duration});
}

class StoryVideoPlayerInitialized extends StoryVideoPlayerState {
  const StoryVideoPlayerInitialized({required super.videoController, required super.chewieController, required super.duration});

  @override
  List<Object> get props => [videoController!, chewieController!];
}

class StoryVideoPlayerPlaying extends StoryVideoPlayerState {
  const StoryVideoPlayerPlaying( {required super.videoController, required super.chewieController, required super.duration});
}

class StoryVideoPlayerDisposed extends StoryVideoPlayerState {
  const StoryVideoPlayerDisposed( {required super.videoController, required super.chewieController, required super.duration});

  @override
  List<Object> get props => [videoController??"", chewieController??""];
}

class StoryVideoPlayerPaused extends StoryVideoPlayerState {
  const StoryVideoPlayerPaused( {required super.videoController, required super.chewieController, required super.duration});
}
