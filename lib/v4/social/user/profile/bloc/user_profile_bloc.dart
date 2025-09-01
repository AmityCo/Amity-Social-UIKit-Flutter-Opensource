import 'dart:developer';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/amity_uikit_toast.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/user/follow/user_relationship_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/user/user_relationship_manager.dart';
import 'package:amity_uikit_beta_service/v4/utils/bloc_extension.dart';
import 'package:amity_uikit_beta_service/v4/utils/error_util.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'user_profile_events.dart';
part 'user_profile_state.dart';

class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  UserProfileBloc(String userId) : super(UserProfileState(userId: userId)) {
    on<UserProfileEventUpdated>((event, emit) async {
      emit(state.copyWith(user: event.user));
    });

    on<UserMyFollowInfoEventUpdated>((event, emit) async {
      emit(state.copyWith(myFollowInfo: event.myFollowInfo));
    });

    on<UserFollowInfoEventUpdated>((event, emit) async {
      emit(state.copyWith(userFollowInfo: event.userFollowInfo));
    });

    on<UserProfileEventTabSelected>((event, emit) async {
      emit(state.copyWith(selectedIndex: event.tab));
    });

    on<UserFollowInfoFetchEvent>((event, emit) async {
      setupFollowInfo(userId);
    });

    on<UserProfileEventRefresh>((event, emit) async {
      setupUserInfo(userId);
    });

    on<UserProfileExpandHeaderEvent>((event, emit) async {
      emit(state.copyWith(isHeaderExpanded: true));
    });

    on<ShowUserNameOnAppBarEvent>((event, emit) async {
      emit(state.copyWith(showUserNameOnAppBar: event.showUserName));
    });

    final relationshipManager = UserRelationshipManager();

    // User Moderation
    on<UserProfileUserModerationEvent>((event, emit) async {
      final userId = event.userId;
      final toast = event.toastBloc;

      switch (event.action) {
        case UserModerationAction.report:
          relationshipManager.reportUser(userId, onSuccess: () {
            event.toastBloc.add(AmityToastShort(
                message: event.successMessage, icon: AmityToastIcon.success));
            // Update user info as its not live object
            setupUserInfo(userId);
          }, onError: () {
            toast.addEvent(AmityToastShort(
                message: event.errorMessage, icon: AmityToastIcon.warning));
          });
          break;
        case UserModerationAction.unreport:
          relationshipManager.unreportUser(userId, onSuccess: () {
            toast.add(AmityToastShort(
                message: event.successMessage, icon: AmityToastIcon.success));
            // Update user info as its not live object
            setupUserInfo(userId);
          }, onError: () {
            toast.add(AmityToastShort(
                message: event.errorMessage, icon: AmityToastIcon.warning));
          });
          break;
        case UserModerationAction.block:
          relationshipManager.blockUser(userId, onSuccess: () {
            toast.add(AmityToastShort(
                message: event.successMessage, icon: AmityToastIcon.success));

            setupFollowInfo(userId);
          }, onError: () {
            toast.add(AmityToastShort(
                message: event.errorMessage, icon: AmityToastIcon.warning));
          });
          break;
        case UserModerationAction.unblock:
          relationshipManager.unblockUser(userId, onSuccess: () {
            toast.add(AmityToastShort(
                message: event.successMessage, icon: AmityToastIcon.success));

            // Update follow info
            setupFollowInfo(userId);
          }, onError: () {
            toast.add(AmityToastShort(
                message: event.errorMessage, icon: AmityToastIcon.warning));
          });
          break;
        case UserModerationAction.unfollow:
          relationshipManager.unfollowUser(userId, onSuccess: () {
            // Query updated follow info again.
            setupFollowInfo(userId);
          }, onError: () {
            toast.add(AmityToastShort(
                message: event.errorMessage, icon: AmityToastIcon.warning));
          });
          break;
        case UserModerationAction.follow:
          relationshipManager.followUser(userId, onSuccess: () {
            // Query updated follow info again.
            setupFollowInfo(userId);
          }, onError: (error) {
            if (error != null && error is AmityException) {
              if (error.isAmityErrorWithCode(
                  AmityErrorCode.NO_USER_ACCESS_PERMISSION)) {
                event.onError();
              }
            } else {
              toast.add(AmityToastShort(
                  message: event.errorMessage, icon: AmityToastIcon.warning));
            }
          });
          break;
      }
    });

    setupUserInfo(userId);

    // Follow Info
    setupFollowInfo(userId);
  }

  void setupFollowInfo(String userId) {
    if (AmityCoreClient.getUserId() == userId) {
      AmityCoreClient.newUserRepository()
          .relationship()
          .getMyFollowInfo()
          .then((followInfo) {
        addEvent(UserMyFollowInfoEventUpdated(myFollowInfo: followInfo));
      }).onError((error, stackTrace) {
        log(error.toString());
      });
    } else {
      AmityCoreClient.newUserRepository()
          .relationship()
          .getFollowInfo(userId)
          .then((followInfo) {
        addEvent(UserFollowInfoEventUpdated(userFollowInfo: followInfo));
      }).onError((error, stackTrace) {
        log(error.toString());
      });
    }
  }

  void setupUserInfo(String userId) {
    AmityCoreClient.newUserRepository().getUser(userId).then((user) {
      addEvent(UserProfileEventUpdated(user: user));
    }).onError((error, stackTrace) {
      debugPrint("Error fetching user info: $error");
    });
  }
}
