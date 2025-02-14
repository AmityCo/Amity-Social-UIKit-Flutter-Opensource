part of 'user_video_feed_bloc.dart';

class UserVideoFeedState extends Equatable {
  final List<AmityPost> posts;
  final bool isLoading;
  final bool isJoined;
  final UserFeedEmptyStateType? emptyState;

  const UserVideoFeedState({
    this.posts = const [],
    this.isLoading = false,
    this.isJoined = true,
    this.emptyState,
  });

  @override
  List<Object?> get props => [posts, isLoading, isJoined, emptyState];

  UserVideoFeedState copyWith({
    List<AmityPost>? posts,
    bool? isLoading,
    bool? isJoined,
    UserFeedEmptyStateType? emptyState,
  }) {
    return UserVideoFeedState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      isJoined: isJoined ?? this.isJoined,
      emptyState: emptyState ?? this.emptyState,
    );
  }
}
