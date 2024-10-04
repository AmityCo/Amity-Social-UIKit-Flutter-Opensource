part of 'community_feed_story_bloc.dart';

class CommunityFeedStoryEvent {}



class CheckMangeStoryPermissionEvent extends CommunityFeedStoryEvent {
  String communityId;
  CheckMangeStoryPermissionEvent({required this.communityId});
}

class ObserveStoryTargetEvent extends CommunityFeedStoryEvent {
  String communityId;
  ObserveStoryTargetEvent({required this.communityId});
}

class OnEventSubscribedEvent extends CommunityFeedStoryEvent {
  OnEventSubscribedEvent();
}


class SubscribeToCommunityEvent extends CommunityFeedStoryEvent {
  AmityCommunity community;
  SubscribeToCommunityEvent({required this.community});
}


class NewStoryTargetEvent extends CommunityFeedStoryEvent {
  AmityStoryTarget storyTarget;
  NewStoryTargetEvent({required this.storyTarget});
}

class StoriesFetchedEvent extends CommunityFeedStoryEvent{
  List<AmityStory> stories;
  StoriesFetchedEvent({required this.stories});
}

class FetchStories extends CommunityFeedStoryEvent{
  String communityId;
  FetchStories({required this.communityId});
}



