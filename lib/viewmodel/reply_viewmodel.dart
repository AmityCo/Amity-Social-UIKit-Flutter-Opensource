import 'dart:developer';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/components/alert_dialog.dart';
import 'package:amity_uikit_beta_service/viewmodel/post_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReplyTo {
  ReplyTo(this._replyToComment, this._replyingToUser);
  AmityUser _replyingToUser;

  AmityUser get replyingToUser => _replyingToUser;

  set replyingToUser(AmityUser value) {
    _replyingToUser = value;
  }

  AmityComment _replyToComment;

  AmityComment get replyToComment => _replyToComment;

  set replyToComment(AmityComment value) {
    _replyToComment = value;
  }
}

class ReplyVM extends PostVM {
  // Maps a comment ID to a list of its replies
  final Map<String, List<AmityComment>> amityReplyCommentsMap = {};

  // Maps a comment ID to its corresponding paging controller
  late final Map<String, PagingController<AmityComment>> _controllersMap = {};

  final AmityCommentSortOption _sortOption =
      AmityCommentSortOption.FIRST_CREATED;

  ReplyTo? replyToObject;

  Future<void> initReplyComment(String postId, BuildContext context) async {
    print("initReplyComment");
    print(amityComments.length);
    var comments = Provider.of<PostVM>(context, listen: false).amityComments;
    for (var comment in comments) {
      print("comment: ${comment.data}");
      listenForReplyComments(postId, comment.commentId!);
    }
  }

  void selectReplyComment({required AmityComment comment}) {
    replyToObject = ReplyTo(comment, comment.user!);
    notifyListeners();
  }

  void clearReply() {
    replyToObject = null;
    notifyListeners();
  }

// Listens for reply comments asynchronously and updates the UI upon receiving new data or an error.
  Future<void> listenForReplyComments(String postID, String commentId) async {
    print("$postID:look reply: commentId:$commentId");
    // Initialize an empty list to hold AmityComments.
    final amityComments = <AmityComment>[];

    // Set up a PagingController for managing pagination.
    _controllersMap[commentId] = PagingController(
      pageFuture: (token) => AmitySocialClient.newCommentRepository()
          .getComments()
          .post(postID)
          .parentId(commentId)
          .sortBy(_sortOption)
          .includeDeleted(true)
          .getPagingData(token: token, limit: 20),
      pageSize: 20,
    )..addListener(
        () async {
          // Check for errors from the pagination controller.
          if (_controllersMap[commentId]!.error == null) {
            // Clear existing comments and add newly loaded items.
            amityComments.clear();
            amityComments.addAll(_controllersMap[commentId]!.loadedItems);
            // Update the map of reply comments and notify listeners to update the UI.
            amityReplyCommentsMap[commentId] = amityComments;
            notifyListeners();
          } else {
            // Handle pagination controller error by logging and showing an alert dialog.
            log("error");
            await AmityDialog().showAlertErrorDialog(
                title: "Error!",
                message: _controllersMap[commentId]!.error.toString());
          }
        },
      );

    // Fetch the next page of comments after the frame is built to ensure the UI is updated.
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _controllersMap[commentId]!.fetchNextPage();
    });
  }

  void loadReplynextpage(String commentId) {
    if (_controllersMap[commentId] != null) {
      if ((scrollcontroller.position.pixels ==
              scrollcontroller.position.maxScrollExtent) &&
          _controllersMap[commentId]!.hasMoreItems) {
        _controllersMap[commentId]!.fetchNextPage();
      }
    } else {
      print("Cannot find comment ID in map");
    }
  }

  @override
  Future<void> deleteComment(AmityComment comment) async {
    print("delete commet...");
    comment.delete().then((value) {
      print("delete commet success: $value");
      // amityReplyCommentsMap[comment.commentId]!
      //     .removeWhere((element) => element.commentId == comment.commentId);
      // listenForComments(postID: amityPost.postId!);

      notifyListeners();
    }).onError((error, stackTrace) async {
      await AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
    });
  }

  Future<void> createReplyComment(
      {required String postId,
      required String commentId,
      required String text}) async {
    final amityComments = <AmityComment>[];
    await AmitySocialClient.newCommentRepository()
        .createComment()
        .post(postId)
        .parentId(commentId)
        .create()
        .text(text)
        .send()
        .then((comment) async {
      // _controller.add(comment);
      // Clear existing comments and add newly loaded items.

      // Update the map of reply comments and notify listeners to update the UI.
      amityReplyCommentsMap[commentId]!.add(comment);
      replyToObject = null;
      notifyListeners();

      // Future.delayed(const Duration(milliseconds: 300)).then((value) {
      //   scrollcontroller.jumpTo(scrollcontroller.position.maxScrollExtent);
      // });
    }).onError((error, stackTrace) async {
      log(error.toString());
      await AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
    });
  }
}
