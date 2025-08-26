part of 'user_relationship_bloc.dart';

abstract class UserRelationshipEvent extends Equatable {
  const UserRelationshipEvent();

  @override
  List<Object> get props => [];
}

class UserRelationshipLoadingStateUpdated extends UserRelationshipEvent {
  final bool isLoading;

  const UserRelationshipLoadingStateUpdated({required this.isLoading});

  @override
  List<Object> get props => [isLoading];
}

class UserRelationshipUsersUpdated extends UserRelationshipEvent {
  final List<AmityFollowRelationship> users;

  const UserRelationshipUsersUpdated({required this.users});

  @override
  List<Object> get props => [users];
}

class UserRelationshipLoadNextPage extends UserRelationshipEvent {}

/* --- Moderation --- */

enum UserModerationAction { report, unreport, block, unblock, unfollow, follow }

class UserModerationEvent extends UserRelationshipEvent {
  final UserModerationAction action;
  final String userId;
  final AmityToastBloc toastBloc;
  final String successMessage;
  final String errorMessage;

  const UserModerationEvent({
    required this.action,
    required this.userId,
    required this.toastBloc,
    required this.successMessage,
    required this.errorMessage,
  });

  @override
  List<Object> get props => [action, userId, toastBloc];
}
