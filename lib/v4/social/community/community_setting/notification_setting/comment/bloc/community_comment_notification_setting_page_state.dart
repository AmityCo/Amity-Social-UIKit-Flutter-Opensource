part of 'community_comment_notification_setting_page_bloc.dart';

class CommunityCommentNotificationSettingPageState extends Equatable {
  final RadioButtonSetting reactCommentSetting;
  final RadioButtonSetting newCommentSetting;
  final RadioButtonSetting replyCommentSetting;
  final RadioButtonSetting initialReactCommentSetting;
  final RadioButtonSetting initialNewCommentSetting;
  final RadioButtonSetting initialReplyCommentSetting;
  final bool settingsChanged;
  final bool isReactCommentNetworkEnabled;
  final bool isNewCommentNetworkEnabled;
  final bool isReplyCommentNetworkEnabled;
  final bool isLoading;

  CommunityCommentNotificationSettingPageState({
    this.reactCommentSetting = RadioButtonSetting.everyone,
    this.newCommentSetting = RadioButtonSetting.everyone,
    this.replyCommentSetting = RadioButtonSetting.everyone,
    this.initialReactCommentSetting = RadioButtonSetting.everyone,
    this.initialNewCommentSetting = RadioButtonSetting.everyone,
    this.initialReplyCommentSetting = RadioButtonSetting.everyone,
    this.settingsChanged = false,
    this.isReactCommentNetworkEnabled = false,
    this.isNewCommentNetworkEnabled = false,
    this.isReplyCommentNetworkEnabled = false,
    this.isLoading = false,
  });

  CommunityCommentNotificationSettingPageState copyWith({
    RadioButtonSetting? reactCommentSetting,
    RadioButtonSetting? newCommentSetting,
    RadioButtonSetting? replyCommentSetting,
    RadioButtonSetting? initialReactCommentSetting,
    RadioButtonSetting? initialNewCommentSetting,
    RadioButtonSetting? initialReplyCommentSetting,
    bool? settingsChanged,
    bool? isReactCommentNetworkEnabled,
    bool? isNewCommentNetworkEnabled,
    bool? isReplyCommentNetworkEnabled,
    bool? isLoading,
  }) {
    return CommunityCommentNotificationSettingPageState(
      reactCommentSetting: reactCommentSetting ?? this.reactCommentSetting,
      newCommentSetting: newCommentSetting ?? this.newCommentSetting,
      replyCommentSetting: replyCommentSetting ?? this.replyCommentSetting,
      initialReactCommentSetting:
          initialReactCommentSetting ?? this.initialReactCommentSetting,
      initialNewCommentSetting:
          initialNewCommentSetting ?? this.initialNewCommentSetting,
      initialReplyCommentSetting:
          initialReplyCommentSetting ?? this.initialReplyCommentSetting,
      settingsChanged: settingsChanged ?? this.settingsChanged,
      isReactCommentNetworkEnabled:
          isReactCommentNetworkEnabled ?? this.isReactCommentNetworkEnabled,
      isNewCommentNetworkEnabled:
          isNewCommentNetworkEnabled ?? this.isNewCommentNetworkEnabled,
      isReplyCommentNetworkEnabled:
          isReplyCommentNetworkEnabled ?? this.isReplyCommentNetworkEnabled,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object> get props => [
        reactCommentSetting,
        newCommentSetting,
        initialReactCommentSetting,
        initialNewCommentSetting,
        settingsChanged,
        isReactCommentNetworkEnabled,
        isNewCommentNetworkEnabled,
        isReplyCommentNetworkEnabled,
        isLoading
      ];
}
