part of 'user_image_feed_bloc.dart';

class UserImageFeedState extends Equatable {
  final List<AmityPost> posts;
  final bool isLoading;
  final bool isJoined;
  final UserFeedEmptyStateType? emptyState;

  const UserImageFeedState({
    this.posts = const [],
    this.isLoading = false,
    this.isJoined = true,
    this.emptyState,
  });

  @override
  List<Object?> get props => [posts, isLoading, isJoined, emptyState];

  UserImageFeedState copyWith({
    List<AmityPost>? posts,
    bool? isLoading,
    bool? isJoined,
    UserFeedEmptyStateType? emptyState,
  }) {
    return UserImageFeedState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      isJoined: isJoined ?? this.isJoined,
      emptyState: emptyState ?? this.emptyState,
    );
  }
}
