import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UserModerationConfirmationHandler {
  BuildContext context;
  AmityThemeColor theme;

  UserModerationConfirmationHandler({
    required this.context,
    required this.theme,
  });

  void askConfirmationToBlockUser(
      {required String displayName, required Function onConfirm}) {
    showDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text("Block user?"),
          content: Text(
              "$displayName won't be able to see posts and comments that you've created. They won't be notified that you've blocked them."),
          actions: [
            CupertinoDialogAction(
              child: Text(
                "Cancel",
                style: AmityTextStyle.body(theme.highlightColor),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: Text(
                "Block",
                style: AmityTextStyle.bodyBold(theme.alertColor),
              ),
              onPressed: () {
                Navigator.pop(context);

                onConfirm();
              },
            ),
          ],
        );
      },
    );
  }

  void askConfirmationToUnblockUser(
      {required String displayName, required Function onConfirm}) {
    showDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text("Unblock user?"),
          content: Text(
              "$displayName will now be able to see posts and comments that you've created. They won't be notified that you've unblocked them."),
          actions: [
            CupertinoDialogAction(
              child: Text(
                "Cancel",
                style: AmityTextStyle.body(theme.highlightColor),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: Text(
                "Unblock",
                style: AmityTextStyle.bodyBold(theme.alertColor),
              ),
              onPressed: () {
                Navigator.pop(context);

                onConfirm();
              },
            ),
          ],
        );
      },
    );
  }

  void askConfirmationToUnfollowUser({required Function onConfirm}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text("Unfollow this user?"),
          content: const Text(
              "If you change your mind, you'll have to request to follow them again."),
          actions: [
            CupertinoDialogAction(
              child: Text(
                "Cancel",
                style: AmityTextStyle.body(theme.highlightColor),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: Text(
                "Unfollow",
                style: AmityTextStyle.bodyBold(theme.alertColor),
              ),
              onPressed: () {
                Navigator.pop(context);

                onConfirm();
              },
            ),
          ],
        );
      },
    );
  }
}
