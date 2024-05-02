import 'dart:developer';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:flutter/material.dart';

import '../components/alert_dialog.dart';

class AmityVM extends ChangeNotifier {
  AmityUser? currentamityUser;

  Future<void> login(
      {required String userID, String? displayName, String? authToken}) async {
    log("login with $userID");
    if (authToken == null) {
      log("authToken == null");
      if (displayName != null) {
        await AmityCoreClient.login(userID)
            .displayName(displayName)
            .submit()
            .then((value) async {
          log("success");

          getUserByID(userID);
          currentamityUser = value;
          notifyListeners();
        }).catchError((error, stackTrace) async {
          log("error");

          log(error.toString());
          //        await AmityDialog()
          //            .showAlertErrorDialog(title: "Error!", message: error.toString());
        });
      } else {
        await AmityCoreClient.login(userID).submit().then((value) async {
          log("success");

          currentamityUser = value;
          notifyListeners();
        }).catchError((error, stackTrace) async {
          log("error");

          log(error.toString());
          //        await AmityDialog()
          //            .showAlertErrorDialog(title: "Error!", message: error.toString());
        });
      }
    } else {
      log("authToken is provided");
      if (displayName != null) {
        log("displayName is provided");
        await AmityCoreClient.login(userID)
            .authToken(authToken)
            .displayName(displayName)
            .submit()
            .then((value) async {
          log("success");

          currentamityUser = value;
          notifyListeners();
        }).catchError((error, stackTrace) async {
          log("error");

          log(error.toString());
          //        await AmityDialog()
          //            .showAlertErrorDialog(title: "Error!", message: error.toString());
        });
      } else {
        log("displayName is not provided");
        await AmityCoreClient.login(userID)
            .authToken(authToken)
            .submit()
            .then((value) async {
          log("success");

          getUserByID(userID);
          currentamityUser = value;
          notifyListeners();
        }).catchError((error, stackTrace) async {
          print("error");

          log(error.toString());
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
        log(error.toString());
        await AmityDialog()
            .showAlertErrorDialog(title: "Error!", message: error.toString());
      });
    }
  }

  Future<void> getUserByID(String id) async {
    await AmityCoreClient.newUserRepository().getUser(id).then((user) {
      log("IsGlobalban: ${user.isGlobalBan}");
    }).onError((error, stackTrace) async {
      log(error.toString());
      await AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
    });
  }

  late Function(AmityPost) onShareButtonPressed;
  void setShareButtonFunction(
      Function(AmityPost) onShareButtonPressed) {} // Callback function)
}
