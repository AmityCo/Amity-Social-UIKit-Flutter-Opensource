import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/view/user/medie_component.dart';
import 'package:flutter/material.dart';

import '../../components/alert_dialog.dart';
import 'configuration_viewmodel.dart';

class UserFeedVM extends ChangeNotifier {
  MediaType _selectedMediaType = MediaType.photos;
  void doSelectMedieType(MediaType mediaType) {
    _selectedMediaType = mediaType;
    notifyListeners();
  }

  MediaType getMediaType() => _selectedMediaType;

  AmityUser? amityUser;
  late AmityUserFollowInfo amityMyFollowInfo = AmityUserFollowInfo();
  late PagingController<AmityPost> _controller;
  var amityPosts = <AmityPost>[];
  late PagingController<AmityPost> _imagePostController;
  final amityImagePosts = <AmityPost>[];
  late PagingController<AmityPost> _videoPostController;
  final amityVideoPosts = <AmityPost>[];
  final scrollcontroller = ScrollController();
  bool loading = false;
  TabController? userFeedTabController;
  void changeTab() {
    notifyListeners();
  }

  Future<void> initUserFeed(
      {AmityUser? amityUser, required String userId}) async {
    _getUser(userId: userId, otherUser: amityUser);
    await listenForUserFeed(userId,
        onCustomPost: AmityUIConfiguration.onCustomPost);
    listenForImageFeed(userId);
    listenForVideoFeed(userId);
  }

  Future<void> _getUser({required String userId, AmityUser? otherUser}) async {
    if (userId == AmityCoreClient.getUserId()) {
      amityUser = AmityCoreClient.getCurrentUser();
    } else {
      if (otherUser != null) {
        amityUser = otherUser;
      } else {
        await AmityCoreClient.newUserRepository()
            .getUser(userId)
            .then((AmityUser user) {
          amityUser = user;
        }).onError<AmityException>((error, stackTrace) {});
      }
    }
    amityMyFollowInfo.id = null;
    amityUser!.relationship().getFollowInfo(amityUser!.userId!).then((value) {
      amityMyFollowInfo = value;

      amityMyFollowInfo = value;
      notifyListeners();
    }).onError((error, stackTrace) {
      AmityDialog()
          .showAlertErrorDialog(title: "Error", message: error.toString());
    });
  }

  Future<void> listenForUserFeed(String userId,
      {required Future<List<AmityPost>> Function(List<AmityPost>)
          onCustomPost}) async {
    _controller = PagingController(
      pageFuture: (token) => AmitySocialClient.newFeedRepository()
          .getUserFeed(userId)
          .includeDeleted(false)
          .getPagingData(token: token, limit: 20),
      pageSize: 20,
    )..addListener(
        () async {
          if (_controller.error == null) {
            final feedItems = await onCustomPost(_controller.loadedItems);
            amityPosts.clear();
            amityPosts.addAll(feedItems);

            notifyListeners();
          } else {
            //Error on pagination controller
          }
        },
      );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _controller.fetchNextPage();
    });

    scrollcontroller.addListener(() {
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
        () async {
          if (_imagePostController.error == null) {
            amityImagePosts.clear();
            final feedItems = await AmityUIConfiguration.onCustomPost(
                _imagePostController.loadedItems);
            amityImagePosts.addAll(feedItems);

            notifyListeners();
          } else {
            //Error on pagination controller
          }
        },
      );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _imagePostController.fetchNextPage();
    });

    scrollcontroller.addListener(() {
      loadnextpage(scrollcontroller, _imagePostController);
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
        () async {
          if (_videoPostController.error == null) {
            amityVideoPosts.clear();
            final feedItems = await AmityUIConfiguration.onCustomPost(
                _videoPostController.loadedItems);

            amityVideoPosts.addAll(feedItems);

            notifyListeners();
          } else {
            //Error on pagination controller
          }
        },
      );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _videoPostController.fetchNextPage();
    });

    scrollcontroller.addListener(() {
      loadnextpage(scrollcontroller, _videoPostController);
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
          .then((value) => {})
          .onError((error, stackTrace) async => {
                // await AmityDialog().showAlertErrorDialog(
                //     title: "Error!", message: error.toString())
              });
    } else {
      await AmityCoreClient.getCurrentUser()
          .update()
          .displayName(displayName)
          .description(description)
          .update()
          .then((value) => {})
          .onError((error, stackTrace) async => {
                // await AmityDialog().showAlertErrorDialog(
                //     title: "Error!", message: error.toString())
              });
    }
  }

  Future<void> followButtonAction(
      AmityUser user, AmityFollowStatus amityFollowStatus) async {
    if (amityFollowStatus == AmityFollowStatus.NONE) {
      await sendFollowRequest(user: user);
      initUserFeed(userId: amityUser!.userId!);
      notifyListeners();
    } else if (amityFollowStatus == AmityFollowStatus.PENDING) {
      await withdrawFollowRequest(user);
      initUserFeed(userId: amityUser!.userId!);
      notifyListeners();
    } else if (amityFollowStatus == AmityFollowStatus.ACCEPTED) {
      await _getUser(userId: amityUser!.userId!);
      initUserFeed(userId: amityUser!.userId!);
    } else if (amityFollowStatus == AmityFollowStatus.BLOCKED) {
      //do nothing
    } else {
      AmityDialog().showAlertErrorDialog(
          title: "Error!",
          message: "followButtonAction: cant handle amityFollowStatus");
    }
  }

  void deletePost(
      AmityPost post, Function(bool success, String message) callback) async {
    AmitySocialClient.newPostRepository()
        .deletePost(postId: post.postId!)
        .then((value) {
      int postIndex = amityPosts.indexWhere((p) => p.postId == post.postId);
      amityPosts.removeAt(postIndex);
      notifyListeners();
      listenForUserFeed(amityUser!.userId!,
          onCustomPost: AmityUIConfiguration.onCustomPost);
      callback(true, "Post deleted successfully.");

      callback(false, "Post not found in the list.");
    }).onError((error, stackTrace) async {
      String errorMessage = error.toString();
      await AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: errorMessage);
      callback(false, errorMessage);
    });
  }

  Future<void> sendFollowRequest({required AmityUser user}) async {
    AmityCoreClient.newUserRepository()
        .relationship()
        .user(user.userId!)
        .follow()
        .then((AmityFollowStatus followStatus) {
      //success

      notifyListeners();
    }).onError((error, stackTrace) {
      //handle error
      AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
    });
  }

  Future<void> withdrawFollowRequest(AmityUser user) async {
    await AmityCoreClient.newUserRepository()
        .relationship()
        .me()
        .unfollow(user.userId!)
        .then((value) {
      notifyListeners();
    }).onError((error, stackTrace) {
      AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
    });
  }

  Future<void> unfollowUser(AmityUser user) async {
    await AmityCoreClient.newUserRepository()
        .relationship()
        .unfollow(user.userId!)
        .then((value) {
      amityImagePosts.clear();
      amityPosts.clear();
      amityVideoPosts.clear();
      notifyListeners();
      initUserFeed(userId: amityUser!.userId!);
    }).onError((error, stackTrace) {
      AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
    });
  }

  void blockUser(String userId, Function onCallBack) {
    AmityCoreClient.newUserRepository()
        .relationship()
        .blockUser(userId)
        .then((value) {
      AmitySuccessDialog.showTimedDialog("Blocked user");
      _getUser(userId: userId);
      notifyListeners();
      // onCallBack();
    }).onError((error, stackTrace) {
      AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
    });
  }

  void unBlockUser(String userId) {
    AmityCoreClient.newUserRepository()
        .relationship()
        .unblockUser(userId)
        .then((value) {
      AmitySuccessDialog.showTimedDialog("Unblock user");
      _getUser(userId: userId);
      notifyListeners();
    }).onError((error, stackTrace) {
      AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
    });
  }
}
