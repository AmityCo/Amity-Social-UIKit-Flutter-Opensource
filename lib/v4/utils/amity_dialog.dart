import 'dart:io';

import 'package:amity_uikit_beta_service/components/custom_dialog.dart';
import 'package:amity_uikit_beta_service/utils/navigation_key.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class AmityV4Dialog {
  var isShowDialog = true;

  Future<void> showAlertErrorDialog({
    required String title,
    required String message,
  }) async {
    bool isBarrierDismissible() {
      return title.toLowerCase().contains("error");
    }

    if (isShowDialog) {
      final BuildContext? context =
          NavigationService.navigatorKey.currentContext;
      if (context != null) {
        if (Platform.isIOS) {
          // Use CupertinoAlertDialog for iOS
          await showCupertinoDialog(
            barrierDismissible: isBarrierDismissible(),
            context: context,
            builder: (BuildContext context) {
              return CupertinoAlertDialog(
                title: Text(title),
                content: Text(message),
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
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
                    child: const Text('OK'),
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
    String leftButtonText = 'Cancel',
    String rightButtonText = 'Confirm',
    required Function onConfirm,
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
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red, // Set the text color
                ),
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
                  textStyle: const TextStyle(color: Colors.red),
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
