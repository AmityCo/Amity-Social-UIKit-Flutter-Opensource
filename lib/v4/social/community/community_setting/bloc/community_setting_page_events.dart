part of 'community_setting_page_bloc.dart';

abstract class CommunitySettingPageEvent extends Equatable {
  const CommunitySettingPageEvent();

  @override
  List<Object> get props => [];
}

class CommunityNotificationSettingPageLoadEvent extends CommunitySettingPageEvent {
  
  const CommunityNotificationSettingPageLoadEvent();

  @override
  List<Object> get props => [];
}

class LeaveCommunityEvent extends CommunitySettingPageEvent {
  final AmityToastBloc toastBloc;
  final Function onSuccess;
  final Function onFailure;

  const LeaveCommunityEvent(
      {required this.toastBloc,
      required this.onSuccess,
      required this.onFailure});

  @override
  List<Object> get props => [toastBloc, onSuccess, onFailure];
}

class CloseCommunityEvent extends CommunitySettingPageEvent {
  final AmityToastBloc toastBloc;
  final Function onSuccess;
  final Function onFailure;

  const CloseCommunityEvent(
      {required this.toastBloc,
      required this.onSuccess,
      required this.onFailure});
  
  @override
  List<Object> get props => [toastBloc, onSuccess, onFailure];
}

class CommunityNotificaitonSettingEvent extends CommunitySettingPageEvent {
  final bool isSocialNetworkEnabled;
  final bool isNotificationEnabled;

  const CommunityNotificaitonSettingEvent({
    required this.isSocialNetworkEnabled,
    required this.isNotificationEnabled,
  });

  @override
  List<Object> get props => [isSocialNetworkEnabled, isNotificationEnabled];
}
