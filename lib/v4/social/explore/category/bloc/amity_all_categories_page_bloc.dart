import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_creation/element/category_grid_view.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'amity_all_categories_page_event.dart';
part 'amity_all_categories_page_state.dart';

class AllCategoriesPageBloc
    extends Bloc<AllCategoriesPageEvent, AllCategoriesPageState> {
  late PagingController<AmityCommunityCategory> _pagingController;
  final ScrollController scrollController;

  AllCategoriesPageBloc({required this.scrollController}) : super(AllCategoriesPageState()) {
    on<AllCategoriesPageLoadedEvent>((event, emit) {
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
        add(AllCategoriesPageLoadedEvent(_pagingController.loadedItems
            .map((e) => CommunityCategory(category: e))
            .toList()));
      });

    // initial loading the first page
    _pagingController.fetchNextPage();

    scrollController.removeListener(() {});
    scrollController.addListener(() {
      final maxScroll = scrollController.position.maxScrollExtent;
      final currentScroll = scrollController.position.pixels;
      const threshold = 200.0; // Load more when within 200 pixels of the bottom

      if (maxScroll - currentScroll <= threshold && _pagingController.hasMoreItems) {
        _pagingController.fetchNextPage();
      }
    });
  }
}
