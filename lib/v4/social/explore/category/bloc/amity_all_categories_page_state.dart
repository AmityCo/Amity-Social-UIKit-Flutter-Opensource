part of 'amity_all_categories_page_bloc.dart';

// ignore: must_be_immutable
class AllCategoriesPageState extends Equatable {
  List<CommunityCategory> categories = [];

  copyWith({
    List<CommunityCategory>? categories,
  }) {
    return AllCategoriesPageState()
      ..categories = categories ?? this.categories;
  }

  @override
  List<Object> get props => [categories];
}
