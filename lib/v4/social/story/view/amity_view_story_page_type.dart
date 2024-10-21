abstract class AmityViewStoryPageType {}

class AmityViewStoryCommunityFeed extends AmityViewStoryPageType {
  String communityId;
  AmityViewStoryCommunityFeed({required this.communityId});
}

class AmityViewStoryGlobalFeed extends AmityViewStoryPageType {
  String communityId;
  AmityViewStoryGlobalFeed({required this.communityId});
}
