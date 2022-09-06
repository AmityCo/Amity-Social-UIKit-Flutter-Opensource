import 'dart:developer';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:flutter/material.dart';

import '../components/alert_dialog.dart';

class AmityVM extends ChangeNotifier {
  AmityUser? currentamityUser;
  bool isProcessing = false;
  Future<void> login(String userID) async {
    if (!isProcessing) {
      isProcessing = true;

      log("login with $userID");

      await AmityCoreClient.login(userID).submit().then((value) async {
        log("success");
        isProcessing = false;
        getUserByID(userID);
        currentamityUser = value;
        notifyListeners();
      }).catchError((error, stackTrace) async {
        isProcessing = false;
        log(error.toString());
        await AmityDialog()
            .showAlertErrorDialog(title: "Error!", message: error.toString());
      });
    } else {
      /// processing
      log("processing login...");
    }
  }

  void setProcessing(bool isProcessing) {
    this.isProcessing = isProcessing;
    notifyListeners();
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
}
