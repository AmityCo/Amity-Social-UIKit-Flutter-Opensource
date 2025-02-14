part of 'channel_create_conversation_bloc.dart';

abstract class ChannelCreateConversationEvent extends Equatable {
  const ChannelCreateConversationEvent();

  @override
  List<Object> get props => [];
}

class ChannelCreateConversationEventInitial
    extends ChannelCreateConversationEvent {}

class ChannelCreateConversationEventLoadMore
    extends ChannelCreateConversationEvent {}

class SearchUsersEvent extends ChannelCreateConversationEvent {
  final String searchText;

  const SearchUsersEvent(this.searchText);

  @override
  List<Object> get props => [searchText];
}

class UsersLoadedEvent extends ChannelCreateConversationEvent {
  final List<AmityUser> users;
  final bool hasMoreItems;
  final bool isFetching;

  const UsersLoadedEvent({
    required this.users,
    required this.hasMoreItems,
    required this.isFetching,
  });
}

class LoadingStateUpdatedEvent extends ChannelCreateConversationEvent {
  final bool isFetching;

  const LoadingStateUpdatedEvent({required this.isFetching});

  @override
  List<Object> get props => [isFetching];
}
