part of 'community_feed_bloc.dart';

class CommunityFeedState extends Equatable {
  final List<AmityPost> posts;
  final List<AmityPinnedPost> announcements;
  final List<AmityPinnedPost> pins;
  final bool isLoading;
  final bool isJoined;

  CommunityFeedState({
    this.posts = const [],
    this.announcements = const [],
    this.pins = const [],
    this.isLoading = false,
    this.isJoined = true,
  });

  @override
  List<Object?> get props => [posts, announcements, pins, isLoading, isJoined];

  CommunityFeedState copyWith({
    List<AmityPost>? posts,
    List<AmityPinnedPost>? announcements,
    List<AmityPinnedPost>? pins,
    bool? isLoading,
    bool? isJoined,
  }) {
    return CommunityFeedState(
      posts: posts ?? this.posts,
      announcements: announcements ?? this.announcements,
      pins: pins ?? this.pins,
      isLoading: isLoading ?? this.isLoading,
      isJoined: isJoined ?? this.isJoined,
    );
  }
}
