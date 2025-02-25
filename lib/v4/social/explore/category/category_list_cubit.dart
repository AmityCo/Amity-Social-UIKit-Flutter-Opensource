// Category Cubit
import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/social/explore/list_state/amity_list_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryListCubit extends Cubit<CategoryState> {
  CategoryListCubit()
      : super(CategoryState(
          isLoading: true,
          hasError: false,
          categories: const [],
        ));

  Future<void> loadCategories() async {
    try {
      emit(state.copyWith(isLoading: true, hasError: false));

      final categories = await AmitySocialClient.newCommunityRepository()
          .getCategories()
          .sortBy(AmityCommunityCategorySortOption.NAME)
          .includeDeleted(false)
          .getPagingData()
          .then((value) => value.data);

      emit(state.copyWith(
        isLoading: false,
        categories: categories,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: e.toString(),
      ));
    }
  }

  CategoryListState getCurrentState() {
    if (state.isLoading) return CategoryListState.loading;
    if (state.hasError) return CategoryListState.error;
    if (state.categories.isEmpty) return CategoryListState.empty;
    return CategoryListState.success;
  }
}
