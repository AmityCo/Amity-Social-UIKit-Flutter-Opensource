part of 'global_feed_bloc.dart';

@immutable
abstract class GlobalFeedEvent {}

class GlobalFeedRefresh extends GlobalFeedEvent {}

class GlobalFeedListUpdated extends GlobalFeedEvent {
  final List<AmityPost> posts;

  GlobalFeedListUpdated({required this.posts});
}

class GlobalFeedLoadingStateUpdated extends GlobalFeedEvent {
  final bool isLoading;

  GlobalFeedLoadingStateUpdated({required this.isLoading});
}

class GlobalFeedAddLocalPost extends GlobalFeedEvent {
  final AmityPost post;

  GlobalFeedAddLocalPost({required this.post});
}

class GlobalFeedLocalPostUpdated extends GlobalFeedEvent {
  final AmityPost post;

  GlobalFeedLocalPostUpdated({required this.post});
}

class GlobalFeedLoadNext extends GlobalFeedEvent {}

class GlobalFeedError extends GlobalFeedEvent {
  final String message;

  GlobalFeedError({required this.message});
}