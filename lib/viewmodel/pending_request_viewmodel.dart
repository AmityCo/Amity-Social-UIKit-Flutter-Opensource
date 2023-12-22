import 'dart:developer';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:flutter/material.dart';

import '../components/alert_dialog.dart';

class PendingVM extends ChangeNotifier {
  var _pendingList = <AmityFollowRelationship>[];
  List<AmityFollowRelationship> get pendingRequestList => _pendingList;

  ScrollController? scrollController;

  late PagingController<AmityFollowRelationship> _pendingListController;

  Future<void> getMyPendingRequestList() async {
    log("getMyFollowingList....");

    _pendingListController = PagingController(
      pageFuture: (token) => AmityCoreClient.newUserRepository()
          .relationship()
          .me()
          .getFollowers()
          .status(AmityFollowStatusFilter.PENDING)
          .getPagingData(token: token, limit: 20),
      pageSize: 20,
    )..addListener(listener);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _pendingListController.fetchNextPage();
    });

    if (scrollController != null) {
      _pendingListController.addListener((() {
        if ((scrollController!.position.pixels ==
                scrollController!.position.maxScrollExtent) &&
            _pendingListController.hasMoreItems) {
          _pendingListController.fetchNextPage();
        }
      }));
    }

    await AmityCoreClient.newUserRepository()
        .relationship()
        .me()
        .getFollowers()
        .status(AmityFollowStatusFilter.PENDING)
        .getPagingData()
        .then((value) {
      log("getFollowerListOf....Successs");
      _pendingList = value.data;
    }).onError((error, stackTrace) {
      AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
    });

    notifyListeners();
  }

  Function listener() {
    return () {
      if (_pendingListController.error == null) {
        //handle _followerController, we suggest to clear the previous items
        //and add with the latest _controller.loadedItems
        _pendingList.clear();

        _pendingList.addAll(_pendingListController.loadedItems);
        //update widgets
      } else {
        //error on pagination controller
        //update widgets
      }
    };
  }

  void acceptFollowRequest(String userId, int index) {
    AmityCoreClient.newUserRepository()
        .relationship()
        .me()
        .accept(userId = userId)
        .then((value) {
      //success
      log("acceptFollowRequest: Success");
      _pendingList.removeAt(index);
      notifyListeners();
    }).onError((error, stackTrace) {
      //handle error
      AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
    });
  }

  void declineFollowRequest(String userId, int index) {
    AmityCoreClient.newUserRepository()
        .relationship()
        .me()
        .decline(userId = userId)
        .then((value) {
      //success
      log("declineFollowRequest: Success");
      _pendingList.removeAt(index);
      notifyListeners();
    }).onError((error, stackTrace) {
      //handle error
      AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
    });
  }
}
