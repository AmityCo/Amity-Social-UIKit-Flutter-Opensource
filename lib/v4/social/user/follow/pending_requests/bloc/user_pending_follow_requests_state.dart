part of 'user_pending_follow_requests_bloc.dart';

class UserPendingFollowRequestsState extends Equatable {
  final List<AmityFollowRelationship> users; // Replace it with actual request
  final bool isLoading;

  const UserPendingFollowRequestsState({
    this.users = const [],
    this.isLoading = false,
  });

  @override
  List<Object?> get props => [users, isLoading];

  UserPendingFollowRequestsState copyWith({
    List<AmityFollowRelationship>? users,
    bool? isLoading,
  }) {
    return UserPendingFollowRequestsState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
