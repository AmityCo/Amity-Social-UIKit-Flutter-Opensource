part of 'video_message_player_bloc.dart';

abstract class  VideoMessagePlayerEvent extends Equatable {
  const  VideoMessagePlayerEvent();

  @override
  List<Object> get props => [];
}

class  VideoMessagePlayerEventInitial extends  VideoMessagePlayerEvent {}

class  VideoMessagePlayerEventDispose extends  VideoMessagePlayerEvent {}