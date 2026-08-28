import 'package:amity_sdk/amity_sdk.dart';

/// Gating rules for the story-create affordances, kept in one place so every
/// entry point agrees. Mirrors Android, which applies the same rule at each of
/// its five call sites.

/// The network-level "allow all users to create stories" setting.
bool isAllowAllUserToCreateStory() {
  if (!AmityCoreClient.isUserLoggedIn()) return false;
  return AmitySocialClient.getStorySettings()?.allowAllUserToCreateStory ??
      false;
}

/// Community-scoped rule:
/// `(allowAllUserToCreateStory || hasManageStoryPermission) && isJoined`.
///
/// Membership is required regardless of either flag, so a non-member is never
/// granted the create affordance.
bool canCreateStoryInCommunity({
  required bool hasManageStoryPermission,
  required bool isJoined,
  bool? allowAllUsers,
}) {
  final allowAll = allowAllUsers ?? isAllowAllUserToCreateStory();
  return (allowAll || hasManageStoryPermission) && isJoined;
}

/// Whether the given community grants the current user story creation.
bool canCreateStoryInCommunityObject(AmityCommunity? community,
    {bool? allowAllUsers}) {
  final communityId = community?.communityId;
  if (communityId == null) return false;
  final hasManagePermission =
      AmityCoreClient.hasPermission(AmityPermission.MANAGE_COMMUNITY_STORY)
          .atCommunity(communityId)
          .check();
  return canCreateStoryInCommunity(
    hasManageStoryPermission: hasManagePermission,
    isJoined: community?.isJoined ?? false,
    allowAllUsers: allowAllUsers,
  );
}

/// Rule for the community-agnostic social home create menu. There is no
/// community in scope here, so the permission is checked at global scope
/// instead of being combined with membership. Follows Android; iOS keys off the
/// setting alone, which hides the entry from global moderators whenever the
/// setting is off.
bool canCreateStoryFromSocialHome() {
  if (!AmityCoreClient.isUserLoggedIn()) return false;
  if (isAllowAllUserToCreateStory()) return true;
  return AmityCoreClient.hasPermission(AmityPermission.MANAGE_COMMUNITY_STORY)
      .atGlobal()
      .check();
}
