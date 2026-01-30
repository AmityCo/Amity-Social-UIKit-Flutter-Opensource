import 'dart:io';

import 'package:amity_uikit_beta_service/components/custom_dialog.dart';
import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:amity_uikit_beta_service/v4/utils/config_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/navigation_key.dart';

class AmityDialog {
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
        // Get theme before showing dialog
        final appTheme = Provider.of<ConfigProvider>(context, listen: false).getTheme(null, null);
        final isDarkMode = appTheme.backgroundColor.computeLuminance() < 0.5;

        if (Platform.isIOS) {
          // Use CupertinoAlertDialog for iOS
          await showCupertinoDialog(
            barrierDismissible: isBarrierDismissible(),
            context: context,
            builder: (BuildContext dialogContext) {
              return CupertinoTheme(
                data: CupertinoThemeData(
                  brightness: isDarkMode ? Brightness.dark : Brightness.light,
                ),
                child: CupertinoAlertDialog(
                  title: Text(
                    title,
                    style: TextStyle(color: appTheme.baseColor),
                  ),
                  content: Text(
                    message,
                    style: TextStyle(color: appTheme.baseColor),
                  ),
                  actions: <Widget>[
                    CupertinoDialogAction(
                      child: Text(dialogContext.l10n.general_ok),
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
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
            builder: (BuildContext dialogContext) {
              return AlertDialog(
                backgroundColor: appTheme.backgroundColor,
                title: Text(
                  title,
                  style: TextStyle(color: appTheme.baseColor),
                ),
                content: Text(
                  message,
                  style: TextStyle(color: appTheme.baseColor),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text(dialogContext.l10n.general_ok),
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
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

class AmityLoadingDialog {
  static BuildContext? loadingContext;
  static bool _isDialogShowing = false;

  static Future<void> showLoadingDialog() {
    print("show AmityLoadingDialog");
    _isDialogShowing = true;
    print("set _isDialogShowing: $_isDialogShowing");
    final context = NavigationService.navigatorKey.currentContext!;
    final appTheme = Provider.of<ConfigProvider>(context, listen: false).getTheme(null, null);
    return showDialog<void>(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible:
          true, // Set to false to prevent dismissing by tapping outside
      builder: (dialogContext) {
        loadingContext = dialogContext;
        return Center(
          child: SizedBox(
            width: 200,
            child: Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0, // Remove shadow/elevation effect
              child: Container(
                decoration: BoxDecoration(
                  color: appTheme.baseColorShade3.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CupertinoActivityIndicator(
                      color: appTheme.baseColor,
                      radius: 20,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      dialogContext.l10n.general_loading,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: appTheme.baseColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ).then((value) => _isDialogShowing = false);
  }

  static void hideLoadingDialog() {
    if (_isDialogShowing) {
      Navigator.of(loadingContext!).pop();

      _isDialogShowing = false;
    }
  }

  static Future<void> runWithLoadingDialog<T>(Future<T> Function() task) async {
    try {
      showLoadingDialog(); // Show the loading dialog
      await task(); // Wait for the passed function to complete
    } catch (e) {
      // Handle any errors here if needed
    } finally {
      hideLoadingDialog(); // Hide the loading dialog
    }
  }
}

class AmitySuccessDialog {
  static Future<void> showTimedDialog(String text,
      {BuildContext? context}) async {
    final ctx = context ?? NavigationService.navigatorKey.currentContext!;
    final appTheme = Provider.of<ConfigProvider>(ctx, listen: false).getTheme(null, null);

    showCupertinoDialog<void>(
      context: ctx,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return TimedDialog(
          text: text,
          backgroundColor: appTheme.backgroundColor,
          textColor: appTheme.baseColor,
        );
      },
    );
  }
}

class ConfirmationDialog {
  Future<void> show({
    required BuildContext context,
    required String title,
    required String detailText,
    String? leftButtonText,
    String? rightButtonText,
    required Function onConfirm,
    Color confrimColor = Colors.red, 
  }) async {
    // Set default localized values
    final String leftBtnText = leftButtonText ?? context.l10n.general_cancel;
    final String rightBtnText = rightButtonText ?? context.l10n.general_confirm;

    // Get theme before showing dialog
    final appTheme = Provider.of<ConfigProvider>(context, listen: false).getTheme(null, null);

    // Check the platform
    if (Platform.isAndroid) {
      // Android-specific code
      return showDialog<void>(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            backgroundColor: appTheme.backgroundColor,
            title: Text(
              title,
              style: TextStyle(color: appTheme.baseColor),
            ),
            content: Text(
              detailText,
              style: TextStyle(color: appTheme.baseColor),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(leftBtnText),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  onConfirm();
                },
                style: TextButton.styleFrom(
                  foregroundColor: confrimColor,
                ),
                child: Text(rightBtnText),
              ),
            ],
          );
        },
      );
    } else if (Platform.isIOS) {
      // iOS-specific code
      final isDarkMode = appTheme.backgroundColor.computeLuminance() < 0.5;
      return showCupertinoDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return CupertinoTheme(
            data: CupertinoThemeData(
              brightness: isDarkMode ? Brightness.dark : Brightness.light,
            ),
            child: CupertinoAlertDialog(
              title: Text(
                title,
                style: TextStyle(color: appTheme.baseColor),
              ),
              content: Text(
                detailText,
                style: TextStyle(color: appTheme.baseColor),
              ),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text(leftBtnText),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                ),
                CupertinoDialogAction(
                  textStyle: TextStyle(color: confrimColor),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    onConfirm();
                  },
                  isDefaultAction: true,
                  child: Text(rightBtnText),
                ),
              ],
            ),
          );
        },
      );
    }
  }
}


class AmityAlertDialogWithThreeActions {
  Future<void> show({
    required BuildContext context,
    required String title,
    required String detailText,
    required String actionOneText,
    required String actionTwoText,
    String? dismissText,
    required Function actionOne,
    required Function actionTwo,
    required Function onDismissRequest,
     Color actionOneColor = Colors.red,
     Color actionTwoColor = Colors.red,
  }) async {
    // Set default localized values
    final String dismissBtnText = dismissText ?? context.l10n.general_cancel;

    // Get theme before showing dialog
    final appTheme = Provider.of<ConfigProvider>(context, listen: false).getTheme(null, null);

    // Check the platform
    if (Platform.isAndroid) {
      // Android-specific code
      return showDialog<void>(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            backgroundColor: appTheme.backgroundColor,
            title: Text(
              title,
              style: TextStyle(color: appTheme.baseColor),
            ),
            content: Text(
              detailText,
              style: TextStyle(color: appTheme.baseColor),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(dismissBtnText),
                onPressed: () {
                  onDismissRequest();
                  Navigator.of(dialogContext).pop();
                },
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  actionOne();
                },
                style: TextButton.styleFrom(
                  foregroundColor: actionOneColor,
                ),
                child: Text(actionOneText),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  actionTwo();
                },
                style: TextButton.styleFrom(
                  foregroundColor: actionTwoColor,
                ),
                child: Text(actionTwoText),
              ),
            ],
          );
        },
      ).then((value){
        onDismissRequest();
      
      });
    } else if (Platform.isIOS) {
      // iOS-specific code
      final isDarkMode = appTheme.backgroundColor.computeLuminance() < 0.5;
      return showCupertinoDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return CupertinoTheme(
            data: CupertinoThemeData(
              brightness: isDarkMode ? Brightness.dark : Brightness.light,
            ),
            child: CupertinoAlertDialog(
              title: Text(
                title,
                style: TextStyle(color: appTheme.baseColor),
              ),
              content: Text(
                detailText,
                style: TextStyle(color: appTheme.baseColor),
              ),
              actions: <Widget>[
                CupertinoDialogAction(
                  textStyle: TextStyle(color: actionOneColor),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    actionOne();
                  },
                  isDefaultAction: true,
                  child: Text(actionOneText),
                ),
                CupertinoDialogAction(
                  textStyle: TextStyle(color: actionTwoColor),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    actionTwo();
                  },
                  isDefaultAction: true,
                  child: Text(actionTwoText),
                ),
                CupertinoDialogAction(
                  child: Text(dismissBtnText),
                  onPressed: () {
                    onDismissRequest();
                    Navigator.of(dialogContext).pop();
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
