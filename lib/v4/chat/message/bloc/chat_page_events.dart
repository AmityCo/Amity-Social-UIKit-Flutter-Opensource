part of 'chat_page_bloc.dart';

abstract class ChatPageEvent extends Equatable {
  const ChatPageEvent();

  @override
  List<Object> get props => [];
}

class LoadMessages extends ChatPageEvent {}

class ChatPageEventChanged extends ChatPageEvent {
  final List<AmityMessage> messages;
  final bool isFetching;

  const ChatPageEventChanged(
      {required this.messages, required this.isFetching});

  @override
  List<Object> get props => [messages, isFetching];
}

class ChatPageEventRefresh extends ChatPageEvent {
  const ChatPageEventRefresh();
}

class ChatPageEventChannelIdChanged extends ChatPageEvent {
  final String channelId;

  const ChatPageEventChannelIdChanged(this.channelId);

  @override
  List<Object> get props => [channelId];
}

class ChatPageEventLoadMore extends ChatPageEvent {
  const ChatPageEventLoadMore();
}

class ChatPageEventFetchMuteState extends ChatPageEvent {
  const ChatPageEventFetchMuteState();
}

class ChatPageEventCreateNewChannel extends ChatPageEvent {
  final String userId;
  const ChatPageEventCreateNewChannel({required this.userId});

  @override
  List<Object> get props => [userId];
}

class ChatPageEventMuteUnmute extends ChatPageEvent {
  const ChatPageEventMuteUnmute();
}

class ChatPageEventResendMessage extends ChatPageEvent {
  final AmityMessage message;
  const ChatPageEventResendMessage({required this.message});

  @override
  List<Object> get props => [message];
}

class ChatPageEventLoadingStateUpdated extends ChatPageEvent {
  final bool isFetching;

  const ChatPageEventLoadingStateUpdated({required this.isFetching});

  @override
  List<Object> get props => [isFetching];
}

class ChatPageHeaderEventChanged extends ChatPageEvent {
  final AmityChannelMember channelMember;

  const ChatPageHeaderEventChanged({required this.channelMember});

  @override
  List<Object> get props => [channelMember];
}

class ChatPageIsMuteEventChanged extends ChatPageEvent {
  final bool isMute;

  const ChatPageIsMuteEventChanged({required this.isMute});

  @override
  List<Object> get props => [isMute];
}

class ChatPageEventFetchLocalVideoThumbnail extends ChatPageEvent {
  final String uniqueId;
  final String videoPath;

  const ChatPageEventFetchLocalVideoThumbnail(
      {required this.uniqueId, required this.videoPath});

  @override
  List<Object> get props => [uniqueId, videoPath];
}

class ChatPageNetworkConnectivityChanged extends ChatPageEvent {
  final bool isConnected;

  const ChatPageNetworkConnectivityChanged({required this.isConnected});

  @override
  List<Object> get props => [isConnected];
}

class ChatPageReplyEvent extends ChatPageEvent {
  final ReplyingMesage message;

  const ChatPageReplyEvent({required this.message});

  @override
  List<Object> get props => [message];
}

class ChatPageRemoveReplyEvent extends ChatPageEvent {
  const ChatPageRemoveReplyEvent();
}

class ChatPageEditEvent extends ChatPageEvent {
  final AmityMessage message;

  const ChatPageEditEvent({required this.message});

  @override
  List<Object> get props => [message];
}

class ChatPageShowScrollButtonEvent extends ChatPageEvent {
  final bool showScrollButton;

  const ChatPageShowScrollButtonEvent({required this.showScrollButton});

  @override
  List<Object> get props => [showScrollButton];
}

class ChatPageNewMessageUpdated extends ChatPageEvent {
  final AmityMessage? newMessage;

  const ChatPageNewMessageUpdated({required this.newMessage});

  @override
  List<Object> get props => [];
}

class ChatPageEventMarkReadMessage extends ChatPageEvent {
  final AmityMessage message;

  const ChatPageEventMarkReadMessage({required this.message});

  @override
  List<Object> get props => [message];
}
