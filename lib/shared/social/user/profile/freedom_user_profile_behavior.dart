import 'package:flutter/material.dart';
import 'package:amity_uikit_beta_service/freedom_uikit_behavior.dart';

class FreedomUserProfileBehavior {
  /// Custom Me Page builder function - override this in your own repo
  Widget Function({
    required String userId,
    required Widget avatar,
    bool? isEnableAppbar,
    Widget? customActions,
    Widget? customProfile,
    Widget? customHeader,
    String? avatarUrl,
    String rarity,
  })? buildMePage;

  /// Initialize the behavior with default values
  FreedomUserProfileBehavior() {
    // Default implementation - should be overridden in your own repo
    buildMePage = null;
  }

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

  /// Get custom me page - returns null by default
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
    // If custom buildMePage is provided (from your main project), use it
    if (buildMePage != null && avatar != null) {
      return buildMePage!(
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

    // Default implementation - return null to use standard Amity me page
    return null;
  }

  Widget? buildDefaultMePage({
    required String userId,
    required Widget avatar,
    bool? isEnableAppbar,
    Widget? customActions,
    Widget? customProfile,
    Widget? customHeader,
    String? avatarUrl,
    String rarity = "Common",
  }) {
    // Default implementation - return null to use standard Amity me page
    // Custom implementations should be done in your own repo by overriding buildMePage
    return null;
  }
}
