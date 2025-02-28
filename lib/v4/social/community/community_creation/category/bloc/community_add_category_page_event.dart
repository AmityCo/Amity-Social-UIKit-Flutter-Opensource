part of 'community_add_category_page_bloc.dart';

class CommunityAddCategoryPageEvent extends Equatable {
  const CommunityAddCategoryPageEvent();

  @override
  List<Object> get props => [];
}

class CommunityAddCategoryPageLoadedEvent extends CommunityAddCategoryPageEvent {
  final List<CommunityCategory> categories;

  const CommunityAddCategoryPageLoadedEvent(this.categories);

  @override
  List<Object> get props => [categories];
}

class CommunityAddCategoryPageLoadMoreEvent extends CommunityAddCategoryPageEvent {}

class CommunityAddCategoryPageCategorySelectedEvent extends CommunityAddCategoryPageEvent {
  final CommunityCategory category;

  const CommunityAddCategoryPageCategorySelectedEvent(this.category);

  @override
  List<Object> get props => [category];
}

class CommunityAddCategoryAddCategoryEvent extends CommunityAddCategoryPageEvent {
  final Function onSuccess;

  const CommunityAddCategoryAddCategoryEvent({required this.onSuccess});

  @override
  List<Object> get props => [onSuccess];
}
