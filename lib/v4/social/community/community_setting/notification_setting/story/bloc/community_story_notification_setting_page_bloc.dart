import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/freedom_uikit_behavior.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/amity_uikit_toast.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_setting/notification_setting/community_notification_setting_extension.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_setting/notification_setting/element/setting_radio_button.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_setting/notification_setting/post/bloc/community_post_notification_setting_page_bloc.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'community_story_notification_setting_page_event.dart';
part 'community_story_notification_setting_page_state.dart';

class CommunityStoryNotificationSettingPageBloc extends Bloc<
    CommunityStoryNotificationSettingPageEvent,
    CommunityStoryNotificationSettingPageState> {
  late AmityCommunity community;
  late AmityCommunityNotification _communityNotification;
  AmityCommunityNotificationSettings? notificationSettings;

  CommunityStoryNotificationSettingPageBloc(AmityCommunity community,
      AmityCommunityNotificationSettings? notificationSettings)
      : super(CommunityStoryNotificationSettingPageState()) {
    _communityNotification =
        AmityCommunityNotification(community.communityId ?? '');

    if (notificationSettings != null) {
      _emitInitialState(notificationSettings);
    } else {
      _communityNotification.getSettings().then((settings) {
        _emitInitialState(settings);
      });
    }

    on<CommunityStoryNotificationSettingChangedEvent>((event, emit) {
      final settingsChanged =
          state.initialReactStorySetting != event.reactStorySetting ||
              state.initialNewStorySetting != event.newStorySetting ||
              state.initialCommentStorySetting != event.commentStorySetting;
      emit(state.copyWith(
        reactStorySetting: event.reactStorySetting,
        newStorySetting: event.newStorySetting,
        commentStorySetting: event.commentStorySetting,
        settingsChanged: settingsChanged,
      ));
    });

    on<CommunityStoryNotificationSettingSaveEvent>((event, emit) async {
      final storyReactSetting =
          state.reactStorySetting == RadioButtonSetting.off
              ? StoryReacted.disable()
              : state.reactStorySetting == RadioButtonSetting.everyone
                  ? StoryReacted.enable(All())
                  : StoryReacted.enable(Only(
                      AmityRoles(roles: ["moderator", "community-moderator"])));
      final storyCreationSetting =
          state.newStorySetting == RadioButtonSetting.off
              ? StoryCreated.disable()
              : state.newStorySetting == RadioButtonSetting.everyone
                  ? StoryCreated.enable(All())
                  : StoryCreated.enable(Only(
                      AmityRoles(roles: ["moderator", "community-moderator"])));
      final storyCommentSetting =
          state.commentStorySetting == RadioButtonSetting.off
              ? StoryCommentCreated.disable()
              : state.commentStorySetting == RadioButtonSetting.everyone
                  ? StoryCommentCreated.enable(All())
                  : StoryCommentCreated.enable(Only(
                      AmityRoles(roles: ["moderator", "community-moderator"])));

      _communityNotification.enable([
        storyReactSetting,
        storyCreationSetting,
        storyCommentSetting
      ]).then((value) {
        final behavior = FreedomUIKitBehavior.instance.communityNotificationSettingBehavior;
        if (behavior.onSaveSuccess != null) {
          event.onSuccess();
          return;
        }
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
    final storyReactionEvent = (settings.events
        ?.firstWhere((event) => event is StoryReacted) as StoryReacted?);

    final storyCreationEvent = (settings.events
        ?.firstWhere((event) => event is StoryCreated) as StoryCreated?);

    final storyCommentEvent =
        (settings.events?.firstWhere((event) => event is StoryCommentCreated)
            as StoryCommentCreated?);

    final reactStorySetting = _getRadioButtonSetting(storyReactionEvent);
    final newStorySetting = _getRadioButtonSetting(storyCreationEvent);
    final commentStorySetting = _getRadioButtonSetting(storyCommentEvent);

    emit(state.copyWith(
      reactStorySetting: reactStorySetting,
      newStorySetting: newStorySetting,
      commentStorySetting: commentStorySetting,
      initialReactStorySetting: reactStorySetting,
      initialNewStorySetting: newStorySetting,
      initialCommentStorySetting: commentStorySetting,
      isNewStoryNetworkEnabled: settings.isStoryCreatedEventEnabled(),
      isReactStoryNetworkEnabled: settings.isStoryReactedEventEnabled(),
      isCommentStoryNetworkEnabled: settings.isStoryCommentCreatedEventEnabled(),
    ));
  }
}
