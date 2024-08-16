part of 'video_post_player_bloc.dart';

abstract class VideoPostPlayerEvent extends Equatable {
  const VideoPostPlayerEvent();

  @override
  List<Object> get props => [];
}

class VideoPostPlayerEventInitial extends VideoPostPlayerEvent {}

class VideoPostPlayerEventPageChanged extends VideoPostPlayerEvent {
  final int currentIndex;

  const VideoPostPlayerEventPageChanged({required this.currentIndex});

  @override
  List<Object> get props => [currentIndex];
}

class VideoPostPlayerEventDispose extends VideoPostPlayerEvent {}