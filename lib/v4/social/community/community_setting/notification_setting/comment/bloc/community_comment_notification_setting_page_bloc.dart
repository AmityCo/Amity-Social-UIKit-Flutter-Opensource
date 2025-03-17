import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/amity_uikit_toast.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_setting/notification_setting/community_notification_setting_extension.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_setting/notification_setting/element/setting_radio_button.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_setting/notification_setting/post/bloc/community_post_notification_setting_page_bloc.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'community_comment_notification_setting_page_event.dart';
part 'community_comment_notification_setting_page_state.dart';

class CommunityCommentNotificationSettingPageBloc extends Bloc<
    CommunityCommentNotificationSettingPageEvent,
    CommunityCommentNotificationSettingPageState> {
  late AmityCommunity community;
  late AmityCommunityNotification _communityNotification;
  AmityCommunityNotificationSettings? notificationSettings;

  CommunityCommentNotificationSettingPageBloc(AmityCommunity community,
      AmityCommunityNotificationSettings? notificationSettings)
      : super(CommunityCommentNotificationSettingPageState()) {
    _communityNotification =
        AmityCommunityNotification(community.communityId ?? '');

    if (notificationSettings != null) {
      _emitInitialState(notificationSettings);
    } else {
      _communityNotification.getSettings().then((settings) {
        _emitInitialState(settings);
      });
    }

    on<CommunityCommentNotificationSettingChangedEvent>((event, emit) {
      final settingsChanged =
          state.initialReactCommentSetting != event.reactCommentSetting ||
              state.initialNewCommentSetting != event.newCommentSetting ||
              state.initialReplyCommentSetting != event.replyCommentSetting;
      emit(state.copyWith(
        reactCommentSetting: event.reactCommentSetting,
        newCommentSetting: event.newCommentSetting,
        replyCommentSetting: event.replyCommentSetting,
        settingsChanged: settingsChanged,
      ));
    });

    on<CommunityCommentNotificationSettingSaveEvent>((event, emit) async {
      final commentReactSetting =
          state.reactCommentSetting == RadioButtonSetting.off
              ? CommentReacted.disable()
              : state.reactCommentSetting == RadioButtonSetting.everyone
                  ? CommentReacted.enable(All())
                  : CommentReacted.enable(Only(
                      AmityRoles(roles: ["moderator", "community-moderator"])));
      final commentCreationSetting =
          state.newCommentSetting == RadioButtonSetting.off
              ? CommentCreated.disable()
              : state.newCommentSetting == RadioButtonSetting.everyone
                  ? CommentCreated.enable(All())
                  : CommentCreated.enable(Only(
                      AmityRoles(roles: ["moderator", "community-moderator"])));
      final replyCommentSetting =
          state.replyCommentSetting == RadioButtonSetting.off
              ? CommentReplied.disable()
              : state.replyCommentSetting == RadioButtonSetting.everyone
                  ? CommentReplied.enable(All())
                  : CommentReplied.enable(Only(
                      AmityRoles(roles: ["moderator", "community-moderator"])));

      _communityNotification.enable([
        commentReactSetting,
        commentCreationSetting,
        replyCommentSetting
      ]).then((value) {
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
    final commentReactionEvent = (settings.events
        ?.firstWhere((event) => event is CommentReacted) as CommentReacted?);

    final commentCreationEvent = (settings.events
        ?.firstWhere((event) => event is CommentCreated) as CommentCreated?);

    final commentReplyEvent = (settings.events
        ?.firstWhere((event) => event is CommentReplied) as CommentReplied?);

    final reactCommentSetting = _getRadioButtonSetting(commentReactionEvent);
    final newCommentSetting = _getRadioButtonSetting(commentCreationEvent);
    final replyCommentSetting = _getRadioButtonSetting(commentReplyEvent);

    emit(state.copyWith(
        reactCommentSetting: reactCommentSetting,
        newCommentSetting: newCommentSetting,
        replyCommentSetting: replyCommentSetting,
        initialReactCommentSetting: reactCommentSetting,
        initialNewCommentSetting: newCommentSetting,
        initialReplyCommentSetting: replyCommentSetting,
        isReactCommentNetworkEnabled: settings.isCommentReactedEventEnabled(),
        isNewCommentNetworkEnabled: settings.isCommentCreatedEventEnabled(),
        isReplyCommentNetworkEnabled: settings.isCommentRepliedEventEnabled() 
        ));
  }
}
