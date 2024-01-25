import 'dart:developer';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../components/alert_dialog.dart';

class PostVM extends ChangeNotifier {
  late AmityPost amityPost;
  late PagingController<AmityComment> _controller;
  final amityComments = <AmityComment>[];

  final scrollcontroller = ScrollController();

  final AmityCommentSortOption _sortOption =
      AmityCommentSortOption.FIRST_CREATED;

  void getPost(String postId, AmityPost initialPostData) {
    amityPost = initialPostData;
    AmitySocialClient.newPostRepository()
        .getPost(postId)
        .then((AmityPost post) {
      amityPost = post;
    }).onError<AmityException>((error, stackTrace) async {
      log(error.toString());
      await AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
    });
  }

  void listenForComments(String postID) {
    _controller = PagingController(
      pageFuture: (token) => AmitySocialClient.newCommentRepository()
          .getComments()
          .post(postID)
          .sortBy(_sortOption)
          .includeDeleted(true)
          .getPagingData(token: token, limit: 20),
      pageSize: 20,
    )..addListener(
        () async {
          if (_controller.error == null) {
            amityComments.clear();
            amityComments.addAll(_controller.loadedItems);

            notifyListeners();
          } else {
            //Error on pagination controller

            log("error");
            await AmityDialog().showAlertErrorDialog(
                title: "Error!", message: _controller.error.toString());
          }
        },
      );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _controller.fetchNextPage();
    });

    scrollcontroller.addListener(loadnextpage);
  }

  void loadnextpage() {
    if ((scrollcontroller.position.pixels ==
            scrollcontroller.position.maxScrollExtent) &&
        _controller.hasMoreItems) {
      _controller.fetchNextPage();
    }
  }

  Future<void> createComment(String postId, String text) async {
    await AmitySocialClient.newCommentRepository()
        .createComment()
        .post(postId)
        .create()
        .text(text)
        .send()
        .then((comment) async {
      _controller.add(comment);
      amityComments.clear();
      amityComments.addAll(_controller.loadedItems);
      Future.delayed(const Duration(milliseconds: 300)).then((value) {
        scrollcontroller.jumpTo(scrollcontroller.position.maxScrollExtent);
      });
    }).onError((error, stackTrace) async {
      log(error.toString());
      await AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
    });
  }

  Future<void> deleteComment(AmityComment comment) async {
    print("delete commet...");
    comment.delete().then((value) {
      print("delete commet success: $value");
      amityComments
          .removeWhere((element) => element.commentId == comment.commentId);
      listenForComments(amityPost.postId!);

      notifyListeners();
    }).onError((error, stackTrace) async {
      await AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
    });
  }

  void addCommentReaction(AmityComment comment) {
    HapticFeedback.heavyImpact();
    comment.react().addReaction('like').then((value) {});
  }

  void addPostReaction(AmityPost post) {
    HapticFeedback.heavyImpact();
    post.react().addReaction('like').then((value) => {
          //success
        });
  }

  void flagPost(AmityPost post) {
    post.report().flag().then((value) {
      log("flag success $value");
      notifyListeners();
    }).onError((error, stackTrace) async {
      log("flag error ${error.toString()}");
      await AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
    });
  }

  void unflagPost(AmityPost post) {
    post.report().unflag().then((value) {
      //success
      log("unflag success $value");
      notifyListeners();
    }).onError((error, stackTrace) async {
      log("unflag error ${error.toString()}");
      await AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
    });
  }

  void removePostReaction(AmityPost post) {
    HapticFeedback.heavyImpact();
    print("removePostReaction");

    post.react().removeReaction('like').then((value) {
      print(value.toString());
      print("success");
      // Handle success
    }).catchError((error) {
      print(error);
      // Handle error
    });
  }

  void removeCommentReaction(AmityComment comment) {
    HapticFeedback.heavyImpact();
    comment.react().removeReaction('like').then((value) => {
          //success
        });
  }

  bool isliked(AmityComment comment) {
    return comment.myReactions?.isNotEmpty ?? false;
  }
}
