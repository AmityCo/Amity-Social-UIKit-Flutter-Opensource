part of 'community_post_permission_page_bloc.dart';

class CommunityPostPermissionPageState extends Equatable {
  final RadioButtonSetting postPermissionSetting;
  final RadioButtonSetting initialPostPermissionSetting;
  final bool settingsChanged;

  CommunityPostPermissionPageState({
    this.postPermissionSetting = RadioButtonSetting.everyone,
    this.initialPostPermissionSetting = RadioButtonSetting.everyone,
    this.settingsChanged = false,
  });

  CommunityPostPermissionPageState copyWith({
    RadioButtonSetting? postPermissionSetting,
    RadioButtonSetting? initialPostPermissionSetting,
    bool? settingsChanged,
  }) {
    return CommunityPostPermissionPageState(
      postPermissionSetting:
          postPermissionSetting ?? this.postPermissionSetting,
      initialPostPermissionSetting:
          initialPostPermissionSetting ?? this.initialPostPermissionSetting,
      settingsChanged: settingsChanged ?? this.settingsChanged,
    );
  }

  @override
  List<Object> get props => [
        postPermissionSetting,
        initialPostPermissionSetting,
        settingsChanged,
      ];
}
