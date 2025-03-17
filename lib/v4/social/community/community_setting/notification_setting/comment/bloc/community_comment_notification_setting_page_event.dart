part of 'community_comment_notification_setting_page_bloc.dart';

class CommunityCommentNotificationSettingPageEvent extends Equatable {
  const CommunityCommentNotificationSettingPageEvent();

  @override
  List<Object> get props => [];
}

class CommunityCommentNotificationSettingChangedEvent
    extends CommunityCommentNotificationSettingPageEvent {
  RadioButtonSetting reactCommentSetting;
  RadioButtonSetting newCommentSetting;
  RadioButtonSetting replyCommentSetting;

  CommunityCommentNotificationSettingChangedEvent({
    required this.reactCommentSetting,
    required this.newCommentSetting,
    required this.replyCommentSetting,
  });

  @override
  List<Object> get props => [reactCommentSetting, newCommentSetting, replyCommentSetting];
}

class CommunityCommentNotificationSettingSaveEvent extends CommunityCommentNotificationSettingPageEvent {
  final AmityToastBloc toastBloc;
  final Function onSuccess;

  const CommunityCommentNotificationSettingSaveEvent(this.toastBloc, this.onSuccess);

  @override
  List<Object> get props => [onSuccess, toastBloc];
}