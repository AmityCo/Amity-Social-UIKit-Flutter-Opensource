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
  final String successMessage;
  final String errorMessage;
  final String limitErrorTitle;
  final String limitErrorMessage;
  
  const ChatListEventChannelArchive({
    required this.channelId,
    required this.successMessage,
    required this.errorMessage,
    required this.limitErrorTitle,
    required this.limitErrorMessage,
  });
  
  @override
  List<Object> get props => [channelId, successMessage, errorMessage, limitErrorTitle, limitErrorMessage];
}

class ChatListEventChannelUnarchive extends ChatListEvent {
  final String channelId;
  final String successMessage;
  final String errorMessage;
  
  const ChatListEventChannelUnarchive({
    required this.channelId,
    required this.successMessage,
    required this.errorMessage,
  });
  
  @override
  List<Object> get props => [channelId, successMessage, errorMessage];
}

class ChatListEventResetDialogState extends ChatListEvent {}