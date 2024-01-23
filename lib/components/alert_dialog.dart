import 'package:amity_uikit_beta_service/components/custom_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/navigation_key.dart';

class AmityDialog {
  var isshowDialog = true;

  Future<void> showAlertErrorDialog(
      {required String title, required String message}) async {
    bool isbarrierDismissible() {
      if (title.toLowerCase().contains("error")) {
        return true;
      } else {
        return false;
      }
    }

    if (isshowDialog) {
      await showDialog(
        barrierDismissible: isbarrierDismissible(),
        context: NavigationService.navigatorKey.currentContext!,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        ),
      );
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
    return showDialog<void>(
      context: NavigationService.navigatorKey.currentContext!,
      barrierColor: Colors.transparent,
      barrierDismissible:
          true, // Set to false to prevent dismissing by tapping outside
      builder: (context) {
        loadingContext = context;
        return Center(
          child: SizedBox(
            width: 200,
            child: Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0, // Remove shadow/elevation effect
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.all(16.0),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CupertinoActivityIndicator(
                      color: Colors.white,
                      radius: 20,
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Loading",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
    print("Hide Loading!");
    print(_isDialogShowing);
    if (_isDialogShowing) {
      print("close...");
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
    // if (context == null) {
    //   print("Context is null, cannot show dialog");
    //   return Future.value();
    // }

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

class ConfirmationDialog {
  Future<void> show({
    required BuildContext context,
    required String title,
    required String detailText,
    String leftButtonText = 'Cancel',
    String rightButtonText = 'Confirm',
    required Function onConfirm,
  }) async {
    return showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoTheme(
          data: const CupertinoThemeData(brightness: Brightness.dark),
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
