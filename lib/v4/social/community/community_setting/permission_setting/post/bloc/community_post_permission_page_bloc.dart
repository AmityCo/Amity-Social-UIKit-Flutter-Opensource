import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/amity_uikit_toast.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_setting/permission_setting/post/post_permission_radio_button.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'community_post_permission_page_event.dart';
part 'community_post_permission_page_state.dart';

class CommunityPostPermissionPageBloc extends Bloc<
    CommunityPostPermissionPageEvent, CommunityPostPermissionPageState> {
  late AmityCommunity community;
  late PostPermissionSetting postPermissionSetting;

  CommunityPostPermissionPageBloc(AmityCommunity community)
      : super(CommunityPostPermissionPageState()) {
    if (community.onlyAdminCanPost == true) {
      postPermissionSetting = PostPermissionSetting.onlyAdminsCanPost;
    } else if (community.isPostReviewEnabled == true) {
      postPermissionSetting = PostPermissionSetting.adminReviewPost;
    } else {
      postPermissionSetting = PostPermissionSetting.everyoneCanPost;
    }

    emit(state.copyWith(
      postPermissionSetting: postPermissionSetting,
      initialPostPermissionSetting: postPermissionSetting,
    ));

    on<CommunityPostPermissionSettingChangedEvent>((event, emit) {
      final settingsChanged =
          state.initialPostPermissionSetting != event.postPermissionSetting;
      emit(state.copyWith(
        postPermissionSetting: event.postPermissionSetting,
        settingsChanged: settingsChanged,
      ));
    });

    on<CommunityPostPermissionSettingSaveEvent>((event, emit) async {
      AmityCommunityPostSettings postSetting;

      if (state.postPermissionSetting == PostPermissionSetting.onlyAdminsCanPost) {
        postSetting = AmityCommunityPostSettings.ADMIN_CAN_POST_ONLY;
      } else if (state.postPermissionSetting == PostPermissionSetting.adminReviewPost) {
        postSetting = AmityCommunityPostSettings.ADMIN_REVIEW_POST_REQUIRED;
      } else {
        postSetting = AmityCommunityPostSettings.ANYONE_CAN_POST;
      }

      AmitySocialClient.newCommunityRepository()
          .updateCommunity(community.communityId ?? '')
          .postSetting(postSetting)
          .update()
          .then((value) {
        event.toastBloc.add(const AmityToastShort(
            message: "Successfully updated community post permissions!",
            icon: AmityToastIcon.success));
        event.onSuccess();
      }).onError((error, stackTrace) async {
        event.toastBloc.add(const AmityToastShort(
            message: "Failed to save your community profile. Please try again.",
            icon: AmityToastIcon.warning));
      });
    });
  }
}
