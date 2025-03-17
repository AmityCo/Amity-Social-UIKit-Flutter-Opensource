import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_creation/element/category_grid_view.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'community_add_category_page_event.dart';
part 'community_add_category_page_state.dart';

class CommunityAddCategoryPageBloc
    extends Bloc<CommunityAddCategoryPageEvent, CommunityAddCategoryPageState> {
  late PagingController<AmityCommunityCategory> _pagingController;

  CommunityAddCategoryPageBloc(List<CommunityCategory> categories) : super(CommunityAddCategoryPageState().copyWith(selectedCategories: categories)) {

    on<CommunityAddCategoryPageLoadedEvent>((event, emit) {
      emit(state.copyWith(categories: event.categories));
    });

    _pagingController = PagingController<AmityCommunityCategory>(
      pageFuture: (token) => AmitySocialClient.newCommunityRepository()
          .getCategories()
          .sortBy(AmityCommunityCategorySortOption.NAME)
          .includeDeleted(false)
          .getPagingData(token: token, limit: 20),
      pageSize: 20,
    )..addListener(() {
        add(CommunityAddCategoryPageLoadedEvent(_pagingController.loadedItems
            .map((e) => CommunityCategory(category: e))
            .toList()));
      });

    // initial loading the first page
    _pagingController.fetchNextPage();

    on<CommunityAddCategoryPageLoadMoreEvent>((event, emit) {
      _pagingController.fetchNextPage();
    });

    on<CommunityAddCategoryPageCategorySelectedEvent>((event, emit) {
      final selectedCategories =
          List<CommunityCategory>.from(state.selectedCategories);
      if (selectedCategories.map((e) => e.id).contains(event.category.id)) {
        selectedCategories.removeWhere((element) => element.id == event.category.id);
      } else {
        if (state.selectedCategories.length < 10) {
          selectedCategories.add(event.category);
        }
      }

      emit(state.copyWith(
          selectedCategories: selectedCategories, hasCategoriesChanged: true));
    });

    on<CommunityAddCategoryAddCategoryEvent>((event, emit) {
      event.onSuccess();
    });
  }
}
