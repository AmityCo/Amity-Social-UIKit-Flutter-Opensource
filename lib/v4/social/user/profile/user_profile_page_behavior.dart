import 'package:flutter/material.dart';

class AmityUserProfilePageBehavior {
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

        if (widgetType.contains('AmitySocialMePage') ||
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
        if (widgetType.contains('AmitySocialMePage') ||
            widgetType.contains('AmityUserProfilePage')) {
          (amityPageState as dynamic).triggerUserEditActions(
            context,
            null,
            null,
            onTappedEditProfile: onTappedEditProfile,
          );
        }
      }
    } catch (e) {
      debugPrint('AmityUserProfilePageBehavior: Error - $e');
    }
  }
}
