import 'package:flutter/material.dart';
import 'package:amity_uikit_beta_service/freedom_uikit_behavior.dart';

/// Backward compatibility behavior for user profile page
class AmityUserProfilePageBehavior {
  /// Show user edit actions - delegates to the new behavior system
  void showUserEditActions(
    BuildContext context,
    String userId, {
    VoidCallback? onTappedEditProfile,
  }) {
    // Delegate to the new Bitazza behavior
    FreedomUIKitBehavior.instance.userProfileBehavior.showUserEditActions(
      context,
      userId,
      onTappedEditProfile: onTappedEditProfile,
    );
  }

  /// Get custom me page - delegates to the new behavior system
  Widget? getSocialMePage(
    BuildContext context,
    String userId, {
    Widget? avatar,
    String? avatarUrl,
    String? rarity,
    Widget? customActions,
    Widget? customProfile,
    Widget? customHeader,
    bool? isEnableAppbar,
  }) {
    final behavior = FreedomUIKitBehavior.instance.userProfileBehavior;
    
    if (behavior.buildMePage != null && avatar != null) {
      return behavior.buildMePage!(
        userId: userId,
        avatar: avatar,
        avatarUrl: avatarUrl,
        rarity: rarity ?? "Common",
        customActions: customActions,
        customProfile: customProfile,
        customHeader: customHeader,
        isEnableAppbar: isEnableAppbar,
      );
    }

    // Return default implementation if avatar is provided
    if (avatar != null) {
      return behavior.buildDefaultMePage(
        userId: userId,
        avatar: avatar,
        avatarUrl: avatarUrl,
        rarity: rarity ?? "Common",
        customActions: customActions,
        customProfile: customProfile,
        customHeader: customHeader,
        isEnableAppbar: isEnableAppbar,
      );
    }

    return null;
  }

}
