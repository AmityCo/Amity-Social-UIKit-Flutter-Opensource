part of 'community_notification_setting_page_bloc.dart';

class CommunityNotificationSettingPageEvent extends Equatable {
  const CommunityNotificationSettingPageEvent();

  @override
  List<Object> get props => [];
}

class CommunityNotificationSettingToggleEvent extends CommunityNotificationSettingPageEvent {
  final bool isNotificationEnabled;

  CommunityNotificationSettingToggleEvent({required this.isNotificationEnabled});

  @override
  List<Object> get props => [isNotificationEnabled];
}