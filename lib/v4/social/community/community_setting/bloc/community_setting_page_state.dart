part of 'community_setting_page_bloc.dart';

// ignore: must_be_immutable
class CommunitySettingPageState extends Equatable {
  CommunitySettingPageState();

  AmityCommunityNotificationSettings? notificationSettings;
  bool shouldShowEditProfile = false;
  bool shouldShowNotificationSetting = false;
  bool isNotificationEnabled = false;
  bool shouldShowPostPermission = false;
  bool shouldShowStoryComments = false;
  bool shouldShowCloseCommunity = false;
  bool shouldShowLeaveCommunity = false;

  @override
  List<Object?> get props => [
        notificationSettings,
        shouldShowEditProfile,
        shouldShowNotificationSetting,
        isNotificationEnabled,
        shouldShowPostPermission,
        shouldShowStoryComments,
        shouldShowCloseCommunity,
        shouldShowLeaveCommunity,
      ];

  CommunitySettingPageState copyWith({
    AmityCommunityNotificationSettings? notificationSettings,
    bool? shouldShowEditProfile,
    bool? shouldShowNotificationSetting,
    bool? isNotificationEnabled,
    bool? shouldShowPostPermission,
    bool? shouldShowStoryComments,
    bool? shouldShowCloseCommunity,
    bool? shouldShowLeaveCommunity,
  }) {
    return CommunitySettingPageState()
      ..notificationSettings = notificationSettings ?? this.notificationSettings
      ..shouldShowEditProfile = shouldShowEditProfile ?? this.shouldShowEditProfile
      ..shouldShowNotificationSetting = shouldShowNotificationSetting ?? this.shouldShowNotificationSetting
      ..isNotificationEnabled = isNotificationEnabled ?? this.isNotificationEnabled
      ..shouldShowPostPermission = shouldShowPostPermission ?? this.shouldShowPostPermission
      ..shouldShowStoryComments = shouldShowStoryComments ?? this.shouldShowStoryComments
      ..shouldShowCloseCommunity = shouldShowCloseCommunity ?? this.shouldShowCloseCommunity
      ..shouldShowLeaveCommunity = shouldShowLeaveCommunity ?? this.shouldShowLeaveCommunity;
  }
}
