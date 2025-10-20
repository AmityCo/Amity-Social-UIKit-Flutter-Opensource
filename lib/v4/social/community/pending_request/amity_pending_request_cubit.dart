import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/social/community/pending_request/amity_pending_request_page.dart';
import 'package:amity_uikit_beta_service/v4/social/community/pending_request/amity_pending_request_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AmityPendingRequestCubit extends Cubit<AmityPendingRequestState> {
  AmityPendingRequestCubit({
    required AmityCommunity community,
    required AmityPendingRequestPageTab initialTab,
  }) : super(AmityPendingRequestState(
          community: community,
          activeTab: initialTab,
          isLoading: true,
        )) {
    _initializePage();
  }

  void _initializePage() {
    // Initial setup is mostly handled by the state constructor
    emit(state.copyWith(isLoading: false));
  }

  /// Updates the pending post count
  void updatePendingPostCount(int count) {
    emit(state.copyWith(pendingPostCount: count));
  }

  /// Updates the join request count
  void updateJoinRequestCount(int count) {
    emit(state.copyWith(joinRequestCount: count));
  }

  /// Changes the active tab
  void changeTab(AmityPendingRequestPageTab tab) {
    emit(state.copyWith(activeTab: tab));
  }
}
