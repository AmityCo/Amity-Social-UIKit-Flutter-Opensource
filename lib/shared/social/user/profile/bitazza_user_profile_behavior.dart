import 'package:flutter/material.dart';
import 'bitazza_me_page.dart';

class BitazzaUserProfileBehavior {
  /// Custom Me Page builder function
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

  /// Initialize the behavior with default Me Page builder
  BitazzaUserProfileBehavior() {
    buildMePage = buildDefaultMePage;
  }

  /// Show user edit actions
  void showUserEditActions(
    BuildContext context,
    String userId, {
    VoidCallback? onTappedEditProfile,
  }) {
    try {
      dynamic targetPage;

      context.visitAncestorElements((element) {
        final widget = element.widget;
        final widgetType = widget.runtimeType.toString();

        if (widgetType.contains('BitazzaMePage') ||
            widgetType.contains('AmityUserProfilePage')) {
          targetPage = widget;
          return false;
        }
        return true;
      });

      if (targetPage != null) {
        targetPage.triggerUserEditActions(
          context,
          onTappedEditProfile: onTappedEditProfile,
        );
        return;
      }

      final amityPageState = context.findAncestorStateOfType<State>();
      if (amityPageState != null) {
        final widgetType = amityPageState.widget.runtimeType.toString();
        if (widgetType.contains('BitazzaMePage') ||
            widgetType.contains('AmityUserProfilePage')) {
          (amityPageState as dynamic).triggerUserEditActions(
            context,
            onTappedEditProfile: onTappedEditProfile,
          );
        }
      }
    } catch (e) {
      debugPrint('BitazzaUserProfileBehavior: Error - $e');
    }
  }

  /// Default Me Page builder
  Widget buildDefaultMePage({
    required String userId,
    required Widget avatar,
    bool? isEnableAppbar,
    Widget? customActions,
    Widget? customProfile,
    Widget? customHeader,
    String? avatarUrl,
    String rarity = "Common",
  }) {
    return BitazzaMePage(
      userId: userId,
      avatar: avatar,
      isEnableAppbar: isEnableAppbar,
      customActions: customActions,
      customProfile: customProfile,
      customHeader: customHeader,
      avatarUrl: avatarUrl,
      rarity: rarity,
    );
  }
}