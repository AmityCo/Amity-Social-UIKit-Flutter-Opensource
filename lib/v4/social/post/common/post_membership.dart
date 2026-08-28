import 'package:amity_sdk/amity_sdk.dart';

/// Whether the post belongs to a community the current user has not joined.
///
/// Mirrors native: iOS `post.targetCommunity?.isJoined ?? true` and Android
/// `(post.getTarget() as? Target.COMMUNITY)?.getCommunity()?.isJoined() == false`.
/// Posts without a community target (user feed) are always interactable.
bool isNonMemberCommunityPost(AmityPost post) {
  final target = post.target;
  if (target is! CommunityTarget) return false;
  return target.targetCommunity?.isJoined == false;
}
