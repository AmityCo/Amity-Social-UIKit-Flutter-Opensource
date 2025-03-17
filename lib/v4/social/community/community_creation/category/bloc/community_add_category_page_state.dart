part of 'community_add_category_page_bloc.dart';

// ignore: must_be_immutable
class CommunityAddCategoryPageState extends Equatable {
  List<CommunityCategory> selectedCategories = [];
  List<CommunityCategory> categories = [];
  bool hasCategoriesChanged = false;
  CommunityAddCategoryPageState();

  CommunityAddCategoryPageState copyWith({
    List<CommunityCategory>? selectedCategories,
    List<CommunityCategory>? categories,
    bool? hasCategoriesChanged,
  }) {
    return CommunityAddCategoryPageState()
      ..selectedCategories = selectedCategories ?? this.selectedCategories
      ..categories = categories ?? this.categories
      ..hasCategoriesChanged = hasCategoriesChanged ?? this.hasCategoriesChanged;
  }

  @override
  List<Object> get props => [selectedCategories, categories, hasCategoriesChanged];
}
