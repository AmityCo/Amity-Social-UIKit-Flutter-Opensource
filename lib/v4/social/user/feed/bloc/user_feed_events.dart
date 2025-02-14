part of 'user_feed_bloc.dart';

abstract class UserFeedEvent extends Equatable {
  const UserFeedEvent();

  @override
  List<Object> get props => [];
}

class UserFeedEventPostUpdated extends UserFeedEvent {
  final List<AmityPost> posts;
  final UserFeedEmptyStateType? emptyState;

  const UserFeedEventPostUpdated({required this.posts, this.emptyState});

  @override
  List<Object> get props => [posts];
}

class UserFeedEventAnnouncementUpdated extends UserFeedEvent {
  final List<AmityPinnedPost> announcements;

  const UserFeedEventAnnouncementUpdated({required this.announcements});

  @override
  List<Object> get props => [announcements];
}

class UserFeedEventPinUpdated extends UserFeedEvent {
  final List<AmityPinnedPost> pins;

  const UserFeedEventPinUpdated({required this.pins});

  @override
  List<Object> get props => [pins];
}

class UserFeedEventLoadingStateUpdated extends UserFeedEvent {
  final bool isLoading;

  const UserFeedEventLoadingStateUpdated({required this.isLoading});

  @override
  List<Object> get props => [isLoading];
}

class UserFeedEventJoinedStateUpdated extends UserFeedEvent {
  final bool isJoined;

  const UserFeedEventJoinedStateUpdated({required this.isJoined});

  @override
  List<Object> get props => [isJoined];
}
