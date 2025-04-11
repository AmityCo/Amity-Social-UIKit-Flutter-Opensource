part of 'community_media_feed_bloc.dart';

class CommunityMediaFeedEvent extends Equatable {
  const CommunityMediaFeedEvent();

  @override
  List<Object> get props => [];
}

class CommunityMediaFeedEventPostUpdated extends CommunityMediaFeedEvent {
  final List<AmityPost> posts;

  const CommunityMediaFeedEventPostUpdated({required this.posts});

  @override
  List<Object> get props => [posts];
}

class CommunityMediaFeedEventLoadingStateUpdated
    extends CommunityMediaFeedEvent {
  final bool isLoading;

  const CommunityMediaFeedEventLoadingStateUpdated({required this.isLoading});

  @override
  List<Object> get props => [isLoading];
}
