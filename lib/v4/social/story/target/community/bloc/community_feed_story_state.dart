part of 'community_feed_story_bloc.dart';

class CommunityFeedStoryState {
  List<AmityStory>? stories;
  AmityStoryTarget? storyTarget;
  bool haveStoryPermission = false;
  // Network-level setting: when true, ALL members (not just those with
  // MANAGE_COMMUNITY_STORY) are allowed to create a story. Same "possibly
  // cold cache on first read" characteristic as haveStoryPermission, so it
  // is refreshed on the same recheck cadence - see
  // CommunityFeedStoryBloc._maybeRecheckPermission.
  bool allowAllUserToCreateStory = false;
  // Tracks how many times the permission cache has been (re-)checked so the
  // UI can tell "not yet confirmed" apart from "confirmed false". The very
  // first check runs synchronously against a possibly-cold cache, so a
  // single false reading should not be treated as final.
  int permissionCheckCount = 0;
  AmityCommunity? community;
  bool isEventSubscribed;
  bool isLoading = true;

  /// Whether the permission check has had a fair chance to settle: either it
  /// already resolved to true, or it has been (re-)checked
  /// [CommunityFeedStoryBloc._maxPermissionRecheckCount] times off the back
  /// of real data updates. Until this is true, a `false` reading is
  /// considered provisional and should not be used to permanently hide the
  /// create affordance for a member who may actually have permission.
  bool get permissionResolved =>
      haveStoryPermission ||
      allowAllUserToCreateStory ||
      permissionCheckCount >= CommunityFeedStoryBloc._maxPermissionRecheckCount;

  /// Effective create-story affordance, matching the native rule:
  /// `(allowAllUserToCreateStory || hasManageStoryPermission) && isJoined`.
  /// Membership is required regardless of either flag so a non-member is
  /// never granted the create affordance.
  bool get canCreateStory => canCreateStoryInCommunity(
      hasManageStoryPermission: haveStoryPermission,
      isJoined: community?.isJoined ?? false,
      allowAllUsers: allowAllUserToCreateStory);

  CommunityFeedStoryState(
      {this.stories,
      this.isEventSubscribed = false,
      this.storyTarget,
      this.isLoading = true,
      this.haveStoryPermission = false,
      this.allowAllUserToCreateStory = false,
      this.permissionCheckCount = 0,
      this.community});

  copywith({
    List<AmityStory>? stories,
    AmityStoryTarget? storyTarget,
    bool? haveStoryPermission,
    bool? allowAllUserToCreateStory,
    int? permissionCheckCount,
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
        haveStoryPermission: haveStoryPermission ?? this.haveStoryPermission,
        allowAllUserToCreateStory:
            allowAllUserToCreateStory ?? this.allowAllUserToCreateStory,
        permissionCheckCount:
            permissionCheckCount ?? this.permissionCheckCount);
  }
}
