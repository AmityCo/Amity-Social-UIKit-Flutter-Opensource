part of 'community_media_feed_bloc.dart';

class CommunityMediaFeedState extends Equatable {
  final List<AmityPost> posts;
  final bool isLoading;

  const CommunityMediaFeedState({
    this.posts = const [],
    this.isLoading = false,
  });

  @override
  List<Object?> get props => [posts, isLoading];

  CommunityMediaFeedState copyWith({
    List<AmityPost>? posts,
    bool? isLoading,
  }) {
    return CommunityMediaFeedState(
        posts: posts ?? this.posts, isLoading: isLoading ?? this.isLoading);
  }
}
