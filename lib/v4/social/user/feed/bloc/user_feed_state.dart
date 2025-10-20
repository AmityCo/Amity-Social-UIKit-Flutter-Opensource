part of 'user_feed_bloc.dart';

class UserFeedState extends Equatable {
  final List<AmityPost> posts;
  final bool isLoading;
  final UserFeedEmptyStateType? emptyState;

  const UserFeedState({
    this.posts = const [],
    this.isLoading = false,
    this.emptyState,
  });

  @override
  List<Object?> get props => [posts, isLoading, emptyState];

  UserFeedState copyWith({
    List<AmityPost>? posts,
    bool? isLoading,
    UserFeedEmptyStateType? emptyState,
  }) {
    return UserFeedState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      emptyState: emptyState ?? this.emptyState,
    );
  }
}
