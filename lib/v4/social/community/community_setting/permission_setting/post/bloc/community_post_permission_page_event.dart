part of 'community_post_permission_page_bloc.dart';

class CommunityPostPermissionPageEvent extends Equatable {
  const CommunityPostPermissionPageEvent();

  @override
  List<Object> get props => [];
}

class CommunityPostPermissionSettingChangedEvent
    extends CommunityPostPermissionPageEvent {
  final RadioButtonSetting postPermissionSetting;

  CommunityPostPermissionSettingChangedEvent({
    required this.postPermissionSetting,
  });

  @override
  List<Object> get props => [postPermissionSetting];
}

class CommunityPostPermissionSettingSaveEvent
    extends CommunityPostPermissionPageEvent {
  final AmityToastBloc toastBloc;
  final Function onSuccess;

  const CommunityPostPermissionSettingSaveEvent(this.toastBloc, this.onSuccess);

  @override
  List<Object> get props => [onSuccess, toastBloc];
}
