part of 'user_video_feed_bloc.dart';

abstract class UserVideoFeedEvent extends Equatable {
  const UserVideoFeedEvent();

  @override
  List<Object> get props => [];
}

class UserVideoFeedEventPostUpdated extends UserVideoFeedEvent {
  final List<AmityPost> posts;
  final UserFeedEmptyStateType? emptyState;

  const UserVideoFeedEventPostUpdated({required this.posts, this.emptyState});

  @override
  List<Object> get props => [posts];
}

class UserVideoFeedEventAnnouncementUpdated extends UserVideoFeedEvent {
  final List<AmityPinnedPost> announcements;

  const UserVideoFeedEventAnnouncementUpdated({required this.announcements});

  @override
  List<Object> get props => [announcements];
}

class UserVideoFeedEventPinUpdated extends UserVideoFeedEvent {
  final List<AmityPinnedPost> pins;

  const UserVideoFeedEventPinUpdated({required this.pins});

  @override
  List<Object> get props => [pins];
}

class UserVideoFeedEventLoadingStateUpdated extends UserVideoFeedEvent {
  final bool isLoading;

  const UserVideoFeedEventLoadingStateUpdated({required this.isLoading});

  @override
  List<Object> get props => [isLoading];
}

class UserVideoFeedEventJoinedStateUpdated extends UserVideoFeedEvent {
  final bool isJoined;

  const UserVideoFeedEventJoinedStateUpdated({required this.isJoined});

  @override
  List<Object> get props => [isJoined];
}
