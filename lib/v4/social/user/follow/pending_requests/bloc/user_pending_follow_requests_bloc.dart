import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/amity_uikit_toast.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/user/user_relationship_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:amity_uikit_beta_service/v4/utils/bloc_extension.dart';

part 'user_pending_follow_requests_events.dart';
part 'user_pending_follow_requests_state.dart';

class UserPendingFollowRequestsBloc extends Bloc<UserPendingFollowRequestsEvent,
    UserPendingFollowRequestsState> {
  FollowerLiveCollection? followerUsersLiveCollection;

  UserPendingFollowRequestsBloc()
      : super(const UserPendingFollowRequestsState()) {
    on<UserPendingFollowRequestsUsersUpdated>((event, emit) {
      emit(state.copyWith(users: event.users));
    });

    on<UserPendingFollowRequestsLoadingStateUpdated>((event, emit) {
      emit(state.copyWith(isLoading: event.isLoading));
    });

    on<UserPendingFollowRequestsLoadNextPage>((event, emit) {});

    final relationshipManager = UserRelationshipManager();

    on<UserPendingFollowRequestsActionEvent>((event, emit) async {
      final user = event.user;
      final displayName = user?.displayName ?? "Unknown User";
      final completion = event.callback;

      switch (event.action) {
        case UserPendingFollowRequestsAction.accept:
          relationshipManager.acceptFollower(user?.userId ?? "", onSuccess: () {
            event.toastBloc.add(AmityToastShort(
                message: "$displayName is now following you.",
                icon: AmityToastIcon.success));

            completion();
          }, onError: () {
            event.toastBloc.add(const AmityToastShort(
                message: "Failed to accept follow request. Please try again.",
                icon: AmityToastIcon.warning));

            completion();
          });
          break;
        case UserPendingFollowRequestsAction.decline:
          relationshipManager.declineFollower(user?.userId ?? "",
              onSuccess: () {
            event.toastBloc.add(const AmityToastShort(
                message: "Following request declined.",
                icon: AmityToastIcon.success));

            completion();
          }, onError: () {
            event.toastBloc.add(const AmityToastShort(
                message: "Failed to decline follow request. Please try again.",
                icon: AmityToastIcon.warning));

            completion();
          });

          break;
      }
    });

    followerUsersLiveCollection = AmityCoreClient.newUserRepository()
        .relationship()
        .getMyFollowers()
        .status(AmityFollowStatusFilter.PENDING)
        .getLiveCollection();

    followerUsersLiveCollection?.observeLoadingState().listen((isLoading) {
      addEvent(
          UserPendingFollowRequestsLoadingStateUpdated(isLoading: isLoading));
    });

    followerUsersLiveCollection?.getStreamController().stream.listen((users) {
      addEvent(UserPendingFollowRequestsUsersUpdated(users: users));
    });

    followerUsersLiveCollection?.loadNext();
  }

  @override
  Future<void> close() {
    followerUsersLiveCollection?.dispose();
    return super.close();
  }
}
