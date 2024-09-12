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

  const GlobalSearchLoaded(this.communities, this.isFetching);

  @override
  List<Object> get props => [communities, isFetching];
}

class GlobalUserSearchLoaded extends GlobalSearchState {
  final List<AmityUser> users;
  final bool isFetching;

  const GlobalUserSearchLoaded(this.users, this.isFetching);

  @override
  List<Object> get props => [users, isFetching];
}

class GlobalSearchLoading extends GlobalSearchState {}