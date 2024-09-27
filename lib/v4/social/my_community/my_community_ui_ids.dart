part of 'my_community_component.dart';

enum AmityComponent { myCommunities }

extension AmityComponentExtension on AmityComponent {
  String get stringValue {
    switch (this) {
      case AmityComponent.myCommunities:
        return 'my_communities';
    }
  }
}

enum AmityMyCommunityElement {
  communityAvatar,
  communityDisplayName,
  communityPrivateBadge,
  communityOfficialBadge,
  communityCetegoryName,
  communityMemberCount
}

extension AmityMyCommunityElementExtension on AmityMyCommunityElement {
  String get stringValue {
    switch (this) {
      case AmityMyCommunityElement.communityAvatar:
        return 'community_avatar';
      case AmityMyCommunityElement.communityDisplayName:
        return 'community_display_name';
      case AmityMyCommunityElement.communityPrivateBadge:
        return 'community_private_badge';
      case AmityMyCommunityElement.communityOfficialBadge:
        return 'community_official_badge';
      case AmityMyCommunityElement.communityCetegoryName:
        return 'community_category_name';
      case AmityMyCommunityElement.communityMemberCount:
        return 'community_members_count';
    }
  }
}
