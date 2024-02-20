import 'dart:developer';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/view/user/medie_component.dart';
import 'package:flutter/material.dart';

import '../../components/alert_dialog.dart';

class CommuFeedVM extends ChangeNotifier {
  MediaType _selectedMediaType = MediaType.photos;
  void doSelectMedieType(MediaType mediaType) {
    _selectedMediaType = mediaType;
    log(_selectedMediaType.toString());
    notifyListeners();
  }

  MediaType getMediaType() => _selectedMediaType;
  bool isCurrentUserIsAdmin = false;
  var _amityCommunityFeedPosts = <AmityPost>[];

  late PagingController<AmityPost> _controllerCommu;

  var _amityCommunityImageFeedPosts = <AmityPost>[];

  late PagingController<AmityPost> _controllerImageCommu;

  var _amityCommunityVideoFeedPosts = <AmityPost>[];

  late PagingController<AmityPost> _controllerVideoCommu;

  final scrollcontroller = ScrollController();

  var _amityCommunityPendingFeedPosts = <AmityPost>[];

  late PagingController<AmityPost> _controllerPendingPost;

  final pendingScrollcontroller = ScrollController();

  AmityCommunity? community;
  List<AmityPost> getCommunityPosts() {
    return _amityCommunityFeedPosts;
  }

  List<AmityPost> getCommunityImagePosts() {
    return _amityCommunityImageFeedPosts;
  }

  List<AmityPost> getCommunityVideoPosts() {
    return _amityCommunityVideoFeedPosts;
  }

  List<AmityPost> getCommunityPendingPosts() {
    return _amityCommunityPendingFeedPosts;
  }

  void addPostToFeed(AmityPost post) {
    _amityCommunityFeedPosts.insert(0, post);
    notifyListeners();
  }

  Future<void> initAmityCommunityFeed(String communityId) async {
    isCurrentUserIsAdmin = false;

    //inititate the PagingController
    _controllerCommu = PagingController(
      pageFuture: (token) => AmitySocialClient.newFeedRepository()
          .getCommunityFeed(communityId)
          //feedType could be AmityFeedType.PUBLISHED, AmityFeedType.REVIEWING, AmityFeedType.DECLINED
          .feedType(AmityFeedType.PUBLISHED)
          .includeDeleted(false)
          .getPagingData(token: token, limit: 20),
      pageSize: 20,
    )..addListener(
        () async {
          log("initAmityCommunityFeed ID: $communityId");
          if (_controllerCommu.error == null) {
            //handle results, we suggest to clear the previous items
            //and add with the latest _controller.loadedItems
            _amityCommunityFeedPosts.clear();
            _amityCommunityFeedPosts.addAll(_controllerCommu.loadedItems);

            //update widgets
            notifyListeners();
          } else {
            //error on pagination controller
            // await AmityDialog().showAlertErrorDialog(
            //     title: "Error!", message: _controllerCommu.error.toString());
            //update widgets
          }
        },
      );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _controllerCommu.fetchNextPage();
    });

    scrollcontroller.addListener(loadnextpage);

    //inititate the PagingController
    await AmitySocialClient.newFeedRepository()
        .getCommunityFeed(communityId)
        .includeDeleted(false)
        .getPagingData()
        .then((value) {
      _amityCommunityFeedPosts = value.data;
    });
    notifyListeners();
    await checkIsCurrentUserIsAdmin(communityId);
  }

  Future<void> initAmityPendingCommunityFeed(
      String communityId, AmityFeedType amityFeedType) async {
    isCurrentUserIsAdmin = false;

    //inititate the PagingController
    _controllerPendingPost = PagingController(
      pageFuture: (token) => AmitySocialClient.newFeedRepository()
          .getCommunityFeed(communityId)
          //feedType could be AmityFeedType.PUBLISHED, AmityFeedType.REVIEWING, AmityFeedType.DECLINED
          .feedType(amityFeedType)
          .includeDeleted(false)
          .getPagingData(token: token, limit: 20),
      pageSize: 20,
    )..addListener(
        () async {
          log(">>>PENDINGListener");
          if (_controllerPendingPost.error == null) {
            //handle results, we suggest to clear the previous items
            //and add with the latest _controller.loadedItems
            _amityCommunityPendingFeedPosts.clear();
            _amityCommunityPendingFeedPosts
                .addAll(_controllerPendingPost.loadedItems);

            //update widgets
            notifyListeners();
          } else {
            //error on pagination controller
            // await AmityDialog().showAlertErrorDialog(
            //     title: "Error!", message: _controllerPendingPost.error.toString());
            //update widgets
          }
        },
      );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _controllerPendingPost.fetchNextPage();
    });

    pendingScrollcontroller.addListener(loadnextpage);

    //inititate the PagingController
    await AmitySocialClient.newFeedRepository()
        .getCommunityFeed(communityId)
        .includeDeleted(false)
        .feedType(amityFeedType)
        .getPagingData()
        .then((value) {
      _amityCommunityPendingFeedPosts = value.data;
    });
    notifyListeners();
    await checkIsCurrentUserIsAdmin(communityId);
  }

  Future<void> initAmityCommunityVideoFeed(String communityId) async {
    isCurrentUserIsAdmin = false;

    //inititate the PagingController
    _controllerVideoCommu = PagingController(
      pageFuture: (token) => AmitySocialClient.newFeedRepository()
          .getCommunityFeed(communityId)
          .types([AmityDataType.VIDEO])
          //feedType could be AmityFeedType.PUBLISHED, AmityFeedType.REVIEWING, AmityFeedType.DECLINED
          .feedType(AmityFeedType.PUBLISHED)
          .getPagingData(token: token, limit: 20),
      pageSize: 20,
    )..addListener(
        () async {
          log("communityListener");
          if (_controllerVideoCommu.error == null) {
            //handle results, we suggest to clear the previous items
            //and add with the latest _controller.loadedItems
            print(">>> video ${_controllerVideoCommu.loadedItems.length}");
            _amityCommunityVideoFeedPosts.clear();
            _amityCommunityVideoFeedPosts
                .addAll(_controllerVideoCommu.loadedItems);

            //update widgets
            notifyListeners();
          } else {
            //error on pagination controller
            // await AmityDialog().showAlertErrorDialog(
            //     title: "Error!", message: _controllerPendingPost.error.toString());
            //update widgets
          }
        },
      );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _controllerVideoCommu.fetchNextPage();
    });

    scrollcontroller.addListener(loadnextpage);

    //inititate the PagingController
    await AmitySocialClient.newFeedRepository()
        .getCommunityFeed(communityId)
        .includeDeleted(false)
        .types([AmityDataType.VIDEO])
        .getPagingData()
        .then((value) {
          _amityCommunityVideoFeedPosts = value.data;
        });
    notifyListeners();
    await checkIsCurrentUserIsAdmin(communityId);
  }

  Future<void> initAmityCommunityImageFeed(String communityId) async {
    isCurrentUserIsAdmin = false;

    //inititate the PagingController
    _controllerImageCommu = PagingController(
      pageFuture: (token) => AmitySocialClient.newFeedRepository()
          .getCommunityFeed(communityId)
          .types([AmityDataType.IMAGE])
          .feedType(AmityFeedType.PUBLISHED)
          .includeDeleted(false)
          .getPagingData(token: token, limit: 20),
      pageSize: 20,
    )..addListener(
        () async {
          log("communityListener");
          if (_controllerImageCommu.error == null) {
            //handle results, we suggest to clear the previous items
            //and add with the latest _controller.loadedItems

            print(
                ">>>>>${_controllerImageCommu.loadedItems[0].data!.fileInfo.fileUrl}");
            _amityCommunityImageFeedPosts.clear();
            _amityCommunityImageFeedPosts
                .addAll(_controllerImageCommu.loadedItems);

            //update widgets
            notifyListeners();
          } else {
            //error on pagination controller
            // await AmityDialog().showAlertErrorDialog(
            //     title: "Error!", message: _controllerImageCommu.error.toString());
            //update widgets
          }
        },
      );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _controllerImageCommu.fetchNextPage();
    });

    scrollcontroller.addListener(loadnextpage);

    //inititate the PagingController
    await AmitySocialClient.newFeedRepository()
        .getCommunityFeed(communityId)
        .includeDeleted(false)
        .types([AmityDataType.IMAGE])
        .getPagingData()
        .then((value) {
          _amityCommunityImageFeedPosts = value.data;
        });
    notifyListeners();
    await checkIsCurrentUserIsAdmin(communityId);
  }

  void loadnextpage() {
    print("load next page");
    if ((scrollcontroller.position.pixels ==
            scrollcontroller.position.maxScrollExtent) &&
        _controllerCommu.hasMoreItems) {
      _controllerCommu.fetchNextPage();
    }
  }

  void loadCoomunityMember() {}

  void deletePost(AmityPost post, int postIndex) async {
    log("deleting post....");
    AmitySocialClient.newPostRepository()
        .deletePost(postId: post.postId!)
        .then((value) {
      _amityCommunityFeedPosts.removeAt(postIndex);
      notifyListeners();
    }).onError((error, stackTrace) async {
      await AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
    });
  }

  void deletePendingPost(AmityPost post, int postIndex) async {
    log("deleting post....");
    AmitySocialClient.newPostRepository()
        .deletePost(postId: post.postId!)
        .then((value) {
      _amityCommunityPendingFeedPosts.removeAt(postIndex);
      notifyListeners();
    }).onError((error, stackTrace) async {
      await AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
    });
  }

  Future<void> checkIsCurrentUserIsAdmin(String communityId) async {
    log("LOG1 :checkIsCurrentUserIsAdmin");
    await AmitySocialClient.newCommunityRepository()
        .getCurentUserRoles(communityId)
        .then((value) {
      log("LOG1$value");
      for (var role in value!) {
        if (role == "community-moderator") {
          isCurrentUserIsAdmin = true;
        }
      }
      notifyListeners();
    }).onError((error, stackTrace) {
      log("LOG1:$error");
    });
  }

  void acceptPost(
      {required String postId,
      required String communityId,
      required Function(bool) callback}) {
    AmitySocialClient.newPostRepository()
        .reviewPost(postId: postId)
        .approve()
        .then((value) {
      //success
      //optional: to remove the approved post from the current post collection
      //you will need manually remove the approved post from the collection
      //for example :
      _controllerPendingPost.removeWhere((element) => element.postId == postId);
      notifyListeners();
      initAmityCommunityFeed(communityId);
    }).onError((error, stackTrace) {
      print(error);
      //handle error
    });
  }

  void declinePost(
      {required String postId,
      required String communityId,
      required Function(bool) callback}) {
    AmitySocialClient.newPostRepository()
        .reviewPost(postId: postId)
        .decline()
        .then((value) {
      //success
      //optional: to remove the approved post from the current post collection
      //you will need manually remove the approved post from the collection
      //for example :
      _controllerPendingPost.removeWhere((element) => element.postId == postId);
      notifyListeners();
      initAmityCommunityFeed(communityId);
    }).onError((error, stackTrace) {
      print(error);
      //handle error
    });
  }
}
