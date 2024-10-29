import 'package:amity_sdk/amity_sdk.dart';
import 'package:flutter/material.dart';

import '../components/alert_dialog.dart';

class AmityVM extends ChangeNotifier {
  AmityUser? currentamityUser;

  Future<void> login(
      {required String userID, String? displayName, String? authToken}) async {
    if (authToken == null) {
      if (displayName != null) {
        await AmityCoreClient.login(userID)
            .displayName(displayName)
            .submit()
            .then((value) async {
          currentamityUser = value;
          notifyListeners();
        }).catchError((error, stackTrace) async {
          //        await AmityDialog()
          //            .showAlertErrorDialog(title: "Error!", message: error.toString());
        });
      } else {
        await AmityCoreClient.login(userID).submit().then((value) async {
          currentamityUser = value;
          notifyListeners();
        }).catchError((error, stackTrace) async {
          //        await AmityDialog()
          //            .showAlertErrorDialog(title: "Error!", message: error.toString());
        });
      }
    } else {
      if (displayName != null) {
        await AmityCoreClient.login(userID)
            .authToken(authToken)
            .displayName(displayName)
            .submit()
            .then((value) async {
          currentamityUser = value;
          notifyListeners();
        }).catchError((error, stackTrace) async {
          //        await AmityDialog()
          //            .showAlertErrorDialog(title: "Error!", message: error.toString());
        });
      } else {
        await AmityCoreClient.login(userID)
            .authToken(authToken)
            .submit()
            .then((value) async {
          currentamityUser = value;
          notifyListeners();
        }).catchError((error, stackTrace) async {
          //        await AmityDialog()
          //            .showAlertErrorDialog(title: "Error!", message: error.toString());
        });
      }
    }
  }

  Future<void> refreshCurrentUserData() async {
    if (currentamityUser != null) {
      await AmityCoreClient.newUserRepository()
          .getUser(currentamityUser!.userId!)
          .then((user) {
        currentamityUser = user;
        notifyListeners();
      }).onError((error, stackTrace) async {
        await AmityDialog()
            .showAlertErrorDialog(title: "Error!", message: error.toString());
      });
    }
  }

  late Function(AmityPost) onShareButtonPressed;
  void setShareButtonFunction(
      Function(AmityPost) onShareButtonPressed) {} // Callback function)
}
