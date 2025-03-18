part of 'amity_all_categories_page_bloc.dart';

class AllCategoriesPageEvent extends Equatable {
  const AllCategoriesPageEvent();

  @override
  List<Object> get props => [];
}

class AllCategoriesPageLoadedEvent extends AllCategoriesPageEvent {
  final List<CommunityCategory> categories;
  const AllCategoriesPageLoadedEvent(
    this.categories,
  ) : super();

  @override
  List<Object> get props => [categories];
}
