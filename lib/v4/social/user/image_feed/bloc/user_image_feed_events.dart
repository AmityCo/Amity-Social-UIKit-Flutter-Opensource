part of 'user_image_feed_bloc.dart';

abstract class UserImageFeedEvent extends Equatable {
  const UserImageFeedEvent();

  @override
  List<Object> get props => [];
}

class UserImageFeedEventPostUpdated extends UserImageFeedEvent {
  final List<AmityPost> posts;
  final UserFeedEmptyStateType? emptyState;

  const UserImageFeedEventPostUpdated({required this.posts, this.emptyState});

  @override
  List<Object> get props => [posts];
}

class UserImageFeedEventAnnouncementUpdated extends UserImageFeedEvent {
  final List<AmityPinnedPost> announcements;

  const UserImageFeedEventAnnouncementUpdated({required this.announcements});

  @override
  List<Object> get props => [announcements];
}

class UserImageFeedEventPinUpdated extends UserImageFeedEvent {
  final List<AmityPinnedPost> pins;

  const UserImageFeedEventPinUpdated({required this.pins});

  @override
  List<Object> get props => [pins];
}

class UserImageFeedEventLoadingStateUpdated extends UserImageFeedEvent {
  final bool isLoading;

  const UserImageFeedEventLoadingStateUpdated({required this.isLoading});

  @override
  List<Object> get props => [isLoading];
}

class UserImageFeedEventJoinedStateUpdated extends UserImageFeedEvent {
  final bool isJoined;

  const UserImageFeedEventJoinedStateUpdated({required this.isJoined});

  @override
  List<Object> get props => [isJoined];
}
