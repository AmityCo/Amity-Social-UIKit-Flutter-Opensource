import 'dart:developer';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/components/alert_dialog.dart';
import 'package:flutter/material.dart';

class MyCommunityVM with ChangeNotifier {
  // Existing members...

  final scrollcontroller = ScrollController();
  bool loadingNextPage = false;
  // The list of communities.
  final List<AmityCommunity> _amityCommunities = [];

  // The controller for handling pagination.
  late PagingController<AmityCommunity> _communityController;

  // Getter for _amityCommunities for external classes to use.
  List<AmityCommunity> get amityCommunities => _amityCommunities;
  final textEditingController = TextEditingController();
  Future<void> initMyCommunity([String? keyword]) async {
    _communityController = PagingController(
      pageFuture: (token) {
        final repository = AmitySocialClient.newCommunityRepository()
            .getCommunities()
            .filter(AmityCommunityFilter.MEMBER);
        if (keyword != null && keyword.isNotEmpty) {
          repository.withKeyword(
              keyword); // Add keyword filtering only if keyword is provided and not empty
        }
        return repository.getPagingData(token: token, limit: 20);
      },
      pageSize: 20,
    )..addListener(
        () async {
          if (_communityController.error == null) {
            _amityCommunities.clear();
            _amityCommunities.addAll(_communityController.loadedItems);
            // Call any additional methods like sortedUserListWithHeaders here if needed.
            notifyListeners();
          } else {
            log("error");
            await AmityDialog().showAlertErrorDialog(
                title: "Error!",
                message: _communityController.error.toString());
          }
        },
      );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _communityController.fetchNextPage();
    });

    scrollcontroller.removeListener(() {});
    scrollcontroller.addListener(loadNextPage);
  }

  void loadNextPage() async {
    if ((scrollcontroller.position.pixels >
        scrollcontroller.position.maxScrollExtent - 800)) {
      print("hasMore: ${_communityController.hasMoreItems}");
    }
    if ((scrollcontroller.position.pixels >
            scrollcontroller.position.maxScrollExtent - 800) &&
        _communityController.hasMoreItems &&
        !loadingNextPage) {
      loadingNextPage = true;
      notifyListeners();
      log("loading Next Page...");
      // Call any additional methods like sortedUserListWithHeaders here if needed.
      await _communityController.fetchNextPage().then((value) {
        loadingNextPage = false;
        notifyListeners();
      });
    }
  }
}
