import 'dart:developer';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/utils/navigation_key.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/alert_dialog.dart';
import 'amity_viewmodel.dart';

enum MediaType { photos, videos }

class UserFeedVM extends ChangeNotifier {
  MediaType _selectedMediaType = MediaType.photos;
  void doSelectMedieType(MediaType mediaType) {
    _selectedMediaType = mediaType;
    log(_selectedMediaType.toString());
    notifyListeners();
  }

  MediaType getMediaType() => _selectedMediaType;

  AmityUser? amityUser;
  late AmityUserFollowInfo amityMyFollowInfo = AmityUserFollowInfo();
  late PagingController<AmityPost> _controller;
  final amityPosts = <AmityPost>[];
  late PagingController<AmityPost> _imagePostController;
  final amityImagePosts = <AmityPost>[];
  late PagingController<AmityPost> _videoPostController;
  final amityVideoPosts = <AmityPost>[];
  final scrollcontroller = ScrollController();
  final imageScrollcontroller = ScrollController();
  final videoScrollcontroller = ScrollController();
  bool loading = false;

  void initUserFeed({AmityUser? amityUser, required String userId}) async {
    _getUser(userId: userId, otherUser: amityUser);
    listenForUserFeed(userId);
    listenForImageFeed(userId);
    listenForVideoFeed(userId);
  }

  Future<void> _getUser({required String userId, AmityUser? otherUser}) async {
    log("getUser=> $userId");
    if (userId == AmityCoreClient.getUserId()) {
      log("isCurrentUser:$userId");
      amityUser = Provider.of<AmityVM>(
              NavigationService.navigatorKey.currentContext!,
              listen: false)
          .currentamityUser;
    } else {
      log("isNotCurrentUser:$userId");
      if (otherUser != null) {
        print("set instant user object");
        amityUser = otherUser;
      } else {
        print("get new user object");
        await AmityCoreClient.newUserRepository()
            .getUser(userId)
            .then((AmityUser user) {
          print("get user success");
          amityUser = user;
        }).onError<AmityException>((error, stackTrace) {
          print("fail getting user Data");
        });
      }
    }
    print("get following info");
    amityUser!.relationship().getFollowInfo(amityUser!.userId!).then((value) {
      amityMyFollowInfo = value;
      notifyListeners();
    }).onError((error, stackTrace) {
      AmityDialog()
          .showAlertErrorDialog(title: "Error", message: error.toString());
    });
  }

  void listenForUserFeed(String userId) {
    _controller = PagingController(
      pageFuture: (token) => AmitySocialClient.newFeedRepository()
          .getUserFeed(userId)
          .includeDeleted(false)
          .getPagingData(token: token, limit: 20),
      pageSize: 20,
    )..addListener(
        () {
          if (_controller.error == null) {
            amityPosts.clear();
            amityPosts.addAll(_controller.loadedItems);

            notifyListeners();
          } else {
            //Error on pagination controller
            log("Error: listenForUserFeed... with userId = $userId");
            log("ERROR::${_controller.error.toString()}");
          }
        },
      );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _controller.fetchNextPage();
    });

    videoScrollcontroller.addListener(() {
      loadnextpage(scrollcontroller, _controller);
    });
  }

  void listenForImageFeed(String userId) {
    _imagePostController = PagingController(
      pageFuture: (token) => AmitySocialClient.newPostRepository()
          .getPosts()
          .targetUser(userId)
          .types([AmityDataType.IMAGE])
          .includeDeleted(false)
          .getPagingData(token: token, limit: 20),
      pageSize: 20,
    )..addListener(
        () {
          if (_imagePostController.error == null) {
            amityImagePosts.clear();
            amityImagePosts.addAll(_imagePostController.loadedItems);

            notifyListeners();
          } else {
            //Error on pagination controller
            log("Error: listenForUserFeed... with userId = $userId");
            log("ERROR::${_imagePostController.error.toString()}");
          }
        },
      );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _imagePostController.fetchNextPage();
    });

    videoScrollcontroller.addListener(() {
      loadnextpage(imageScrollcontroller, _imagePostController);
    });
  }

  void listenForVideoFeed(String userId) {
    _videoPostController = PagingController(
      pageFuture: (token) => AmitySocialClient.newPostRepository()
          .getPosts()
          .targetUser(userId)
          .types([AmityDataType.VIDEO])
          .includeDeleted(false)
          .getPagingData(token: token, limit: 20),
      pageSize: 20,
    )..addListener(
        () {
          if (_videoPostController.error == null) {
            amityVideoPosts.clear();
            amityVideoPosts.addAll(_videoPostController.loadedItems);

            notifyListeners();
          } else {
            //Error on pagination controller
            log("Error: listenForUserFeed... with userId = $userId");
            log("ERROR::${_videoPostController.error.toString()}");
          }
        },
      );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _videoPostController.fetchNextPage();
    });

    videoScrollcontroller.addListener(() {
      loadnextpage(videoScrollcontroller, _videoPostController);
    });
  }

  void loadnextpage(ScrollController scrollController,
      PagingController<AmityPost> pagingController) {
    if ((scrollController.position.pixels ==
            scrollController.position.maxScrollExtent) &&
        pagingController.hasMoreItems) {
      pagingController.fetchNextPage();
    }
  }

  Future<void> editCurrentUserInfo(
      {required String displayName,
      required String description,
      String? avatarFileId}) async {
    if (avatarFileId != null) {
      await AmityCoreClient.getCurrentUser()
          .update()
          .avatarFileId(avatarFileId)
          .description(description)
          .displayName(displayName)
          .update()
          .then((value) =>
              {log("update displayname & description & avatarFileUrl success")})
          .onError((error, stackTrace) async => {
                log("update displayname & description & avatarFileUrl fail"),
                await AmityDialog().showAlertErrorDialog(
                    title: "Error!", message: error.toString())
              });
    } else {
      await AmityCoreClient.getCurrentUser()
          .update()
          .displayName(displayName)
          .description(description)
          .update()
          .then((value) => {log("update displayname & description success")})
          .onError((error, stackTrace) async => {
                log("update displayname & description fail"),
                await AmityDialog().showAlertErrorDialog(
                    title: "Error!", message: error.toString())
              });
    }
  }

  void followButtonAction(AmityUser user, AmityFollowStatus amityFollowStatus) {
    log(amityFollowStatus.toString());
    if (amityFollowStatus == AmityFollowStatus.NONE) {
      sendFollowRequest(user: user);
    } else if (amityFollowStatus == AmityFollowStatus.PENDING) {
      withdrawFollowRequest(user);
    } else if (amityFollowStatus == AmityFollowStatus.ACCEPTED) {
      unfollowUser(user);
    } else {
      AmityDialog().showAlertErrorDialog(
          title: "Error!",
          message: "followButtonAction: cant handle amityFollowStatus");
    }
  }

  void deletePost(AmityPost post, int postIndex) async {
    log("deleting post....");
    AmitySocialClient.newPostRepository()
        .deletePost(postId: post.postId!)
        .then((value) {
      amityPosts.removeAt(postIndex);
      notifyListeners();
    }).onError((error, stackTrace) async {
      await AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
    });
  }

  Future<void> sendFollowRequest({required AmityUser user}) async {
    AmityCoreClient.newUserRepository()
        .relationship()
        .user(user.userId!)
        .follow()
        .then((AmityFollowStatus followStatus) {
      //success
      log("sendFollowRequest: Success");
      notifyListeners();
    }).onError((error, stackTrace) {
      //handle error
      AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
    });
  }

  void withdrawFollowRequest(AmityUser user) {
    AmityCoreClient.newUserRepository()
        .relationship()
        .me()
        .unfollow(user.userId!)
        .then((value) {
      log("withdrawFollowRequest: Success");
      notifyListeners();
    }).onError((error, stackTrace) {
      AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
    });
  }

  void unfollowUser(AmityUser user) {
    AmityCoreClient.newUserRepository()
        .relationship()
        .unfollow(user.userId!)
        .then((value) {
      log("unfollowUser: Success");
      notifyListeners();
    }).onError((error, stackTrace) {
      AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
    });
  }
}
