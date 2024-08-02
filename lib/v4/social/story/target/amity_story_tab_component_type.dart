abstract class AmityStoryTabComponentType {}

class CommunityFeedStoryTab extends AmityStoryTabComponentType {
  final String communityId;
  CommunityFeedStoryTab({required this.communityId});
}

class GlobalFeedStoryTab extends AmityStoryTabComponentType {}
