part of 'single_video_player_bloc.dart';

abstract class SingleVideoPlayerEvent extends Equatable {
  const SingleVideoPlayerEvent();

  @override
  List<Object> get props => [];
}

class SingleVideoPlayerEventInitial extends SingleVideoPlayerEvent {}

class SingleVideoPlayerEventDispose extends SingleVideoPlayerEvent {}
