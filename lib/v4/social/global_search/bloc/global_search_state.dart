part of 'global_search_bloc.dart';

class GlobalSearchState extends Equatable {
  const GlobalSearchState();
  
  @override
  List<Object> get props => [];
}

class GlobalSearchInitial extends GlobalSearchState {}

class GlobalSearchTextChange extends GlobalSearchState {
  final String searchText;

  const GlobalSearchTextChange(this.searchText);

  @override
  List<Object> get props => [searchText];
}

class GlobalSearchLoaded extends GlobalSearchState {
  final List<AmityCommunity> communities;
  final bool isFetching;

  final String searchText;

  const GlobalSearchLoaded(this.communities, this.isFetching,
      [this.searchText = '']);

  @override
  List<Object> get props => [communities, isFetching, searchText];
}

class GlobalUserSearchLoaded extends GlobalSearchState {
  final List<AmityUser> users;
  final bool isFetching;

  final String searchText;

  const GlobalUserSearchLoaded(this.users, this.isFetching,
      [this.searchText = '']);

  @override
  List<Object> get props => [users, isFetching, searchText];
}

class GlobalSearchLoading extends GlobalSearchState {}

class GlobalPostSearchLoaded extends GlobalSearchState {
  final List<AmityPost> posts;
  final bool isFetching;
  final String searchText;

  const GlobalPostSearchLoaded(this.posts, this.isFetching,
      [this.searchText = '']);

  @override
  List<Object> get props => [posts, isFetching, searchText];
}