part of 'community_story_notification_setting_page_bloc.dart';

class CommunityStoryNotificationSettingPageState extends Equatable {
  final RadioButtonSetting reactStorySetting;
  final RadioButtonSetting newStorySetting;
  final RadioButtonSetting commentStorySetting;
  final RadioButtonSetting initialReactStorySetting;
  final RadioButtonSetting initialNewStorySetting;
  final RadioButtonSetting initialCommentStorySetting;
  final bool settingsChanged;
  final bool isNewStoryNetworkEnabled;
  final bool isReactStoryNetworkEnabled;
  final bool isCommentStoryNetworkEnabled;

  CommunityStoryNotificationSettingPageState({
    this.reactStorySetting = RadioButtonSetting.everyone,
    this.newStorySetting = RadioButtonSetting.everyone,
    this.commentStorySetting = RadioButtonSetting.everyone,
    this.initialReactStorySetting = RadioButtonSetting.everyone,
    this.initialNewStorySetting = RadioButtonSetting.everyone,
    this.initialCommentStorySetting = RadioButtonSetting.everyone,
    this.settingsChanged = false,
    this.isNewStoryNetworkEnabled = false,
    this.isReactStoryNetworkEnabled = false,
    this.isCommentStoryNetworkEnabled = false,
  });

  CommunityStoryNotificationSettingPageState copyWith({
    RadioButtonSetting? reactStorySetting,
    RadioButtonSetting? newStorySetting,
    RadioButtonSetting? commentStorySetting,
    RadioButtonSetting? initialReactStorySetting,
    RadioButtonSetting? initialNewStorySetting,
    RadioButtonSetting? initialCommentStorySetting,
    bool? settingsChanged,
    bool? isNewStoryNetworkEnabled,
    bool? isReactStoryNetworkEnabled,
    bool? isCommentStoryNetworkEnabled,
  }) {
    return CommunityStoryNotificationSettingPageState(
      reactStorySetting: reactStorySetting ?? this.reactStorySetting,
      newStorySetting: newStorySetting ?? this.newStorySetting,
      commentStorySetting: commentStorySetting ?? this.commentStorySetting,
      initialReactStorySetting: initialReactStorySetting ?? this.initialReactStorySetting,
      initialNewStorySetting: initialNewStorySetting ?? this.initialNewStorySetting,
      initialCommentStorySetting: initialCommentStorySetting ?? this.initialCommentStorySetting,
      settingsChanged: settingsChanged ?? this.settingsChanged,
      isNewStoryNetworkEnabled: isNewStoryNetworkEnabled ?? this.isNewStoryNetworkEnabled,
      isReactStoryNetworkEnabled: isReactStoryNetworkEnabled ?? this.isReactStoryNetworkEnabled,
      isCommentStoryNetworkEnabled: isCommentStoryNetworkEnabled ?? this.isCommentStoryNetworkEnabled,
    );
  }

  @override
  List<Object> get props => [
        reactStorySetting,
        newStorySetting,
        commentStorySetting,
        initialReactStorySetting,
        initialNewStorySetting,
        initialCommentStorySetting,
        settingsChanged,
        isNewStoryNetworkEnabled,
        isReactStoryNetworkEnabled,
        isCommentStoryNetworkEnabled,
      ];
}