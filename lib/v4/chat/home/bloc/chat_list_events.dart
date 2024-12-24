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