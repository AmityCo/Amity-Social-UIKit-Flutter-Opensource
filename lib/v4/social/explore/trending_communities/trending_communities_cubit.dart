import 'dart:async';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/social/explore/explore_component_cubit.dart';
import 'package:amity_uikit_beta_service/v4/social/explore/list_state/amity_list_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TrendingCommunitiesCubit extends Cubit<CommunityState> {
  ExploreComponentRefreshController? refreshController;
  late final StreamSubscription? _refreshSubscription;

  TrendingCommunitiesCubit(this.refreshController)
      : super(CommunityState(
          isLoading: true,
          hasError: false,
          communities: const [],
        )) {
    loadTrendingCommunities();

    refreshController ??= ExploreComponentRefreshController();
    _refreshSubscription = refreshController?.refreshStream.listen((event) {
      loadTrendingCommunities();
    });
  }

  Future<void> loadTrendingCommunities() async {
    try {
      emit(state.copyWith(isLoading: true));
      final communities = await AmitySocialClient.newCommunityRepository()
          .getTrendingCommunities()
          .then((communities) => communities.take(5).toList());

      emit(state.copyWith(
        isLoading: false,
        communities: communities,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> joinCommunity(String communityId) async {
    try {
      await AmitySocialClient.newCommunityRepository()
          .joinCommunity(communityId);
      refreshController?.notifyRefresh();
    } catch (e) {
      emit(state.copyWith(
        hasError: true,
        errorMessage: 'Failed to join community',
      ));
    }
  }

  Future<void> leaveCommunity(String communityId) async {
    try {
      await AmitySocialClient.newCommunityRepository()
          .leaveCommunity(communityId);
      refreshController?.notifyRefresh();
    } catch (e) {
      emit(state.copyWith(
        hasError: true,
        errorMessage: 'Failed to leave community',
      ));
    }
  }

  CommunityListState getCurrentState() {
    if (state.isLoading) return CommunityListState.loading;
    if (state.hasError) return CommunityListState.error;
    if (state.communities.isEmpty) return CommunityListState.empty;
    return CommunityListState.success;
  }

  @override
  Future<void> close() {
    _refreshSubscription?.cancel();
    return super.close();
  }
}
