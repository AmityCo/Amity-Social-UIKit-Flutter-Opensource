import 'dart:async';
import 'dart:developer';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:flutter/material.dart';

import '../../components/alert_dialog.dart';

enum Feedtype { global, commu }

class FeedVM extends ChangeNotifier {
  final _amityGlobalFeedPosts = <AmityPost>[];
  bool isCustomPostRanking = false;
  bool isLoading = true;
  final scrollcontroller = ScrollController();
  late GlobalFeedLiveCollection globalFeedLiveCollection;
  late CustomRankingLiveCollection customRankingLiveCollection;
  late StreamSubscription<List<AmityPost>> _subscription;

  bool loadingNexPage = false;
  List<AmityPost> get getAmityPosts {
    return _amityGlobalFeedPosts;
  }

  Future<void> addPostToFeed(AmityPost post) async {
    // if (_controllerGlobal == null) {
    //   _controllerGlobal?.addAtIndex(0, post);
    // }
    notifyListeners();
  }

  void deletePost(AmityPost post, int postIndex,
      Function(bool success, String message) callback) async {
    AmitySocialClient.newPostRepository()
        .deletePost(postId: post.postId!)
        .then((value) {
      // Find the post by postId and remove it
      int postIndex =
          _amityGlobalFeedPosts.indexWhere((p) => p.postId == post.postId);
      if (postIndex != -1) {
        _amityGlobalFeedPosts.removeAt(postIndex);
        notifyListeners();
        callback(true, "Post deleted successfully.");
      } else {
        callback(false, "Post not found in the list.");
      }
    }).onError((error, stackTrace) async {
      String errorMessage = error.toString();
      await AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: errorMessage);
      callback(false, errorMessage);
    });
  }

  Future<void> initAmityGlobalfeed({bool isCustomPostRanking = false}) async {
    isCustomPostRanking = isCustomPostRanking;
    isLoading = true;
    print("isloading1: $isLoading");
    print("isCustomPostRanking:$isCustomPostRanking");
    if (isCustomPostRanking) {
      customRankingLiveCollection = AmitySocialClient.newFeedRepository()
          .getCustomRankingGlobalFeed()
          .getLiveCollection();

      _subscription = customRankingLiveCollection
          .getStreamController()
          .stream
          .listen((posts) async {
        if (globalFeedLiveCollection.isFetching == true && posts.isEmpty) {
          isLoading = true;
          notifyListeners();
        } else if (posts.isNotEmpty) {
          _amityGlobalFeedPosts.clear();
          _amityGlobalFeedPosts.addAll(posts);
          isLoading = false;
          notifyListeners();
        }
      });

      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        globalFeedLiveCollection.loadNext();
      });
    } else {
      globalFeedLiveCollection = AmitySocialClient.newFeedRepository()
          .getGlobalFeed()
          .getLiveCollection();

      _subscription = globalFeedLiveCollection
          .getStreamController()
          .stream
          .listen((posts) async {
        if (globalFeedLiveCollection.isFetching == true && posts.isEmpty) {
          isLoading = true;
          notifyListeners();
        } else if (posts.isNotEmpty) {
          _amityGlobalFeedPosts.clear();
          _amityGlobalFeedPosts.addAll(posts);
          isLoading = false;
          notifyListeners();
        }
      });
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        globalFeedLiveCollection.loadNext();
      });
      scrollcontroller.addListener(loadnextpage);
      // if (isCustomPostRanking) {
      //   _controllerGlobal = PagingController(
      //     pageFuture: (token) => AmitySocialClient.newFeedRepository()
      //         .getCustomRankingGlobalFeed()
      //         .getPagingData(token: token, limit: 5),
      //     pageSize: 5,
      //   )..addListener(
      //       () async {
      //         log("getCustomRankingGlobalFeed listener...");
      //         if (_controllerGlobal?.error == null) {
      //           _amityGlobalFeedPosts.clear();
      //           _amityGlobalFeedPosts.addAll(_controllerGlobal!.loadedItems);

      //           isLoading = false;
      //           notifyListeners();
      //         } else {
      //           //Error on pagination controller
      //           isLoading = false;

      //           notifyListeners();
      //           log("error: ${_controllerGlobal!.error.toString()}");
      //           // await AmityDialog().showAlertErrorDialog(
      //           //     title: "Error!",
      //           //     message: _controllerGlobal!.error.toString());
      //         }
      //       },
      //     );
      // } else {
      //   _controllerGlobal = PagingController(
      //     pageFuture: (token) => AmitySocialClient.newFeedRepository()
      //         .getGlobalFeed()
      //         .getPagingData(token: token, limit: 5),
      //     pageSize: 5,
      //   )..addListener(
      //       () async {
      //         log("initAmityGlobalfeed listener...");
      //         if (_controllerGlobal?.error == null) {
      //           _amityGlobalFeedPosts.clear();
      //           _amityGlobalFeedPosts.addAll(_controllerGlobal!.loadedItems);

      //           isLoading = false;
      //           notifyListeners();
      //         } else {
      //           // Handle pagination controller error
      //           log("error: ${_controllerGlobal!.error.toString()}");
      //           notifyListeners();
      //           // Optionally show an error dialog
      //           // await AmityDialog().showAlertErrorDialog(
      //           //   title: "Error!",
      //           //   message: _controllerGlobal!.error.toString());
      //         }
      //         if (_controllerGlobal?.isFetching == false) {
      //           isLoading = false;
      //         }
      //       },
      //     );
      // }

      // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      //   _controllerGlobal?.fetchNextPage();
      // });

      // scrollcontroller.addListener(loadnextpage);
    }
  }

  Future<void> close() async {
    await _subscription.cancel();
  }

  void loadnextpage() async {
    isLoading = true;

    if (isCustomPostRanking) {
      if ((scrollcontroller.position.pixels >
              scrollcontroller.position.maxScrollExtent - 800) &&
          customRankingLiveCollection.hasNextPage() &&
          !loadingNexPage) {
        loadingNexPage = true;
        notifyListeners();
        log("loading Next Page...");
        await customRankingLiveCollection.loadNext().then((value) {
          loadingNexPage = false;
          notifyListeners();
        });
      }
    } else {
      if ((scrollcontroller.position.pixels >
              scrollcontroller.position.maxScrollExtent - 800) &&
          globalFeedLiveCollection.hasNextPage() &&
          !loadingNexPage) {
        loadingNexPage = true;
        notifyListeners();
        log("loading Next Page...");
        await globalFeedLiveCollection.loadNext().then((value) {
          loadingNexPage = false;
          notifyListeners();
        });
      }
    }
  }
}
