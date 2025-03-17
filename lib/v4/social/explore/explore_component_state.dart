import 'package:amity_uikit_beta_service/v4/social/explore/list_state/amity_list_states.dart';

class ExploreComponentState {
  final bool isRefreshing;
  final bool isEmpty;
  final bool isError;
  final CategoryListState categoryState;
  final CommunityListState recommendedState;
  final CommunityListState trendingState;

  ExploreComponentState({
    this.isRefreshing = false,
    this.isEmpty = false,
    this.isError = false,
    this.categoryState = CategoryListState.loading,
    this.recommendedState = CommunityListState.loading,
    this.trendingState = CommunityListState.loading,
  });

  ExploreComponentState copyWith({
    bool? isRefreshing,
    bool? isEmpty,
    bool? isError,
    CategoryListState? categoryState,
    CommunityListState? recommendedState,
    CommunityListState? trendingState,
  }) {
    return ExploreComponentState(
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isEmpty: isEmpty ?? this.isEmpty,
      isError: isError ?? this.isError,
      categoryState: categoryState ?? this.categoryState,
      recommendedState: recommendedState ?? this.recommendedState,
      trendingState: trendingState ?? this.trendingState,
    );
  }
}