import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/amity_uikit_toast.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/user/follow/user_relationship_page.dart';
import 'package:amity_uikit_beta_service/v4/social/user/user_relationship_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:amity_uikit_beta_service/v4/utils/bloc_extension.dart';

part 'user_relationship_events.dart';
part 'user_relationship_state.dart';

class UserRelationshipBloc
    extends Bloc<UserRelationshipEvent, UserRelationshipState> {
  final String userId;
  final AmityUserRelationshipPageTab selectedTab;
  FollowingLiveCollection? followingUsersLiveCollection;
  FollowerLiveCollection? followerUsersLiveCollection;

  UserRelationshipBloc(this.userId, this.selectedTab)
      : super(UserRelationshipState()) {
    on<UserRelationshipUsersUpdated>((event, emit) {
      emit(state.copyWith(followUsers: event.users));
    });

    on<UserRelationshipLoadingStateUpdated>((event, emit) {
      emit(state.copyWith(isLoading: event.isLoading));
    });

    on<UserRelationshipLoadNextPage>((event, emit) {});

    final relationshipManager = UserRelationshipManager();

    /* -- Moderation Events -- */
    on<UserModerationEvent>((event, emit) async {
      final userId = event.userId;
      final toast = event.toastBloc;

      switch (event.action) {
        case UserModerationAction.report:
          relationshipManager.reportUser(userId, onSuccess: () {
            event.toastBloc.add(AmityToastShort(
                message: event.successMessage,
                icon: AmityToastIcon.success));
          }, onError: () {
            toast.addEvent(AmityToastShort(
                message: event.errorMessage,
                icon: AmityToastIcon.warning));
          });
          break;
        case UserModerationAction.unreport:
          relationshipManager.unreportUser(userId, onSuccess: () {
            toast.add(AmityToastShort(
                message: event.successMessage,
                icon: AmityToastIcon.success));
          }, onError: () {
            toast.add(AmityToastShort(
                message: event.errorMessage,
                icon: AmityToastIcon.warning));
          });
          break;
        case UserModerationAction.block:
          relationshipManager.blockUser(userId, onSuccess: () {
            toast.add(AmityToastShort(
                message: event.successMessage,
                icon: AmityToastIcon.success));
          }, onError: () {
            toast.add(AmityToastShort(
                message: event.errorMessage,
                icon: AmityToastIcon.warning));
          });
          break;
        case UserModerationAction.unblock:
          relationshipManager.unblockUser(userId, onSuccess: () {
            toast.add(AmityToastShort(
                message: event.successMessage,
                icon: AmityToastIcon.success));
          }, onError: () {
            toast.add(AmityToastShort(
                message: event.errorMessage,
                icon: AmityToastIcon.warning));
          });
          break;
        case UserModerationAction.unfollow:
          relationshipManager.unfollowUser(userId, onSuccess: () {
            event.toastBloc.add(AmityToastShort(
                message: event.successMessage,
                icon: AmityToastIcon.success));
          }, onError: () {
            toast.add(AmityToastShort(
                message: event.errorMessage,
                icon: AmityToastIcon.warning));
          });
          break;
        case UserModerationAction.follow:
          relationshipManager.followUser(userId, onSuccess: () {
            event.toastBloc.add(AmityToastShort(
                message: event.successMessage,
                icon: AmityToastIcon.success));
          }, onError: (error) {
            toast.add(AmityToastShort(
                message: event.errorMessage,
                icon: AmityToastIcon.warning));
          });
          break;
      }
    });

    switch (selectedTab) {
      case AmityUserRelationshipPageTab.following:
        if (userId == AmityCoreClient.getUserId()) {
          followingUsersLiveCollection = AmityCoreClient.newUserRepository()
              .relationship()
              .getMyFollowings()
              .status(AmityFollowStatusFilter.ACCEPTED)
              .getLiveCollection();
        } else {
          followingUsersLiveCollection = AmityCoreClient.newUserRepository()
              .relationship()
              .getFollowings(userId)
              .status(AmityFollowStatusFilter.ACCEPTED)
              .getLiveCollection();
        }

        followingUsersLiveCollection?.observeLoadingState().listen((isLoading) {
          addEvent(UserRelationshipLoadingStateUpdated(isLoading: isLoading));
        });

        followingUsersLiveCollection
            ?.getStreamController()
            .stream
            .listen((users) {
          addEvent(UserRelationshipUsersUpdated(users: users));
        });

        followingUsersLiveCollection?.loadNext();

        break;
      case AmityUserRelationshipPageTab.follower:
        if (userId == AmityCoreClient.getUserId()) {
          followerUsersLiveCollection = AmityCoreClient.newUserRepository()
              .relationship()
              .getMyFollowers()
              .status(AmityFollowStatusFilter.ACCEPTED)
              .getLiveCollection();
        } else {
          followerUsersLiveCollection = AmityCoreClient.newUserRepository()
              .relationship()
              .getFollowers(userId)
              .status(AmityFollowStatusFilter.ACCEPTED)
              .getLiveCollection();
        }

        followerUsersLiveCollection?.observeLoadingState().listen((isLoading) {
          addEvent(UserRelationshipLoadingStateUpdated(isLoading: isLoading));
        });

        followerUsersLiveCollection
            ?.getStreamController()
            .stream
            .listen((users) {
          addEvent(UserRelationshipUsersUpdated(users: users));
        });

        followerUsersLiveCollection?.loadNext();

        break;
    }
  }

  @override
  Future<void> close() {
    followingUsersLiveCollection?.dispose();
    followerUsersLiveCollection?.dispose();
    return super.close();
  }
}
