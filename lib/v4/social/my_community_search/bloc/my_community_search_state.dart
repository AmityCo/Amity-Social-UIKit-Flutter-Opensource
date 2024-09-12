part of 'my_community_search_bloc.dart';

class MyCommunitySearchState extends Equatable {
  const MyCommunitySearchState();
  
  @override
  List<Object> get props => [];
}

class GlobalSearchInitial extends MyCommunitySearchState {}

class MyCommunitySearchTextChange extends MyCommunitySearchState {
  final String searchText;

  const MyCommunitySearchTextChange(this.searchText);

  @override
  List<Object> get props => [searchText];
}

class MyCommunitySearchLoaded extends MyCommunitySearchState {
  final List<AmityCommunity> communities;
  final bool isFetching;

  const MyCommunitySearchLoaded(this.communities, this.isFetching);

  @override
  List<Object> get props => [communities, isFetching];
}