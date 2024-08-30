
part of 'single_video_player_bloc.dart';

abstract class SingleVideoPlayerEvent extends Equatable {
  const SingleVideoPlayerEvent();

  @override
  List<Object> get props => [];
}

class SingleVideoPlayerEventInitial extends SingleVideoPlayerEvent {}

class SingleVideoPlayerEventPageChanged extends SingleVideoPlayerEvent {
  final int currentIndex;

  const SingleVideoPlayerEventPageChanged({required this.currentIndex});

  @override
  List<Object> get props => [currentIndex];
}

class SingleVideoPlayerEventDispose extends SingleVideoPlayerEvent {}
