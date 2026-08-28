part of 'global_search_bloc.dart';

class GlobalSearchEvent extends Equatable {
  const GlobalSearchEvent();

  @override
  List<Object> get props => [];
}

class SearchUsersEvent extends GlobalSearchEvent {
  final String searchText;

  const SearchUsersEvent(this.searchText);

  @override
  List<Object> get props => [searchText];
}

class NotifyUsersEvent extends GlobalSearchEvent {
  final List<AmityUser> users;
  final bool isFetching;

  final String searchText;

  const NotifyUsersEvent(this.users, this.isFetching, [this.searchText = '']);

  @override
  List<Object> get props => [users, isFetching, searchText];
}

class NotifyCommunitiesEvent extends GlobalSearchEvent {
  final List<AmityCommunity> communities;
  final bool isFetching;

  final String searchText;

  const NotifyCommunitiesEvent(this.communities, this.isFetching,
      [this.searchText = '']);

  @override
  List<Object> get props => [communities, isFetching, searchText];
}

class GlobalSearchLoadMoreEvent extends GlobalSearchEvent {
  const GlobalSearchLoadMoreEvent();

  @override
  List<Object> get props => [];
}

class GlobalUserSearchLoadMoreEvent extends GlobalSearchEvent {
  const GlobalUserSearchLoadMoreEvent();

  @override
  List<Object> get props => [];
}



class SearchCommunitiesEvent extends GlobalSearchEvent {
  final String text;

  const SearchCommunitiesEvent(this.text);

  @override
  List<Object> get props => [text];
}

class SearchPostsEvent extends GlobalSearchEvent {
  final String searchText;

  const SearchPostsEvent(this.searchText);

  @override
  List<Object> get props => [searchText];
}

class NotifyPostsEvent extends GlobalSearchEvent {
  final List<AmityPost> posts;
  final bool isFetching;
  final String searchText;

  const NotifyPostsEvent(this.posts, this.isFetching, [this.searchText = '']);

  @override
  List<Object> get props => [posts, isFetching, searchText];
}

class GlobalPostSearchLoadMoreEvent extends GlobalSearchEvent {
  const GlobalPostSearchLoadMoreEvent();

  @override
  List<Object> get props => [];
}
