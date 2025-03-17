import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/amity_uikit_toast.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_setting/notification_setting/community_notification_setting_extension.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_setting/notification_setting/element/setting_radio_button.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'community_post_notification_setting_page_event.dart';
part 'community_post_notification_setting_page_state.dart';

class CommunityPostNotificationSettingPageBloc extends Bloc<
    CommunityPostNotificationSettingPageEvent,
    CommunityPostNotificationSettingPageState> {
  late AmityCommunity community;
  late AmityCommunityNotification _communityNotification;
  AmityCommunityNotificationSettings? notificationSettings;

  CommunityPostNotificationSettingPageBloc(AmityCommunity community, AmityCommunityNotificationSettings? notificationSettings)
      : super(CommunityPostNotificationSettingPageState()) {
    _communityNotification =
        AmityCommunityNotification(community.communityId ?? '');

    if (notificationSettings != null) {
        _emitInitialState(notificationSettings!);
    } else {
       _communityNotification.getSettings().then((settings) {
          _emitInitialState(settings);
       });
    }

    on<CommunityPostNotificationSettingChangedEvent>((event, emit) {
      final settingsChanged =
          state.initialReactPostSetting != event.reactPostSetting ||
              state.initialNewPostSetting != event.newPostSetting;
      emit(state.copyWith(
        reactPostSetting: event.reactPostSetting,
        newPostSetting: event.newPostSetting,
        settingsChanged: settingsChanged,
      ));
    });

    on<CommunityPostNotificationSettingSaveEvent>((event, emit) async {
      final postReactSetting = state.reactPostSetting == RadioButtonSetting.off ? PostReacted.disable() : state.reactPostSetting == RadioButtonSetting.everyone ? PostReacted.enable(All()) : PostReacted.enable(Only(AmityRoles(roles: ["moderator", "community-moderator"])));
      final postCreationSetting = state.newPostSetting == RadioButtonSetting.off ? PostCreated.disable() : state.newPostSetting == RadioButtonSetting.everyone ? PostCreated.enable(All()) : PostCreated.enable(Only(AmityRoles(roles: ["moderator", "community-moderator"])));

      _communityNotification
          .enable([postReactSetting, postCreationSetting]).then((value) {
        event.toastBloc.add(const AmityToastShort(
            message: "Successfully updated community profile!", icon: AmityToastIcon.success));
        event.onSuccess();
      });
    });
  }

  RadioButtonSetting _getRadioButtonSetting(
      AmityCommunityNotificationEvent? event) {
    if (event?.isEnabled == false) {
      return RadioButtonSetting.off;
    } else if (event?.rolesFilter is All) {
      return RadioButtonSetting.everyone;
    } else {
      return RadioButtonSetting.onlyModerator;
    }
  }

  void _emitInitialState(AmityCommunityNotificationSettings settings) {
    final postReactionEvent = (settings.events
          ?.firstWhere((event) => event is PostReacted) as PostReacted?);

      final postCreationEvent = (settings.events
          ?.firstWhere((event) => event is PostCreated) as PostCreated?);

      final reactPostSetting = _getRadioButtonSetting(postReactionEvent);
      final newPostSetting = _getRadioButtonSetting(postCreationEvent);

      emit(state.copyWith(
        reactPostSetting: reactPostSetting,
        newPostSetting: newPostSetting,
        initialReactPostSetting: reactPostSetting,
        initialNewPostSetting: newPostSetting,
        isReactPostNetworkEnabled: settings.isPostReactedEventEnabled(),
        isNewPostNetworkEnabled: settings.isPostCreatedEventEnabled()
      ));
  }
}
