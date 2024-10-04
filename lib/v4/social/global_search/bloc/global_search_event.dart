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

  const NotifyUsersEvent(this.users, this.isFetching);

  @override
  List<Object> get props => [users, isFetching];
}

class NotifyCommunitiesEvent extends GlobalSearchEvent {
  final List<AmityCommunity> communities;
  final bool isFetching;

  const NotifyCommunitiesEvent(this.communities, this.isFetching);

  @override
  List<Object> get props => [communities, isFetching];
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
