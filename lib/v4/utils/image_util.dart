import 'package:flutter/material.dart';

ImageProvider getAvatarImageFromUrl(String? avatarUrl) {
  if (avatarUrl != null && avatarUrl.isNotEmpty) {
    return NetworkImage(avatarUrl);
  } else {
    return const AssetImage("assets/images/user_placeholder.png",
        package: "amity_uikit_beta_service");
  }
}