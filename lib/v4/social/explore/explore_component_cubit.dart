import 'dart:async';
import 'dart:ffi';

import 'package:amity_uikit_beta_service/v4/social/explore/explore_component_state.dart';
import 'package:amity_uikit_beta_service/v4/social/explore/list_state/amity_list_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExploreComponentCubit extends Cubit<ExploreComponentState> {
  ExploreComponentCubit() : super(ExploreComponentState());

  void setRefreshing() async {
    emit(state.copyWith(
      isRefreshing: true,
      isError: false,
      isEmpty: false,
    ));

    await Future.delayed(const Duration(milliseconds: 1500));
    emit(state.copyWith(isRefreshing: false));
    recheckState();
  }

  void setCategoryState(CategoryListState categoryState) {
    emit(state.copyWith(categoryState: categoryState));
    recheckState();
  }

  void setRecommendedState(CommunityListState recommendedState) {
    emit(state.copyWith(recommendedState: recommendedState));
    recheckState();
  }

  void setTrendingState(CommunityListState trendingState) {
    emit(state.copyWith(trendingState: trendingState));
    recheckState();
  }

  void recheckState() {
    bool isEmpty = state.recommendedState == CommunityListState.empty &&
        state.trendingState == CommunityListState.empty;
    bool isError = state.recommendedState == CommunityListState.error &&
        state.trendingState == CommunityListState.error;

    if (isEmpty && !state.isError) {
      emit(state.copyWith(isEmpty: true, isError: false));
    } else if (isError && !state.isEmpty) {
      emit(state.copyWith(isError: true, isEmpty: false));
    } else {
      emit(state.copyWith(isEmpty: false, isError: false));
    }
  }
}

class ExploreComponentRefreshController {
  final _refreshController = StreamController<bool>.broadcast();
  Stream<bool> get refreshStream => _refreshController.stream;

  void notifyRefresh() {
    _refreshController.add(true);
  }

  void dispose() {
    _refreshController.close();
  }
}
