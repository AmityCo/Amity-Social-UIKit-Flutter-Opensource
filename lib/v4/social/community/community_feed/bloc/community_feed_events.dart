part of 'community_feed_bloc.dart';

abstract class CommunityFeedEvent extends Equatable {
  const CommunityFeedEvent();

  @override
  List<Object> get props => [];
}

class CommunityFeedEventPostUpdated extends CommunityFeedEvent {
  final List<AmityPost> posts;

  const CommunityFeedEventPostUpdated({required this.posts});

  @override
  List<Object> get props => [posts];
}

class CommunityFeedEventAnnouncementUpdated extends CommunityFeedEvent {
  final List<AmityPinnedPost> announcements;

  const CommunityFeedEventAnnouncementUpdated({required this.announcements});

  @override
  List<Object> get props => [announcements];
}

class CommunityFeedEventPinUpdated extends CommunityFeedEvent {
  final List<AmityPinnedPost> pins;

  const CommunityFeedEventPinUpdated({required this.pins});

  @override
  List<Object> get props => [pins];
}

class CommunityFeedEventLoadingStateUpdated extends CommunityFeedEvent {
  final bool isLoading;

  const CommunityFeedEventLoadingStateUpdated({required this.isLoading});

  @override
  List<Object> get props => [isLoading];
}

class CommunityFeedEventJoinedStateUpdated extends CommunityFeedEvent {
  final bool isJoined;

  const CommunityFeedEventJoinedStateUpdated({required this.isJoined});

  @override
  List<Object> get props => [isJoined];
}
