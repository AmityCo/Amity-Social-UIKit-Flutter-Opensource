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

class ChatPageEventLoadPrevious extends ChatPageEvent {
  const ChatPageEventLoadPrevious();
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

class ChatPageEventFlagUser extends ChatPageEvent {
  final bool isFlagging; // true for flag, false for unflag

  const ChatPageEventFlagUser({required this.isFlagging});

  @override
  List<Object> get props => [isFlagging];
}

class ChatPageUserFlagStateChanged extends ChatPageEvent {
  final bool isFlagged;
  final AmityUser user;

  const ChatPageUserFlagStateChanged({required this.isFlagged,required this.user});

  @override
  List<Object> get props => [isFlagged, user];
}

class ChatPageEventFetchFollowInfo extends ChatPageEvent {
  const ChatPageEventFetchFollowInfo();

  @override
  List<Object> get props => [];
}

class ChatPageFollowInfoUpdated extends ChatPageEvent {
  final bool isUserBlocked;

  const ChatPageFollowInfoUpdated({required this.isUserBlocked});

  @override
  List<Object> get props => [isUserBlocked];
}

class ChatPageEventBlockUser extends ChatPageEvent {
  final bool isUserBlocked;

  const ChatPageEventBlockUser({required this.isUserBlocked});

  @override
  List<Object> get props => [isUserBlocked];
}

class ChatPageEventJumpToMessage extends ChatPageEvent {
  final String aroundMessageId;

  const ChatPageEventJumpToMessage({required this.aroundMessageId});

  @override
  List<Object> get props => [aroundMessageId];
}

class ChatPageSetAroundMessage extends ChatPageEvent {
  final String? aroundMessageId;
  
  const ChatPageSetAroundMessage({this.aroundMessageId});

  @override
  List<Object> get props => [aroundMessageId ?? ''];
}

class ChatPageTriggerBounceEvent extends ChatPageEvent {
  final int targetIndex;
  
  const ChatPageTriggerBounceEvent({required this.targetIndex});

  @override
  List<Object> get props => [targetIndex];
}

class ChatPageClearBounceEvent extends ChatPageEvent {
  const ChatPageClearBounceEvent();
}


