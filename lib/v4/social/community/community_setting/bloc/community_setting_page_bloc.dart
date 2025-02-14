import 'dart:developer';

import 'package:amity_uikit_beta_service/v4/core/toast/amity_uikit_toast.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_setting/notification_setting/community_notification_setting_extension.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:amity_sdk/amity_sdk.dart';

part 'community_setting_page_events.dart';
part 'community_setting_page_state.dart';

class CommunitySettingPageBloc
    extends Bloc<CommunitySettingPageEvent, CommunitySettingPageState> {
  final AmityCommunity _community;
  late AmityCommunityNotification _communityNotification;

  CommunitySettingPageBloc(this._community)
      : super(CommunitySettingPageState()) {
    bool hasCommunityEditPermission =
        _community.hasPermission(AmityPermission.EDIT_COMMUNITY);

    // Check if the user has permission to edit the profile
    state.shouldShowEditProfile = hasCommunityEditPermission;
    // Check if the user has permission to change the post permission settings
    state.shouldShowPostPermission = hasCommunityEditPermission;
    // Check if the user has permission to change story comment settings
    state.shouldShowStoryComments = hasCommunityEditPermission;
    // Check if the user has permission to delete the community
    state.shouldShowCloseCommunity = hasCommunityEditPermission;

    _communityNotification = AmityCommunityNotification(_community.communityId ?? "");

    _communityNotification.getSettings().then((settings) {
      state.notificationSettings = settings;

      add(CommunityNotificaitonSettingEvent(
        isSocialNetworkEnabled: settings.isSocialNetworkEnabled(),
        isNotificationEnabled: settings.isEnabled ?? false,
      ));
    }).catchError((error) {
      add(const CommunityNotificaitonSettingEvent(
        isSocialNetworkEnabled: false,
        isNotificationEnabled: false,
      ));
    });

    on<CommunityNotificaitonSettingEvent>((event, emit) async {
        emit(state.copyWith(
          shouldShowNotificationSetting: event.isSocialNetworkEnabled,
          isNotificationEnabled: event.isNotificationEnabled,
        ));
    });

    on<CommunityNotificationSettingPageLoadEvent>((event, emit) async {
      final settings = await _communityNotification.getSettings();
      emit(state.copyWith(notificationSettings: settings, isNotificationEnabled: settings.isEnabled ?? false));
    });

    on<LeaveCommunityEvent>((event, emit) async {
      AmitySocialClient.newCommunityRepository()
          .leaveCommunity(_community.communityId ?? '')
          .then((value) {
        event.toastBloc.add(const AmityToastShort(
            message: "Successfully leaved the community.", icon: AmityToastIcon.success));
        event.onSuccess();
      }).onError((error, stackTrace) {
        event.toastBloc.add(
            const AmityToastShort(message: "Failed to leave the community."));
        event.onFailure();
      });
    });

    on<CloseCommunityEvent>((event, emit) async {
      AmitySocialClient.newCommunityRepository()
          .deleteCommunity(_community.communityId ?? '')
          .then((value) {
        event.toastBloc.add(const AmityToastShort(
            message: "Successfully closed the community.", icon: AmityToastIcon.success));
        event.onSuccess();
      }).onError((error, stackTrace) {
        event.toastBloc.add(
            const AmityToastShort(message: "Failed to close the community."));
        event.onFailure();
      });
    });
  }
}


