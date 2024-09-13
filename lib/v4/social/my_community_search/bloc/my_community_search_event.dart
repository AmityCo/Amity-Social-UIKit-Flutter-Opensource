part of 'my_community_search_bloc.dart';

class MyCommunitySearchEvent extends Equatable {
  const MyCommunitySearchEvent();

  @override
  List<Object> get props => [];
}


class MyCommunitySearchTextChanged extends MyCommunitySearchEvent {
  final String searchText;

  const MyCommunitySearchTextChanged(this.searchText);

  @override
  List<Object> get props => [searchText];
}

class NotifyEvent extends MyCommunitySearchEvent {
  final List<AmityCommunity> communities;
  final bool isFetching;

  const NotifyEvent(this.communities, this.isFetching);

  @override
  List<Object> get props => [communities, isFetching];
}

class MyCommunitySearchLoadMoreEvent extends MyCommunitySearchEvent {
  const MyCommunitySearchLoadMoreEvent();

  @override
  List<Object> get props => [];
}