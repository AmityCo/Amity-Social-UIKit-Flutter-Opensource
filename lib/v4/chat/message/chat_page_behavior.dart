import 'package:amity_uikit_beta_service/v4/utils/amity_image_viewer.dart';
import 'package:flutter/material.dart';

class AmityChatPageBehavior {
  /// Called when user taps on avatar in chat page header
  /// By default, opens image viewer to show enlarged avatar
  /// Override this method to customize behavior (e.g., navigate to user profile)
  /// 
  /// [avatarUrl] - The URL of the user's avatar image
  /// [userId] - The ID of the user
  void onAvatarTap(
    BuildContext context,
    String? avatarUrl,
    String? userId,
  ) {
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AmityImageViewer(
            imageUrl: "$avatarUrl?size=large",
          ),
        ),
      );
    }
  }
}
