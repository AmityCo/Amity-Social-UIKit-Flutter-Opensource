import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/freedom_uikit_behavior.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/amity_uikit_toast.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_setting/notification_setting/element/setting_radio_button.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_setting/permission_setting/freedom_community_permission_setting_behavior.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'community_post_permission_page_event.dart';
part 'community_post_permission_page_state.dart';

class CommunityPostPermissionPageBloc extends Bloc<
    CommunityPostPermissionPageEvent, CommunityPostPermissionPageState> {
  late AmityCommunity community;
  late RadioButtonSetting postPermissionSetting;

  FreedomCommunityPermissionSettingBehavior get _behavior => FreedomUIKitBehavior.instance.communityPermissionSettingBehavior;

  CommunityPostPermissionPageBloc(AmityCommunity community)
      : super(CommunityPostPermissionPageState()) {
    if (community.onlyAdminCanPost == true) {
      postPermissionSetting = RadioButtonSetting.off;
    } else if (community.isPostReviewEnabled == true) {
      postPermissionSetting = RadioButtonSetting.onlyModerator;
    } else {
      postPermissionSetting = RadioButtonSetting.everyone;
    }

    final initialPostPermissionSetting = _behavior.initialPostPermissionSetting;
    if (initialPostPermissionSetting != null) {
      initialPostPermissionSetting(community: community, emit: emit, state: state).then((result) {
        postPermissionSetting = result;
      });
    } else {
      emit(state.copyWith(
        postPermissionSetting: postPermissionSetting,
        initialPostPermissionSetting: postPermissionSetting,
      ));
    }

    on<CommunityPostPermissionSettingChangedEvent>((event, emit) {
      final settingsChanged =
          state.initialPostPermissionSetting != event.postPermissionSetting;
      emit(state.copyWith(
        postPermissionSetting: event.postPermissionSetting,
        settingsChanged: settingsChanged,
      ));
    });

    on<CommunityPostPermissionSettingSaveEvent>((event, emit) async {
      // off -> onlyAdminCanPost
      // onlyModerator -> isPostReviewEnabled
      // everyone -> !onlyAdminCanPost && !isPostReviewEnabled

      AmityCommunityPostSettings postSetting;

      if (state.postPermissionSetting == RadioButtonSetting.off) {
        postSetting = AmityCommunityPostSettings.ADMIN_CAN_POST_ONLY;
      } else if (state.postPermissionSetting ==
          RadioButtonSetting.onlyModerator) {
        postSetting = AmityCommunityPostSettings.ADMIN_REVIEW_POST_REQUIRED;
      } else {
        postSetting = AmityCommunityPostSettings.ANYONE_CAN_POST;
      }

      AmitySocialClient.newCommunityRepository()
          .updateCommunity(community.communityId ?? '')
          .postSetting(postSetting)
          .update()
          .then((value) {
        //handle result
        final savePostPermission = _behavior.savePostPermission;
        if (savePostPermission != null) {
          savePostPermission(community, state.postPermissionSetting);
          event.onSuccess();
          return;
        }

        event.toastBloc.add(const AmityToastShort(
            message: "Successfully updated community post permissions!", icon: AmityToastIcon.success));
        event.onSuccess();
      }).onError((error, stackTrace) async {
        //handle error
        event.toastBloc
            .add(const AmityToastShort(message: "Failed to update community!"));
      });
    });
  }
}
