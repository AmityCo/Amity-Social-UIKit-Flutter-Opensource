part of 'community_post_permission_page_bloc.dart';

class CommunityPostPermissionPageState extends Equatable {
  final PostPermissionSetting postPermissionSetting;
  final PostPermissionSetting initialPostPermissionSetting;
  final bool settingsChanged;

  CommunityPostPermissionPageState({
    this.postPermissionSetting = PostPermissionSetting.everyoneCanPost,
    this.initialPostPermissionSetting = PostPermissionSetting.everyoneCanPost,
    this.settingsChanged = false,
  });

  CommunityPostPermissionPageState copyWith({
    PostPermissionSetting? postPermissionSetting,
    PostPermissionSetting? initialPostPermissionSetting,
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
