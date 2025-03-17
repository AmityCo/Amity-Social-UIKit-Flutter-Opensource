part of 'user_profile_bloc.dart';

abstract class UserProfileEvent extends Equatable {
  const UserProfileEvent();

  @override
  List<Object> get props => [];
}

class UserProfileEventRefresh extends UserProfileEvent {
  final String userId;

  const UserProfileEventRefresh({required this.userId});

  @override
  List<Object> get props => [userId];
}

class UserProfileEventUpdated extends UserProfileEvent {
  final AmityUser user;

  const UserProfileEventUpdated({required this.user});

  @override
  List<Object> get props => [user];
}

class UserProfileEventTabSelected extends UserProfileEvent {
  final UserProfileTabIndex tab;

  const UserProfileEventTabSelected({required this.tab});

  @override
  List<Object> get props => [tab];
}

class UserMyFollowInfoEventUpdated extends UserProfileEvent {
  final AmityMyFollowInfo myFollowInfo;

  const UserMyFollowInfoEventUpdated({required this.myFollowInfo});

  @override
  List<Object> get props => [myFollowInfo];
}

class UserFollowInfoEventUpdated extends UserProfileEvent {
  final AmityUserFollowInfo userFollowInfo;

  const UserFollowInfoEventUpdated({required this.userFollowInfo});

  @override
  List<Object> get props => [userFollowInfo];
}

class UserProfileUserModerationEvent extends UserProfileEvent {
  final UserModerationAction action;
  final String userId;
  final AmityToastBloc toastBloc;
  final Function onError;

  const UserProfileUserModerationEvent(
      {required this.action,
      required this.userId,
      required this.toastBloc,
      required this.onError});

  @override
  List<Object> get props => [action, userId, toastBloc];
}

class UserFollowInfoFetchEvent extends UserProfileEvent {}

class UserProfileExpandHeaderEvent extends UserProfileEvent {}
