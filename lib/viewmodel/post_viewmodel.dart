import 'dart:developer';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/utils/navigation_key.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../components/alert_dialog.dart';

class PostVM extends ChangeNotifier {
  late AmityPost amityPost;
  late PagingController<AmityComment> _controller;
  final amityComments = <AmityComment>[];

  final scrollcontroller = ScrollController();

  final AmityCommentSortOption _sortOption =
      AmityCommentSortOption.LAST_CREATED;

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

  void listenForComments(
      {required String postID, Function? successCallback, bool? refresh}) {
    if (refresh != null) {
      if (refresh) {
        amityComments.clear();
      }
    }
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
            // Instead of clearing and re-adding all items, directly append new items
            // This assumes `amityComments` is a List that can be compared with _controller.loadedItems for duplicates
            var newComments = _controller.loadedItems;
            // Append only new comments
            var currentIds = amityComments.map((e) => e.commentId).toSet();
            var newItems = newComments
                .where((item) => !currentIds.contains(item.commentId))
                .toList();
            if (newItems.isNotEmpty) {
              amityComments.addAll(newItems);
              print("parent comments added: ${newItems.length}");
              successCallback?.call();
              notifyListeners(); // Uncomment if you are using a listener-based state management
            }
          } else {
            // Error on pagination controller
            log("error from Comment");
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
    // Dismiss the keyboard by removing focus from the current text field
    FocusScope.of(NavigationService.navigatorKey.currentContext!).unfocus();
    await AmitySocialClient.newCommentRepository()
        .createComment()
        .post(postId)
        .create()
        .text(text)
        .send()
        .then((comment) async {
      amityComments.insert(0, comment);
      Future.delayed(const Duration(milliseconds: 500)).then((value) {
        scrollcontroller.jumpTo(0);
      });
    }).onError((error, stackTrace) async {
      log(error.toString());
      await AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
    });
  }

  void flagComment(AmityComment comment, BuildContext context) {
    comment.report().flag().then((value) {
      AmitySuccessDialog.showTimedDialog("Success", context: context);
    }).onError((error, stackTrace) async {
      await AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
    });
  }

  void unFlagComment(AmityComment comment, BuildContext context) {
    comment.report().unflag().then((value) {
      AmitySuccessDialog.showTimedDialog("Success", context: context);
    }).onError((error, stackTrace) async {
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
      AmitySuccessDialog.showTimedDialog("Report success");
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
      AmitySuccessDialog.showTimedDialog("Undo report success");
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

  void updateComment(AmityComment comment, String text) async {
    comment.edit().text(text).build().update().then((value) {
      //handle result
    }).onError((error, stackTrace) async {
      log("unflag error ${error.toString()}");
      await AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
    });
  }
}
