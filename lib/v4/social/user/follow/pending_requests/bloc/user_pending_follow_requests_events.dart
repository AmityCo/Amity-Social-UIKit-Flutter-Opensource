part of 'user_pending_follow_requests_bloc.dart';

abstract class UserPendingFollowRequestsEvent extends Equatable {
  const UserPendingFollowRequestsEvent();

  @override
  List<Object> get props => [];
}

class UserPendingFollowRequestsLoadingStateUpdated
    extends UserPendingFollowRequestsEvent {
  final bool isLoading;

  const UserPendingFollowRequestsLoadingStateUpdated({required this.isLoading});

  @override
  List<Object> get props => [isLoading];
}

class UserPendingFollowRequestsUsersUpdated
    extends UserPendingFollowRequestsEvent {
  final List<AmityFollowRelationship> users;

  const UserPendingFollowRequestsUsersUpdated({required this.users});

  @override
  List<Object> get props => [users];
}

class UserPendingFollowRequestsLoadNextPage
    extends UserPendingFollowRequestsEvent {}

/* --- Action --- */

enum UserPendingFollowRequestsAction { accept, decline }

class UserPendingFollowRequestsActionEvent
    extends UserPendingFollowRequestsEvent {
  final UserPendingFollowRequestsAction action;
  final AmityUser? user;
  final AmityToastBloc toastBloc;
  final Function callback;

  const UserPendingFollowRequestsActionEvent(
      {required this.action,
      this.user,
      required this.toastBloc,
      required this.callback});

  @override
  List<Object> get props => [action, toastBloc];
}
