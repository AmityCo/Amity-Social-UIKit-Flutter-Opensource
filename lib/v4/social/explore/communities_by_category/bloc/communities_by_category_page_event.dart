part of 'communities_by_category_page_bloc.dart';

class CommunitiesByCategoriesPageEvent extends Equatable {
  const CommunitiesByCategoriesPageEvent();

  @override
  List<Object> get props => [];
}

class CommunitiesByCategoriesPageLoadedEvent extends CommunitiesByCategoriesPageEvent {
  final List<AmityCommunity> communities;

  const CommunitiesByCategoriesPageLoadedEvent(this.communities);

  @override
  List<Object> get props => [communities];
}