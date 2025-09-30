part of 'amity_group_chat_page_bloc.dart';

abstract class GroupChatPageEvent extends Equatable {
  const GroupChatPageEvent();

  @override
  List<Object> get props => [];
}

class GroupChatPageEventRefresh extends GroupChatPageEvent {}

class GroupChatPageEventChanged extends GroupChatPageEvent {
  final List<AmityMessage> messages;
  final bool isFetching;

  const GroupChatPageEventChanged(
      {required this.messages, required this.isFetching});

  @override
  List<Object> get props => [messages, isFetching];
}

class GroupChatPageEventChannelIdChanged extends GroupChatPageEvent {
  final String channelId;

  const GroupChatPageEventChannelIdChanged(this.channelId);

  @override
  List<Object> get props => [channelId];
}

class GroupChatPageEventLoadMore extends GroupChatPageEvent {
  const GroupChatPageEventLoadMore();
}

class GroupChatPageEventLoadPrevious extends GroupChatPageEvent {
  const GroupChatPageEventLoadPrevious();
}

class GroupChatPageEventFetchMuteState extends GroupChatPageEvent {
  const GroupChatPageEventFetchMuteState();
}

class GroupChatPageEventCreateNewChannel extends GroupChatPageEvent {
  final String userId;
  const GroupChatPageEventCreateNewChannel({required this.userId});

  @override
  List<Object> get props => [userId];
}

class GroupChatPageEventMuteUnmute extends GroupChatPageEvent {
  const GroupChatPageEventMuteUnmute();
}

class GroupChatPageEventResendMessage extends GroupChatPageEvent {
  final AmityMessage message;
  const GroupChatPageEventResendMessage({required this.message});

  @override
  List<Object> get props => [message];
}

class GroupChatPageEventLoadingStateUpdated extends GroupChatPageEvent {
  final bool isFetching;

  const GroupChatPageEventLoadingStateUpdated({required this.isFetching});

  @override
  List<Object> get props => [isFetching];
}

class GroupChatPageHeaderEventChanged extends GroupChatPageEvent {
  final AmityChannel channel;

  const GroupChatPageHeaderEventChanged({required this.channel});

  @override
  List<Object> get props => [channel];
}

class GroupChatPageIsMuteEventChanged extends GroupChatPageEvent {
  final bool isMute;

  const GroupChatPageIsMuteEventChanged({required this.isMute});

  @override
  List<Object> get props => [isMute];
}

class GroupChatPageEventFetchLocalVideoThumbnail extends GroupChatPageEvent {
  final String uniqueId;
  final String videoPath;

  const GroupChatPageEventFetchLocalVideoThumbnail(
      {required this.uniqueId, required this.videoPath});

  @override
  List<Object> get props => [uniqueId, videoPath];
}

class GroupChatPageNetworkConnectivityChanged extends GroupChatPageEvent {
  final bool isConnected;

  const GroupChatPageNetworkConnectivityChanged({required this.isConnected});

  @override
  List<Object> get props => [isConnected];
}

class GroupChatPageReplyEvent extends GroupChatPageEvent {
  final ReplyingMesage message;

  const GroupChatPageReplyEvent({required this.message});

  @override
  List<Object> get props => [message];
}

class GroupChatPageRemoveReplyEvent extends GroupChatPageEvent {
  const GroupChatPageRemoveReplyEvent();
}

class GroupChatPageEditEvent extends GroupChatPageEvent {
  final AmityMessage message;

  const GroupChatPageEditEvent({required this.message});

  @override
  List<Object> get props => [message];
}

class GroupChatPageShowScrollButtonEvent extends GroupChatPageEvent {
  final bool showScrollButton;

  const GroupChatPageShowScrollButtonEvent({required this.showScrollButton});

  @override
  List<Object> get props => [showScrollButton];
}

class GroupChatPageNewMessageUpdated extends GroupChatPageEvent {
  final AmityMessage? newMessage;

  const GroupChatPageNewMessageUpdated({required this.newMessage});

  @override
  List<Object> get props => [];
}

class GroupChatPageEventMarkReadMessage extends GroupChatPageEvent {
  final AmityMessage message;

  const GroupChatPageEventMarkReadMessage({required this.message});

  @override
  List<Object> get props => [message];
}

class GroupChatPageEventCheckModeratorStatus extends GroupChatPageEvent {
  final AmityChannel channel;

  const GroupChatPageEventCheckModeratorStatus({required this.channel});

  @override
  List<Object> get props => [channel];
}

class GroupChatPageModeratorStatusUpdated extends GroupChatPageEvent {
  final bool isModerator;

  const GroupChatPageModeratorStatusUpdated({required this.isModerator});

  @override
  List<Object> get props => [isModerator];
}

class GroupChatPageLoadMemberRoles extends GroupChatPageEvent {
  const GroupChatPageLoadMemberRoles();

  @override
  List<Object> get props => [];
}

class GroupChatPageMemberRolesUpdated extends GroupChatPageEvent {
  final Map<String, List<String>> memberRoles;

  const GroupChatPageMemberRolesUpdated({required this.memberRoles});

  @override
  List<Object> get props => [memberRoles];
}

class GroupChatPageMutedUsersUpdated extends GroupChatPageEvent {
  final Map<String, bool> mutedUsers;

  const GroupChatPageMutedUsersUpdated({required this.mutedUsers});

  @override
  List<Object> get props => [mutedUsers];
}

class GroupChatPageEventJumpToMessage extends GroupChatPageEvent {
  final String aroundMessageId;

  const GroupChatPageEventJumpToMessage({required this.aroundMessageId});

  @override
  List<Object> get props => [aroundMessageId];
}

class GroupChatPageSetAroundMessage extends GroupChatPageEvent {
  final String? aroundMessageId;
  
  const GroupChatPageSetAroundMessage({this.aroundMessageId});

  @override
  List<Object> get props => [aroundMessageId ?? ''];
}

class GroupChatPageTriggerBounceEvent extends GroupChatPageEvent {
  final int targetIndex;
  
  const GroupChatPageTriggerBounceEvent({required this.targetIndex});

  @override
  List<Object> get props => [targetIndex];
}

class GroupChatPageClearBounceEvent extends GroupChatPageEvent {
  const GroupChatPageClearBounceEvent();
}

class GroupChatPageSetLoadingToastDismissed extends GroupChatPageEvent {
  final bool isDismissed;
  
  const GroupChatPageSetLoadingToastDismissed({required this.isDismissed});

  @override
  List<Object> get props => [isDismissed];
}

class GroupChatPageSetShouldBounceMessage extends GroupChatPageEvent {
  final bool shouldBounce;
  final int? messageIndex;
  
  const GroupChatPageSetShouldBounceMessage({required this.shouldBounce, this.messageIndex});

  @override
  List<Object> get props => [shouldBounce, messageIndex ?? -1];
}

class GroupChatPageSetShouldUseReverse extends GroupChatPageEvent {
  final bool? shouldUseReverse;
  
  const GroupChatPageSetShouldUseReverse({required this.shouldUseReverse});

  @override
  List<Object> get props => [shouldUseReverse ?? false];
}
