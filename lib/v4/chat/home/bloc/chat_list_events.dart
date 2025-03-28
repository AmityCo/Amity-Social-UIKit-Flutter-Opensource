part of 'chat_list_bloc.dart';

abstract class ChatListEvent extends Equatable {
  const ChatListEvent();

  @override
  List<Object> get props => [];
}

class ChatListEventChannelsUpdated extends ChatListEvent {
  final List<AmityChannel> channels;

  const ChatListEventChannelsUpdated({required this.channels});

  @override
  List<Object> get props => [channels];
}

class ChatListEventFetchMembers extends ChatListEvent {
  final List<String> channelIds;

  const ChatListEventFetchMembers({required this.channelIds});

  @override
  List<Object> get props => [channelIds];
}

class ChatListEventLoadingStateUpdated extends ChatListEvent {
  final bool isLoading;

  const ChatListEventLoadingStateUpdated({required this.isLoading});

  @override
  List<Object> get props => [isLoading];
}

class ChatListLoadNextPage extends ChatListEvent {}

class ChatListPushNotificationEvent extends ChatListEvent {
  final bool isPushNotificationEnabled;

  const ChatListPushNotificationEvent({required this.isPushNotificationEnabled});

  @override
  List<Object> get props => [isPushNotificationEnabled];
}

class ChatListEventChannelArchive extends ChatListEvent {
  final String channelId;
  
  const ChatListEventChannelArchive({required this.channelId});
  
  @override
  List<Object> get props => [channelId];
}

class ChatListEventChannelUnarchive extends ChatListEvent {
  final String channelId;
  
  const ChatListEventChannelUnarchive({required this.channelId});
  
  @override
  List<Object> get props => [channelId];
}

class ChatListEventResetDialogState extends ChatListEvent {}