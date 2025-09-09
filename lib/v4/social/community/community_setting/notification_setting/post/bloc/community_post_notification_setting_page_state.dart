part of 'community_post_notification_setting_page_bloc.dart';

class CommunityPostNotificationSettingPageState extends Equatable {
  CommunityPostNotificationSettingPageState();

  bool isReactPostNetworkEnabled = false;
  bool isNewPostNetworkEnabled = false;
  RadioButtonSetting reactPostSetting = RadioButtonSetting.everyone;
  RadioButtonSetting newPostSetting = RadioButtonSetting.everyone;
  RadioButtonSetting initialReactPostSetting = RadioButtonSetting.everyone;
  RadioButtonSetting initialNewPostSetting = RadioButtonSetting.everyone;

  bool settingsChanged = false;
  bool isLoading = false;

  copyWith(
      {RadioButtonSetting? reactPostSetting,
      RadioButtonSetting? newPostSetting,
      RadioButtonSetting? initialReactPostSetting,
      RadioButtonSetting? initialNewPostSetting,
      bool? isReactPostNetworkEnabled,
      bool? isNewPostNetworkEnabled,
      bool settingsChanged = false,
      bool? isLoading = false}) {
    return CommunityPostNotificationSettingPageState()
      ..reactPostSetting = reactPostSetting ?? this.reactPostSetting
      ..newPostSetting = newPostSetting ?? this.newPostSetting
      ..initialNewPostSetting =
          initialNewPostSetting ?? this.initialNewPostSetting
      ..initialReactPostSetting =
          initialReactPostSetting ?? this.initialReactPostSetting
      ..isReactPostNetworkEnabled =
          isReactPostNetworkEnabled ?? this.isReactPostNetworkEnabled
      ..isNewPostNetworkEnabled =
          isNewPostNetworkEnabled ?? this.isNewPostNetworkEnabled
      ..settingsChanged = settingsChanged
      ..isLoading = isLoading ?? this.isLoading;
  }

  @override
  List<Object> get props => [
        reactPostSetting,
        newPostSetting,
        settingsChanged,
        initialNewPostSetting,
        initialReactPostSetting,
        isReactPostNetworkEnabled,
        isNewPostNetworkEnabled,
        isLoading
      ];
}
