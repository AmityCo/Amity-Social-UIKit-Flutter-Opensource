import 'package:amity_uikit_beta_service/v4/social/community/community_creation/community_setup_page.dart';
import 'package:amity_uikit_beta_service/v4/social/post/amity_post_content_component.dart';
import 'package:amity_uikit_beta_service/v4/social/post/post_detail/amity_post_detail_page.dart';
import 'package:amity_uikit_beta_service/v4/social/user/profile/amity_user_profile_page.dart';
import 'package:flutter/material.dart';

class AmityGlobalFeedComponentBehavior {
  void goToPostDetailPage(
    BuildContext context,
    String id,
    {AmityPostCategory category = AmityPostCategory.general}
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AmityPostDetailPage(
          postId: id,
          category: category,
        ),
      ),
    );
  }

  void goToCreateCommunityPage(
    BuildContext context,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AmityCommunitySetupPage(
          mode: const CreateMode(),
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
}