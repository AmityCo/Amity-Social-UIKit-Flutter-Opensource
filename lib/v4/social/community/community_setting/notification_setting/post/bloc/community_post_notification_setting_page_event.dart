part of 'community_post_notification_setting_page_bloc.dart';

class CommunityPostNotificationSettingPageEvent extends Equatable {
  const CommunityPostNotificationSettingPageEvent();

  @override
  List<Object> get props => [];
}

class CommunityPostNotificationSettingChangedEvent
    extends CommunityPostNotificationSettingPageEvent {
  RadioButtonSetting reactPostSetting;
  RadioButtonSetting newPostSetting;

  CommunityPostNotificationSettingChangedEvent({
    required this.reactPostSetting,
    required this.newPostSetting,
  });

  @override
  List<Object> get props => [reactPostSetting, newPostSetting];
}

class CommunityPostNotificationSettingSaveEvent extends CommunityPostNotificationSettingPageEvent {
  final AmityToastBloc toastBloc;
  final Function onSuccess;

  const CommunityPostNotificationSettingSaveEvent(this.toastBloc, this.onSuccess);

  @override
  List<Object> get props => [onSuccess, toastBloc];
}
