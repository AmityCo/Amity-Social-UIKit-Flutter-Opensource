import 'dart:developer';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/components/alert_dialog.dart';
import 'package:flutter/material.dart';

class FollowerVM extends ChangeNotifier {
  var _followRelationships = <AmityFollowRelationship>[];
  List<AmityFollowRelationship> get getFollowRelationships =>
      _followRelationships;

  ScrollController? scrollController;

  late PagingController<AmityFollowRelationship> _followerController;

  Future<void> getFollowingListof({required String userId}) async {}

  Future<void> getFollowerListOf({
    required String userId,
  }) async {
    log("getFollowerListOf....");
    if (AmityCoreClient.getUserId() == userId) {
      _followerController = PagingController(
        pageFuture: (token) => AmityCoreClient.newUserRepository()
            .relationship()
            .me()
            .getFollowers()
            .status(AmityFollowStatusFilter.ACCEPTED)
            .getPagingData(token: token, limit: 20),
        pageSize: 20,
      )..addListener(listener);
    } else {
      _followerController = PagingController(
        pageFuture: (token) => AmityCoreClient.newUserRepository()
            .relationship()
            .user(userId)
            .getFollowers()
            .status(AmityFollowStatusFilter.ACCEPTED)
            .getPagingData(token: token, limit: 20),
        pageSize: 20,
      )..addListener(listener);
    }
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _followerController.fetchNextPage();
    });

    if (scrollController != null) {
      _followerController.addListener((() {
        if ((scrollController!.position.pixels ==
                scrollController!.position.maxScrollExtent) &&
            _followerController.hasMoreItems) {
          _followerController.fetchNextPage();
        }
      }));
    }

    //inititate the PagingController
    if (AmityCoreClient.getUserId() == userId) {
      await AmityCoreClient.newUserRepository()
          .relationship()
          .me()
          .getFollowers()
          .status(AmityFollowStatusFilter.ACCEPTED)
          .getPagingData()
          .then((value) {
        log("getFollowerListOf....Successs");
        _followRelationships = value.data;
      }).onError((error, stackTrace) {
        AmityDialog()
            .showAlertErrorDialog(title: "Error!", message: error.toString());
      });
    } else {
      await AmityCoreClient.newUserRepository()
          .relationship()
          .user(userId)
          .getFollowers()
          .status(AmityFollowStatusFilter.ACCEPTED)
          .getPagingData()
          .then((value) {
        log("getFollowerListOf....Successs");
        scrollController = ScrollController();
        _followRelationships = value.data;
      }).onError((error, stackTrace) {
        AmityDialog()
            .showAlertErrorDialog(title: "Error!", message: error.toString());
      });
    }
    notifyListeners();
  }

  Future<void> followUser({required String userId}) async {}

  Future<void> unFollowUser({required String userId}) async {}

  Future<void> getPendingRequest() async {}

  Future<void> acceptFollowRequest(
      {required AmityFollowRelationship amityFollowRelationship}) async {}

  Future<void> rejectFollowRequest(
      {required AmityFollowRelationship amityFollowRelationship}) async {}

  Function listener() {
    return () {
      if (_followerController.error == null) {
        //handle _followerController, we suggest to clear the previous items
        //and add with the latest _controller.loadedItems
        _followRelationships.clear();

        _followRelationships.addAll(_followerController.loadedItems);
        //update widgets
      } else {
        //error on pagination controller
        //update widgets
      }
    };
  }
}
