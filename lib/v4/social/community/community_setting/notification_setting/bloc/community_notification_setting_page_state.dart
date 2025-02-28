part of 'community_notification_setting_page_bloc.dart';

class CommunityNotificationSettingPageState extends Equatable {
  CommunityNotificationSettingPageState();

  bool isNotificaitonEnabled = false;
  bool isPostNetworkEnabled = false;
  bool isCommentNetworkEnabled = false;
  bool isStoryNetworkEnabled = false;

  CommunityNotificationSettingPageState copyWith({
    bool? isNotificaitonEnabled,
    bool? isPostNetworkEnabled,
    bool? isCommentNetworkEnabled,
    bool? isStoryNetworkEnabled,
  }) {
    return CommunityNotificationSettingPageState()
      ..isNotificaitonEnabled =
          isNotificaitonEnabled ?? this.isNotificaitonEnabled
      ..isPostNetworkEnabled =
          isPostNetworkEnabled ?? this.isPostNetworkEnabled
      ..isCommentNetworkEnabled =
          isCommentNetworkEnabled ?? this.isCommentNetworkEnabled
      ..isStoryNetworkEnabled =
          isStoryNetworkEnabled ?? this.isStoryNetworkEnabled;
  }

  @override
  List<Object> get props => [isNotificaitonEnabled, isPostNetworkEnabled, isCommentNetworkEnabled, isStoryNetworkEnabled];
}
