import 'dart:async';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/social/explore/list_state/amity_list_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CommunityByCategoryListCubit extends Cubit<CommunityState> {
  final String categoryId;
  CommunityLiveCollection? _communityLiveCollection;
  StreamSubscription<List<AmityCommunity>>? _subscription;

  CommunityByCategoryListCubit(this.categoryId)
      : super(CommunityState(
          isLoading: true,
          hasError: false,
          communities: const [],
        )) {
    _initCollection();
  }

  void _initCollection() {
    _communityLiveCollection = AmitySocialClient.newCommunityRepository()
        .getCommunities()
        .categoryId(categoryId)
        .sortBy(AmityCommunitySortOption.DISPLAY_NAME)
        .getLiveCollection(pageSize: 20);

    _subscription =
        _communityLiveCollection!.getStreamController().stream.listen(
      (communities) {
        emit(state.copyWith(
          isLoading: false,
          communities: communities,
        ));
      },
      onError: (error) {
        emit(state.copyWith(
          isLoading: false,
          hasError: true,
          errorMessage: error.toString(),
        ));
      },
    );
  }

  Future<void> loadMore() async {
    await _communityLiveCollection?.loadNext();
  }

  CommunityListState getCurrentState() {
    if (state.isLoading) return CommunityListState.loading;
    if (state.hasError) return CommunityListState.error;
    if (state.communities.isEmpty) return CommunityListState.empty;
    return CommunityListState.success;
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    _communityLiveCollection?.dispose();
    return super.close();
  }
}
