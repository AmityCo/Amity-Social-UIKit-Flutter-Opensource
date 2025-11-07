import 'package:amity_uikit_beta_service/v4/utils/amity_image_viewer.dart';
import 'package:flutter/material.dart';

class AmityMessageBubbleBehavior {
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
