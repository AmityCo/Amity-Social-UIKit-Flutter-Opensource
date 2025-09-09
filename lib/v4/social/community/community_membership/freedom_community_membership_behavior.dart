import 'package:amity_sdk/amity_sdk.dart';

class FreedomCommunityMembershipBehavior {
  bool Function(AmityCommunityMember member) noFreedomAdminMember = (_) => true;

  bool Function(AmityUser member) noFreedomAdminUser = (_) => true;

  bool showRemoveFromCommunity() => true;

  Future<void> Function(
    AmityCommunity community,
    AmityCommunityMember member,
  )? promoteUser;

  Future<void> Function(
    AmityCommunity community,
    AmityCommunityMember member,
  )? demoteUser;
}
