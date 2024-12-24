part of 'channel_create_conversation_bloc.dart';

class ChannelCreateConversationState extends Equatable {
  const ChannelCreateConversationState();

  @override
  List<Object?> get props => [];
}

class UserSearchTextChange extends ChannelCreateConversationState {
  final String searchText;

  const UserSearchTextChange(this.searchText);

  @override
  List<Object> get props => [searchText];
}

class ChannelCreateConversationLoading extends ChannelCreateConversationState {}

class ChannelCreateConversationLoaded extends ChannelCreateConversationState {
  final List<AmityUser> list;
  final bool hasMoreItems;
  final bool isFetching;

  const ChannelCreateConversationLoaded(
      {required this.list,
      required this.hasMoreItems,
      required this.isFetching});

  ChannelCreateConversationLoaded copyWith({
    List<AmityUser>? list,
    bool? hasMoreItems,
    bool? isFetching,
  }) {
    return ChannelCreateConversationLoaded(
      list: list ?? this.list,
      hasMoreItems: hasMoreItems ?? this.hasMoreItems,
      isFetching: isFetching ?? this.isFetching,
    );
  }

  @override
  List<Object> get props => [list, hasMoreItems, isFetching];
}
