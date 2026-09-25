import 'dart:io';

import 'package:amity_uikit_beta_service/v4/core/ui/custom_dialog.dart';
import 'package:amity_uikit_beta_service/v4/utils/navigation_key.dart';
import 'package:amity_uikit_beta_service/v4/core/theme/amity_color_token.dart';
import 'package:amity_uikit_beta_service/v4/core/config_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class AmityV4Dialog {
  var isShowDialog = true;

  Future<void> showAlertErrorDialog({
    required String title,
    required String message,
    required String closeText,
  }) async {
    bool isBarrierDismissible() {
      return title.toLowerCase().contains("error");
    }

    if (isShowDialog) {
      final BuildContext? context =
          NavigationService.navigatorKey.currentContext;
      if (context != null) {
        if (Platform.isIOS) {
          // CupertinoAlertDialog paints itself from CupertinoTheme, which the
          // UIKit never sets, so without this wrapper it stays on the light iOS
          // surface over a dark app (PDT-5022). ConfirmationV4Dialog and
          // PermissionAlertV4Dialog below already wrap; this one was missed.
          //
          // The mode comes from the UIKit's own resolved theme rather than the
          // OS brightness those two read: a host that pins preferred_theme gets
          // a dark app on a light phone, and the dialog has to follow the app.
          // In light mode this resolves to Brightness.light, which is what the
          // unwrapped dialog already rendered — so light mode is unchanged.
          final brightness = ConfigRepository().isDarkTheme
              ? Brightness.dark
              : Brightness.light;
          await showCupertinoDialog(
            barrierDismissible: isBarrierDismissible(),
            context: context,
            builder: (BuildContext context) {
              return CupertinoTheme(
                data: CupertinoThemeData(brightness: brightness),
                child: CupertinoAlertDialog(
                  title: Text(title),
                  content: Text(message),
                  actions: <Widget>[
                    CupertinoDialogAction(
                      child: Text(
                        closeText,
                        style: const TextStyle(color: Color(0xFF007AFF)),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              );
            },
          );
        } else {
          // Use AlertDialog for Android and other platforms
          await showDialog(
            barrierDismissible: isBarrierDismissible(),
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(title),
                content: Text(message),
                actions: <Widget>[
                  TextButton(
                    child: Text(closeText),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      }
    }
  }
}

class AmityV4SuccessDialog {
  static Future<void> showTimedDialog(String text,
      {BuildContext? context}) async {
    showCupertinoDialog<void>(
      context: context ?? NavigationService.navigatorKey.currentContext!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return TimedDialog(
          text: text,
        );
      },
    );
  }
}

class ConfirmationV4Dialog {
  Future<void> show({
    required BuildContext context,
    required String title,
    required String detailText,
    // Defaults to the product's alert colour rather than Material's raw red
    // (#F44336) — eleven call sites rely on this default, including the
    // delete-message popup PDT-5100 case 4 names.
    Color? leftButtonColor,
    String leftButtonText = 'Cancel',
    String rightButtonText = 'Confirm',
    required Function onConfirm,
  }) async {
    // Resolved before the platform split so both branches get the same colour;
    // iOS previously fell back to Material's red too, so this keeps the two in
    // step rather than leaving one on a raw framework value.
    leftButtonColor ??=
        ConfigRepository().resolveToken(null, AmityColorToken.textBaseAlert);

    // Check the platform
    if (Platform.isAndroid) {
      // Android-specific code
      final resolve = ConfigRepository().resolveToken;
      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          // This used to wrap the dialog in a stock `ThemeData.dark()`, so its
          // surface, title, message and dismiss label all came from Material's
          // baseline rather than the UIKit — measured on a Pixel as a #2B2930
          // sheet with a #D0BCFF dismiss label, which is the M3 dark primary
          // and nothing to do with this product (PDT-5100 case 4, Android).
          // Every colour is bound explicitly now, so no ambient theme decides
          // any of them.
          return AlertDialog(
            backgroundColor:
                resolve(null, AmityColorToken.surfaceAlertDialogBackgroundDefault),
            title: Text(
              title,
              style: TextStyle(
                  color: resolve(
                      null, AmityColorToken.textAlertDialogHeaderTitleDefault)),
            ),
            content: Text(
              detailText,
              style: TextStyle(
                  color:
                      resolve(null, AmityColorToken.textAlertDialogBodyDefault)),
            ),
            actions: <Widget>[
              TextButton(
                // The dismiss side had no colour at all — this is the button
                // QA saw in Material's purple.
                style: TextButton.styleFrom(
                    foregroundColor: resolve(
                        null, AmityColorToken.textAlertDialogBodyDefault)),
                child: Text(leftButtonText),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onConfirm();
                },
                // `leftButtonColor` colours the *confirm* action, which is what
                // all 17 call sites pass it for (highlight to promote, alert to
                // ban or remove). The name is a misnomer kept for compatibility.
                style: TextButton.styleFrom(foregroundColor: leftButtonColor),
                child: Text(rightButtonText),
              ),
            ],
          );
        },
      );
    } else if (Platform.isIOS) {
      // iOS-specific code
      final systemBrightness =
          SchedulerBinding.instance.platformDispatcher.platformBrightness;

      return showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoTheme(
            data: CupertinoThemeData(brightness: systemBrightness),
            child: CupertinoAlertDialog(
              title: Text(title),
              content: Text(detailText),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text(leftButtonText),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                ),
                CupertinoDialogAction(
                  textStyle: TextStyle(color: leftButtonColor),
                  onPressed: () {
                    Navigator.of(context).pop();
                    onConfirm();
                  },
                  isDefaultAction: true,
                  child: Text(rightButtonText),
                ),
              ],
            ),
          );
        },
      );
    }
  }
}

class PermissionAlertV4Dialog {
  Future<void> show({
    required BuildContext context,
    required String title,
    required String detailText,
    String bottomButtonText = 'Cancel',
    String topButtonText = 'Confirm',
    required Function onTopButtonAction,
  }) async {
    // Check the platform
    if (Platform.isAndroid) {
      // Android-specific code
      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(detailText),
            actions: <Widget>[
              TextButton(
                child: Text(bottomButtonText),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onTopButtonAction();
                },
                child: Text(topButtonText),
              ),
            ],
          );
        },
      );
    } else if (Platform.isIOS) {
      // iOS-specific code
      final systemBrightness =
          SchedulerBinding.instance.platformDispatcher.platformBrightness;

      return showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoTheme(
            data: CupertinoThemeData(brightness: systemBrightness),
            child: CupertinoAlertDialog(
              title: Text(title),
              content: Text(detailText),
              actions: <Widget>[
                Container(
                  color: CupertinoColors.systemGrey, // Color of the divider
                ),
                CupertinoDialogAction(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onTopButtonAction();
                  },
                  isDefaultAction: true,
                  child: Text(
                    topButtonText,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                    ),
                  ),
                ),
                Container(
                  color: CupertinoColors.systemGrey, // Color of the divider
                ),
                CupertinoDialogAction(
                  child: Text(
                    bottomButtonText,
                    style: const TextStyle(
                      fontSize: 17,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                ),
              ],
            ),
          );
        },
      );
    }
  }
}