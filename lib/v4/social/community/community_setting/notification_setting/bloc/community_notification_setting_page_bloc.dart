import 'package:amity_uikit_beta_service/freedom_uikit_behavior.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_setting/notification_setting/community_notification_setting_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:amity_sdk/amity_sdk.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'community_notification_setting_page_event.dart';
part 'community_notification_setting_page_state.dart';

class CommunityNotificationSettingPageBloc extends Bloc<
    CommunityNotificationSettingPageEvent,
    CommunityNotificationSettingPageState> {
  late AmityCommunityNotification _communityNotification;
  AmityCommunityNotificationSettings? notificationSettings;

  get _behavior => FreedomUIKitBehavior.instance.communityNotificationSettingBehavior;

  CommunityNotificationSettingPageBloc(AmityCommunity community,
      AmityCommunityNotificationSettings? notificationSettings)
      : super(CommunityNotificationSettingPageState()) {
    _communityNotification =
        AmityCommunityNotification(community.communityId ?? '');

    if (notificationSettings != null) {
      emit(state.copyWith(
          isNotificaitonEnabled: notificationSettings.isEnabled ?? false,
          isPostNetworkEnabled: notificationSettings.isPostNetworkEnabled(),
          isCommentNetworkEnabled:
              notificationSettings.isCommentNetworkEnabled(),
          isStoryNetworkEnabled: notificationSettings.isStoryNetworkEnabled()));
    } else {
      _communityNotification.getSettings().then((settings) {
        emit(state.copyWith(
            isNotificaitonEnabled: settings.isEnabled ?? false,
            isPostNetworkEnabled: settings.isPostNetworkEnabled(),
            isCommentNetworkEnabled: settings.isCommentNetworkEnabled(),
            isStoryNetworkEnabled: settings.isStoryNetworkEnabled()));
      });
    }

    on<CommunityNotificationSettingToggleEvent>((event, emit) async {
      if (event.isNotificationEnabled) {
        await _communityNotification.enable([]);
      } else {
        await _communityNotification.disable();
      }
      final toggleMute = _behavior.toggleMute;
      if (toggleMute != null) {
        await toggleMute(community, event.isNotificationEnabled);
      }
      emit(state.copyWith(isNotificaitonEnabled: event.isNotificationEnabled));
    });
  }
}
