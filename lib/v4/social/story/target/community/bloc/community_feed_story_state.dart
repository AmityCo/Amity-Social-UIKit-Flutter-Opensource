part of 'community_feed_story_bloc.dart';

class CommunityFeedStoryState {
  List<AmityStory>? stories;
  AmityStoryTarget? storyTarget;
  bool haveStoryPermission = false;
  AmityCommunity? community;
  bool isEventSubscribed;
  bool isLoading = true;
  CommunityFeedStoryState(
      {this.stories,
      this.isEventSubscribed = false,
      this.storyTarget,
      this.isLoading = true,
      this.haveStoryPermission = false,
      this.community});

  copywith({
    List<AmityStory>? stories,
    AmityStoryTarget? storyTarget,
    bool? haveStoryPermission,
    AmityCommunity? community,
    bool? isLoading,
    bool? isEventSubscribed,
  }) {
    return CommunityFeedStoryState(
        stories: stories ?? this.stories,
        isLoading: isLoading ?? this.isLoading,
        storyTarget: storyTarget ?? this.storyTarget,
        community: community ?? this.community,
        isEventSubscribed: isEventSubscribed ?? this.isEventSubscribed,
        haveStoryPermission: haveStoryPermission ?? this.haveStoryPermission);
  }
}
