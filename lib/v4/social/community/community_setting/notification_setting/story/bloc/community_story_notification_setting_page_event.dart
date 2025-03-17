part of 'community_story_notification_setting_page_bloc.dart';

class CommunityStoryNotificationSettingPageEvent extends Equatable {
  const CommunityStoryNotificationSettingPageEvent();

  @override
  List<Object> get props => [];
}

class CommunityStoryNotificationSettingChangedEvent
    extends CommunityStoryNotificationSettingPageEvent {
  RadioButtonSetting reactStorySetting;
  RadioButtonSetting newStorySetting;
  RadioButtonSetting commentStorySetting;

  CommunityStoryNotificationSettingChangedEvent({
    required this.reactStorySetting,
    required this.newStorySetting,
    required this.commentStorySetting,
  });

  @override
  List<Object> get props => [reactStorySetting, newStorySetting, commentStorySetting];
}

class CommunityStoryNotificationSettingSaveEvent extends CommunityStoryNotificationSettingPageEvent {
  final AmityToastBloc toastBloc;
  final Function onSuccess;

  const CommunityStoryNotificationSettingSaveEvent(this.toastBloc, this.onSuccess);

  @override
  List<Object> get props => [onSuccess, toastBloc];
}