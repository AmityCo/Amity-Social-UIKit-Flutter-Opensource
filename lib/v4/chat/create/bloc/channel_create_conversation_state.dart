part of 'channel_create_conversation_bloc.dart';

class ChannelCreateConversationState extends Equatable {
  final List<AmityUser> list;
  final bool hasMoreItems;
  final bool isFetching;
  final String searchText;

  const ChannelCreateConversationState(
      {this.list = const [],
      this.hasMoreItems = false,
      this.isFetching = false,
      this.searchText = ''});

  @override
  List<Object?> get props => [list, hasMoreItems, isFetching, searchText];
}

class UserSearchTextChange extends ChannelCreateConversationState {
  final String searchText;

  const UserSearchTextChange(this.searchText) : super(searchText: searchText);

  @override
  List<Object> get props => [searchText];
}

class ChannelCreateConversationLoading extends ChannelCreateConversationState {}

class ChannelCreateConversationLoaded extends ChannelCreateConversationState {
  const ChannelCreateConversationLoaded({
    required List<AmityUser> list,
    required bool isFetching,
    required bool hasMoreItems,
    String searchText = '',
  }) : super(
          list: list,
          isFetching: isFetching,
          hasMoreItems: hasMoreItems,
          searchText: searchText,
        );

  ChannelCreateConversationLoaded copyWith({
    List<AmityUser>? list,
    bool? hasMoreItems,
    bool? isFetching,
    String? searchText,
  }) {
    return ChannelCreateConversationLoaded(
      list: list ?? this.list,
      hasMoreItems: hasMoreItems ?? this.hasMoreItems,
      isFetching: isFetching ?? this.isFetching,
      searchText: searchText ?? this.searchText,
    );
  }

  @override
  List<Object> get props => [list, hasMoreItems, isFetching, searchText];
}
