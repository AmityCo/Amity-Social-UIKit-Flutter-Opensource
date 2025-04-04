import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/social/community/profile/amity_community_profile_page.dart';
import 'package:amity_uikit_beta_service/v4/social/post_composer_page/post_composer_model.dart';
import 'package:amity_uikit_beta_service/v4/social/post_composer_page/post_composer_page.dart';
import 'package:amity_uikit_beta_service/v4/social/user/profile/amity_user_profile_page.dart';
import 'package:flutter/material.dart';

class AmityPostContentComponentBehavior {
  void goToCommunityProfilePage(
    BuildContext context,
    String communityId,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AmityCommunityProfilePage(
          communityId: communityId,
        ),
      ),
    );
  }

  void goToUserProfilePage(
    BuildContext context,
    String userId,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AmityUserProfilePage(
          userId: userId,
        ),
      ),
    );
  }

  void goToPostComposerPage(
    BuildContext context,
    AmityPost post,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AmityPostComposerPage(
          options: AmityPostComposerOptions.editOptions(post: post),
        ),
      ),
    );
  }
}
