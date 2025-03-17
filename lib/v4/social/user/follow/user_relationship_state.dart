part of 'user_relationship_bloc.dart';

class UserRelationshipState extends Equatable {
  final List<AmityFollowRelationship> followUsers; // Replace it with SDK Model
  final bool isLoading;

  const UserRelationshipState({
    this.followUsers = const [],
    this.isLoading = false,
  });

  @override
  List<Object?> get props => [followUsers, isLoading];

  UserRelationshipState copyWith({
    List<AmityFollowRelationship>? followUsers,
    bool? isLoading,
  }) {
    return UserRelationshipState(
      followUsers: followUsers ?? this.followUsers,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
