import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
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
      builder: (dialogContext) {
        return CupertinoAlertDialog(
          title: Text(context.l10n.user_block_confirm_title),
          content: Text(context.l10n.user_block_confirm_description(displayName)),
          actions: [
            CupertinoDialogAction(
              child: Text(
                context.l10n.general_cancel,
                style: AmityTextStyle.body(theme.highlightColor),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            CupertinoDialogAction(
              child: Text(
                context.l10n.user_block_confirm_button,
                style: AmityTextStyle.bodyBold(theme.alertColor),
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
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
      builder: (dialogContext) {
        return CupertinoAlertDialog(
          title: Text(context.l10n.user_unblock_confirm_title),
          content: Text(context.l10n.user_unblock_confirm_description(displayName)),
          actions: [
            CupertinoDialogAction(
              child: Text(
                context.l10n.general_cancel,
                style: AmityTextStyle.body(theme.highlightColor),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            CupertinoDialogAction(
              child: Text(
                context.l10n.user_unblock_confirm_button,
                style: AmityTextStyle.bodyBold(theme.alertColor),
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
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
      builder: (dialogContext) {
        return CupertinoAlertDialog(
          title: Text(context.l10n.user_unfollow_confirm_title),
          content: Text(context.l10n.user_unfollow_confirm_description),
          actions: [
            CupertinoDialogAction(
              child: Text(
                context.l10n.general_cancel,
                style: AmityTextStyle.body(theme.highlightColor),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            CupertinoDialogAction(
              child: Text(
                context.l10n.user_unfollow_confirm_button,
                style: AmityTextStyle.bodyBold(theme.alertColor),
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
                onConfirm();
              },
            ),
          ],
        );
      },
    );
  }
}