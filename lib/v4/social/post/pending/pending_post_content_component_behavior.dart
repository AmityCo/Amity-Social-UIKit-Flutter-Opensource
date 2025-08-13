import 'package:amity_uikit_beta_service/v4/social/user/profile/amity_user_profile_page.dart';
import 'package:flutter/material.dart';

class AmityPendingPostContentComponentBehavior {
  
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

  Widget Function(
    BuildContext context, {
    VoidCallback? onPressed,
    required bool isApprovingPost,
  })? buildPostAcceptButton;

  Widget Function(
    BuildContext context, {
    VoidCallback? onPressed,
    required bool isDecliningPost,
  })? buildPostDeclineButton;
}
