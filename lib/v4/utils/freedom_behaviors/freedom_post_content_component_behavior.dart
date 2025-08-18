import 'package:amity_sdk/amity_sdk.dart';
import 'package:flutter/material.dart';

class FreedomPostContentComponentBehavior {
  bool getIsCreatedByAdmin(AmityPost post) => false;

  String? getCommunityAvatarUrl(AmityPost post) => null;

  String getCommunityDisplayName(AmityPost post) => '';

  bool getIsCommunityDeleted(AmityPost post) => false;

  String? getUserPublicProfile(AmityPost post) => null;

  List<Widget> buildTitleWidget(
    AmityPost post,
    Widget targetWidget,
    Widget verifiedWidget,
  ) =>
      [const SizedBox.shrink()];
}
