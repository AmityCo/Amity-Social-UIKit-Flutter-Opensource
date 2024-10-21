part of 'global_feed_bloc.dart';

@immutable
abstract class GlobalFeedEvent {}

class GlobalFeedInit extends GlobalFeedEvent {}

class GlobalFeedNotify extends GlobalFeedEvent {
  final List<AmityPost> posts;

  GlobalFeedNotify({required this.posts});
}

class GlobalFeedAddLocalPost extends GlobalFeedEvent {
  final AmityPost post;

  GlobalFeedAddLocalPost({required this.post});
}

class GlobalFeedFetch extends GlobalFeedEvent {}

class GlobalFeedFetched extends GlobalFeedEvent {
  final List<AmityPost> list;

  GlobalFeedFetched({required this.list});
}

class GlobalFeedError extends GlobalFeedEvent {
  final String message;

  GlobalFeedError({required this.message});
}

class GlobalFeedRefresh extends GlobalFeedEvent {}

class GlobalFeedReactToPost extends GlobalFeedEvent {
  final AmityPost post;
  final String reactionType;

  GlobalFeedReactToPost({required this.post, required this.reactionType});
}

class GlobalFeedReloadThePost extends GlobalFeedEvent {
  final AmityPost post;

  GlobalFeedReloadThePost({ required this.post });
}
