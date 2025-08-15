import 'package:amity_sdk/amity_sdk.dart';
import 'package:flutter/material.dart';

class FreedomPostContentComponentBehavior {
  bool isCreatedByAdmin(AmityPost post) => false;

  String? communityAvatarUrl(AmityPost post) => null;

  String communityDisplayName(AmityPost post) => '';

  bool isCommunityDeleted(AmityPost post) => false;

  List<Widget> buildTitleWidget(
    AmityPost post,
    Widget targetWidget,
    Widget verifiedWidget,
  ) =>
      [const SizedBox.shrink()];
}
