import 'dart:developer';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/components/alert_dialog.dart';
import 'package:amity_uikit_beta_service/view/UIKit/social/general_component.dart';
import 'package:amity_uikit_beta_service/view/social/global_feed.dart';
import 'package:amity_uikit_beta_service/view/social/post_content_widget.dart';
import 'package:amity_uikit_beta_service/view/user/user_profile.dart';
import 'package:amity_uikit_beta_service/viewmodel/amity_viewmodel.dart';
import 'package:amity_uikit_beta_service/viewmodel/reply_viewmodel.dart';
import 'package:animation_wrappers/animation_wrappers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../components/custom_user_avatar.dart';
import '../../viewmodel/configuration_viewmodel.dart';
import '../../viewmodel/post_viewmodel.dart';

class CommentScreen extends StatefulWidget {
  final AmityPost amityPost;
  final ThemeData theme;
  final bool isFromFeed;

  const CommentScreen(
      {Key? key,
      required this.amityPost,
      required this.theme,
      required this.isFromFeed})
      : super(key: key);

  @override
  CommentScreenState createState() => CommentScreenState();
}

class Comments {
  String image;
  String name;

  Comments(this.image, this.name);
}

class CommentScreenState extends State<CommentScreen> {
  final _commentTextEditController = TextEditingController();

  @override
  void initState() {
    //query comment here

    Provider.of<PostVM>(context, listen: false)
        .getPost(widget.amityPost.postId!, widget.amityPost);

    super.initState();
  }

  bool isMediaPosts() {
    final childrenPosts =
        Provider.of<PostVM>(context, listen: false).amityPost.children;
    if (childrenPosts != null && childrenPosts.isNotEmpty) {
      return true;
    }
    return false;
    // return true;
  }

  Widget mediaPostWidgets() {
    AmityPost parentPost =
        Provider.of<PostVM>(context, listen: false).amityPost;
    List<AmityPost> childrenPosts = parentPost.children ?? [];
    if (childrenPosts.isNotEmpty) {
      return AmityPostWidget(
        childrenPosts,
        true,
        false,
        haveChildrenPost: true,
      );
    }
    // else {
    //   TextData textData = parentPost.data as TextData;
    //   if (textData.text != null) {
    //     return  AmityPostWidget(
    //       [parentPost],
    //       false,
    //       false,
    //       haveChildrenPost: false,
    //       shouldShowTextPost: false,
    //     );
    //   } else {
    //     return Container();
    //   }
    // }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    var postData =
        Provider.of<PostVM>(context, listen: false).amityPost.data as TextData;
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final bHeight = mediaQuery.size.height - mediaQuery.padding.top;

    return Consumer<PostVM>(builder: (context, vm, _) {
      return StreamBuilder<AmityPost>(
          key: Key(postData.postId),
          stream: vm.amityPost.listen.stream,
          initialData: vm.amityPost,
          builder: (context, snapshot) {
            var snapshotPostData = snapshot.data?.data as TextData;
            var actionSection = Column(
              children: [
                Container(
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(width: 20), // Spacing between buttons
                      // Like Button
                      GestureDetector(
                        onTap: () {
                          // Logic to handle like action
                        },
                        child: Row(
                          children: [
                            snapshot.data!.myReactions!.isNotEmpty
                                ? GestureDetector(
                                    onTap: () {
                                      Provider.of<PostVM>(context,
                                              listen: false)
                                          .removePostReaction(widget.amityPost);
                                    },
                                    child: Row(
                                      children: [
                                        SvgPicture.asset(
                                          "assets/Icons/like.svg",
                                          package: 'amity_uikit_beta_service',
                                        ),
                                        const Text(
                                          "Like",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xff898E9E),
                                              fontSize: 15),
                                        ),
                                      ],
                                    ),
                                  )
                                : GestureDetector(
                                    onTap: () {
                                      log(widget.amityPost.myReactions!
                                          .toString());
                                      Provider.of<PostVM>(context,
                                              listen: false)
                                          .addPostReaction(widget.amityPost);
                                    },
                                    child: const Row(
                                      children: [
                                        Icon(
                                          Icons.thumb_up_off_alt,
                                          color: Colors.grey,
                                          size: 16,
                                        ),
                                        Text(
                                          "Like",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xff898E9E),
                                              fontSize: 15),
                                        ),
                                      ],
                                    ),
                                  ),
                            const SizedBox(width: 4),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20), // Spacing between buttons

                      // Comment Button
                      GestureDetector(
                        onTap: () {
                          // Logic to navigate to comments section
                        },
                        child: const Row(
                          children: [
                            Icon(Icons.chat_bubble_outline, color: Colors.grey),
                            SizedBox(width: 4),
                            Text(
                              "Comment",
                              // snapshot.data!.commentCount.toString(),
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20), // Spacing between buttons

                      // Share Button
                      // GestureDetector(
                      //   onTap: () {},
                      //   child: const Row(
                      //     children: [
                      //       Icon(Icons.ios_share_outlined, color: Colors.grey),
                      //       SizedBox(width: 4),
                      //       Text(
                      //         "Share",
                      //         style: TextStyle(color: Colors.grey),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ],
            );

            return Scaffold(
              backgroundColor: Colors.white,
              body: FadedSlideAnimation(
                beginOffset: const Offset(0, 0.3),
                endOffset: const Offset(0, 0),
                slideCurve: Curves.linearToEaseOut,
                child: SafeArea(
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.chevron_left,
                              color: Colors.black, size: 35),
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: vm.scrollcontroller,
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      FocusScope.of(context).unfocus();
                                    },
                                    // color: isMediaPosts()
                                    //     ? Colors.black
                                    //     : Colors.transparent,
                                    // padding: isMediaPosts()
                                    //     ? const EdgeInsets.only(top: 285)
                                    //     : null,
                                    // // height: (bHeight - 60) * 0.6,

                                    // decoration: BoxDecoration(),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        // Text("${snapshot.data!.targetType!}"),
                                        Container(
                                          color: Colors.red,
                                          child: PostWidget(
                                            feedType: FeedType.community,
                                            showCommunity:
                                                snapshot.data?.targetType ==
                                                        AmityPostTargetType
                                                            .COMMUNITY
                                                    ? true
                                                    : false,
                                            showlatestComment: false,
                                            post: snapshot.data!,
                                            theme: theme,
                                            postIndex: 0,
                                            isFromFeed: false,
                                          ),
                                        ),

                                        const Divider(),
                                        CommentComponent(
                                            postId: widget.amityPost.postId!,
                                            theme: theme),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          Provider.of<ReplyVM>(context).replyToObject == null
                              ? const SizedBox()
                              : Container(
                                  color: Colors.grey[200],
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "Replying to ${Provider.of<ReplyVM>(context).replyToObject?.replyingToUser.displayName}",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w400,
                                              color: Color(0xff636878)),
                                        ),
                                      ),
                                      GestureDetector(
                                          onTap: () {
                                            Provider.of<ReplyVM>(context,
                                                    listen: false)
                                                .clearReply();
                                          },
                                          child: const Icon(Icons.close,
                                              color: Color(0xff636878)))
                                    ],
                                  ),
                                ),
                          CommentTextField(
                            postId: snapshot.data!.postId!,
                            commentTextEditController:
                                _commentTextEditController,
                            navigateToFullCommentPage: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => FullCommentPage(
                                        commentTextEditController:
                                            _commentTextEditController,
                                        postId: snapshot.data!.postId!,
                                        postCallback: () async {
                                          Navigator.of(context).pop();
                                          HapticFeedback.heavyImpact();
                                          await Provider.of<PostVM>(context,
                                                  listen: false)
                                              .createComment(
                                                  snapshot.data!.postId!,
                                                  _commentTextEditController
                                                      .text);

                                          _commentTextEditController.clear();
                                        },
                                      )));
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          });
    });
  }
}

class CommentTextField extends StatelessWidget {
  const CommentTextField({
    super.key,
    required this.commentTextEditController,
    required this.postId,
    required this.navigateToFullCommentPage,
  });

  final TextEditingController commentTextEditController;
  final String postId;
  final VoidCallback navigateToFullCommentPage;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
          color: Colors.grey,
          blurRadius: 0.8,
          spreadRadius: 0.5,
        ),
      ]),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        leading: getAvatarImage(
            Provider.of<AmityVM>(context).currentamityUser?.avatarUrl),
        title: ConstrainedBox(
          constraints: const BoxConstraints(
            maxHeight: 200.0, // Maximum height for the text field
          ),
          child: TextField(
            controller: commentTextEditController,
            decoration: InputDecoration(
              suffixIcon: IconButton(
                icon: Stack(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Icon(
                        Icons.arrow_outward_sharp,
                        size: 15,
                        color: Color(0xffA5A9B5),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..scale(-1.0, -1.0), // Flips horizontally
                        child: const Icon(
                          Icons.arrow_outward_sharp,
                          size: 15,
                          color: Color(0xffA5A9B5),
                        ),
                      ),
                    ),
                  ],
                ),
                onPressed: navigateToFullCommentPage,
              ),
              hintText: 'Say something nice...',
              fillColor: Colors.grey[300], // Set the background color to grey
              filled: true, // Enable the fill color
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0), // Rounded border
                borderSide: BorderSide.none, // No border side
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10), // Padding inside the text field
            ),
            keyboardType: TextInputType.multiline,
            maxLines: null, // Allows for any number of lines
          ),
        ),
        trailing: GestureDetector(
            onTap: () async {
              if (Provider.of<ReplyVM>(context, listen: false).replyToObject ==
                  null) {
                HapticFeedback.heavyImpact();
                await Provider.of<PostVM>(context, listen: false)
                    .createComment(postId, commentTextEditController.text);
              } else {
                ///Create Comment with Reply
                print("reply comment");
                var replyingComment =
                    Provider.of<ReplyVM>(context, listen: false)
                        .replyToObject
                        ?.replyToComment
                        .commentId;
                HapticFeedback.heavyImpact();
                print(replyingComment!);
                Provider.of<ReplyVM>(context, listen: false).createReplyComment(
                    postId: postId,
                    commentId: replyingComment,
                    text: commentTextEditController.text);
              }

              commentTextEditController.clear();
            },
            child: Text("Post  ",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Provider.of<AmityUIConfiguration>(context)
                        .primaryColor))),
      ),
    );
  }
}

class FullCommentPage extends StatelessWidget {
  final TextEditingController commentTextEditController;
  final String postId;
  final VoidCallback postCallback;
  const FullCommentPage({
    super.key,
    required this.commentTextEditController,
    required this.postId,
    required this.postCallback,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        shadowColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.close,
            color: Colors.black,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Add Comment",
          style: Provider.of<AmityUIConfiguration>(context).titleTextStyle,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              postCallback();
            },
            child: Text(
              'Post',
              style: TextStyle(
                  color:
                      Provider.of<AmityUIConfiguration>(context).primaryColor),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          controller: commentTextEditController,
          keyboardType: TextInputType.multiline,
          maxLines: null, // Allows for any number of lines
          decoration: const InputDecoration(
              hintText: 'Type message', border: InputBorder.none),
        ),
      ),
    );
  }
}

class EditCommentPage extends StatefulWidget {
  final AmityComment comment;
  final VoidCallback postCallback;
  final String initailText;
  const EditCommentPage({
    super.key,
    required this.initailText,
    required this.comment,
    required this.postCallback,
  });

  @override
  State<EditCommentPage> createState() => _EditCommentPageState();
}

class _EditCommentPageState extends State<EditCommentPage> {
  TextEditingController textEditingController = TextEditingController();
  @override
  void initState() {
    textEditingController.text = widget.initailText;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        shadowColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.close,
            color: Colors.black,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Edit Comment",
          style: Provider.of<AmityUIConfiguration>(context).titleTextStyle,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              print(textEditingController.text);
              HapticFeedback.heavyImpact();
              Provider.of<PostVM>(context, listen: false)
                  .updateComment(widget.comment, textEditingController.text);
              Navigator.of(context).pop();
              widget.postCallback();
            },
            child: Text(
              'Save',
              style: TextStyle(
                  color:
                      Provider.of<AmityUIConfiguration>(context).primaryColor),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          controller: textEditingController,
          keyboardType: TextInputType.multiline,
          maxLines: null, // Allows for any number of lines
          decoration: InputDecoration(
              hintText: widget.initailText, border: InputBorder.none),
        ),
      ),
    );
  }
}

class CommentComponent extends StatefulWidget {
  const CommentComponent({
    Key? key,
    required this.postId,
    required this.theme,
  }) : super(key: key);

  final String postId;
  final ThemeData theme;

  @override
  State<CommentComponent> createState() => _CommentComponentState();
}

class _CommentComponentState extends State<CommentComponent> {
  @override
  void initState() {
    Provider.of<PostVM>(context, listen: false).listenForComments(
        postID: widget.postId,
        refresh: true,
        successCallback: () {
          Provider.of<ReplyVM>(context, listen: false)
              .initReplyComment(widget.postId, context);
        });

    super.initState();
  }

  bool isLiked(AsyncSnapshot<AmityComment> snapshot) {
    var comments = snapshot.data!;
    return comments.myReactions?.isNotEmpty ?? false;
  }

  final _editcommentTextEditController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Consumer<PostVM>(builder: (context, vm, _) {
      return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: vm.amityComments.length,
        itemBuilder: (context, index) {
          return StreamBuilder<AmityComment>(
            key: Key(vm.amityComments[index].commentId!),
            stream: vm.amityComments[index].listen.stream,
            initialData: vm.amityComments[index],
            builder: (context, snapshot) {
              var comments = snapshot.data!;
              var commentData = comments.data as CommentTextData;

              return comments.isDeleted!
                  ? Container(
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 14,
                                ),
                                Icon(
                                  Icons.remove_circle_outline,
                                  size: 15,
                                  color: Color(0xff636878),
                                ),
                                SizedBox(
                                  width: 14,
                                ),
                                Text(
                                  "This comment  has been deleted",
                                  style: TextStyle(
                                      color: Color(0xff636878), fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          Divider(
                            height: 0,
                          )
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              leading: GestureDetector(
                                onTap: () {
                                  // Navigate to user profile
                                },
                                child: GestureDetector(
                                    onTap: () async {
                                      await Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  UserProfileScreen(
                                                      amityUserId:
                                                          comments.userId!,
                                                      amityUser:
                                                          comments.user!)));
                                    },
                                    child: getAvatarImage(
                                        comments.user!.avatarUrl)),
                              ),
                              title: Text(
                                comments.user!.displayName!,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Row(
                                children: [
                                  TimeAgoWidget(
                                    createdAt:
                                        comments.createdAt == comments.editedAt
                                            ? comments.editedAt!
                                            : comments.createdAt!,
                                  ),
                                  comments.createdAt == comments.editedAt
                                      ? const SizedBox()
                                      : Row(
                                          children: [
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            const Icon(
                                              Icons.circle,
                                              size: 5,
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Text(comments.createdAt ==
                                                    comments.editedAt
                                                ? ""
                                                : "Edited"),
                                          ],
                                        )
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10.0),
                              margin: const EdgeInsets.only(left: 70.0),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                ),
                              ),
                              child: Text(
                                commentData.text!,
                                style: widget.theme.textTheme.bodyMedium,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 70.0, top: 0),
                              child: Row(
                                children: [
                                  // Like Button
                                  isLiked(snapshot)
                                      ? GestureDetector(
                                          onTap: () {
                                            vm.removeCommentReaction(comments);
                                          },
                                          child: Row(
                                            children: [
                                              Provider.of<AmityUIConfiguration>(
                                                      context)
                                                  .iconConfig
                                                  .likedIcon(
                                                      color: Provider.of<
                                                                  AmityUIConfiguration>(
                                                              context)
                                                          .primaryColor),
                                              Text(
                                                  " ${snapshot.data?.reactionCount ?? 0}"),
                                            ],
                                          ),
                                        )
                                      : GestureDetector(
                                          onTap: () {
                                            vm.addCommentReaction(comments);
                                          },
                                          child: Row(
                                            children: [
                                              Provider.of<AmityUIConfiguration>(
                                                      context)
                                                  .iconConfig
                                                  .likeIcon(iconSize: 16),
                                              const Text(
                                                " Like",
                                                style: TextStyle(
                                                    color: Color(0xff898E9E),
                                                    fontSize: 15),
                                              ),
                                            ],
                                          )),

                                  const SizedBox(width: 10),
                                  // Reply Button
                                  GestureDetector(
                                    onTap: () {
                                      Provider.of<ReplyVM>(context,
                                              listen: false)
                                          .selectReplyComment(
                                              comment: comments);
                                    },
                                    child: Row(
                                      children: [
                                        Provider.of<AmityUIConfiguration>(
                                                context)
                                            .iconConfig
                                            .replyIcon(iconSize: 16),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        const Text(
                                          "Reply",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xff898E9E),
                                              fontSize: 15),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // More Options Button
                                  IconButton(
                                    icon: const Icon(
                                      Icons.more_horiz,
                                      color: Color(0xff898E9E),
                                    ),
                                    onPressed: () {
                                      AmityGeneralCompomemt
                                          .showOptionsBottomSheet(context, [
                                        comments.user?.userId! ==
                                                AmityCoreClient.getCurrentUser()
                                                    .userId
                                            ? const SizedBox()
                                            : ListTile(
                                                title: Text(
                                                  !comments.isFlaggedByMe
                                                      ? 'Undo Report'
                                                      : 'Report',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                                onTap: () async {
                                                  if (!comments.isFlaggedByMe) {
                                                    vm.flagComment(
                                                        comments, context);
                                                  } else {
                                                    vm.unFlagComment(
                                                        comments, context);
                                                  }
                                                  Navigator.pop(context);
                                                },
                                              ),

                                        ///check admin
                                        comments.user?.userId! !=
                                                AmityCoreClient.getCurrentUser()
                                                    .userId
                                            ? const SizedBox()
                                            : ListTile(
                                                title: const Text(
                                                  'Edit Comment',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                                onTap: () async {
                                                  Navigator.of(context).pop();
                                                  Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              EditCommentPage(
                                                                initailText:
                                                                    commentData
                                                                        .text!,
                                                                comment:
                                                                    comments,
                                                                postCallback:
                                                                    () async {},
                                                              )));
                                                },
                                              ),
                                        comments.user?.userId! !=
                                                AmityCoreClient.getCurrentUser()
                                                    .userId
                                            ? const SizedBox()
                                            : ListTile(
                                                title: const Text(
                                                  'Delete Comment',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                                onTap: () async {
                                                  ConfirmationDialog().show(
                                                      context: context,
                                                      title:
                                                          "Delete this comment",
                                                      detailText:
                                                          " This comment will be permanently deleted. You'll no longer to see and find this comment",
                                                      onConfirm: () {
                                                        vm.deleteComment(
                                                            comments);
                                                        // AmitySuccessDialog
                                                        //     .showTimedDialog(
                                                        //         "Success",
                                                        //         context:
                                                        //             context);
                                                        Navigator.pop(context);
                                                      });
                                                },
                                              ),
                                      ]);
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding:
                                  const EdgeInsets.only(left: 60, right: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Provider.of<ReplyVM>(context)
                                                  .amityReplyCommentsMap[
                                              comments.commentId] ==
                                          null
                                      ? const SizedBox()
                                      : ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount:
                                              Provider.of<ReplyVM>(context)
                                                  .amityReplyCommentsMap[
                                                      comments.commentId]!
                                                  .length,
                                          itemBuilder: (context, index) {
                                            var replyComment =
                                                Provider.of<ReplyVM>(context)
                                                        .amityReplyCommentsMap[
                                                    comments.commentId]![index];
                                            return ReplyCommentComponent(
                                              comment: replyComment,
                                            );
                                          },
                                        ),
                                  Provider.of<ReplyVM>(context)
                                          .replyHaveNextPage(
                                              comments.commentId!)
                                      ? GestureDetector(
                                          onTap: () {
                                            HapticFeedback.mediumImpact();
                                            Provider.of<ReplyVM>(context,
                                                    listen: false)
                                                .loadReplynextpage(
                                              comments.commentId!,
                                            );
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.all(12),
                                            decoration: const BoxDecoration(
                                                color: Color(0xffEBECEF),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(4))),
                                            padding: const EdgeInsets.all(5.0),
                                            child: const Wrap(
                                              crossAxisAlignment:
                                                  WrapCrossAlignment.center,
                                              children: [
                                                SizedBox(
                                                  width: 14,
                                                ),
                                                Icon(
                                                  Icons
                                                      .subdirectory_arrow_right,
                                                  size: 15,
                                                  color: Color(0xff636878),
                                                ),
                                                SizedBox(
                                                  width: 14,
                                                ),
                                                Text(
                                                  "View more replies",
                                                  style: TextStyle(
                                                      color: Color(0xff636878),
                                                      fontSize: 13),
                                                ),
                                                SizedBox(
                                                  width: 14,
                                                )
                                              ],
                                            ),
                                          ),
                                        )
                                      : const SizedBox(),
                                ],
                              ),
                            )
                          ],
                        ),
                        const Divider(
                          height: 0,
                        ),
                      ],
                    );
            },
          );
        },
      );
    });
  }
}

// import 'package:amity_sdk/amity_sdk.dart';
// import 'package:amity_uikit_beta_service/viewmodel/post_viewmodel.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// // Other imports...

// class CommentScreen extends StatefulWidget {
//   final AmityPost amityPost;

//   const CommentScreen({Key? key, required this.amityPost}) : super(key: key);

//   @override
//   CommentScreenState createState() => CommentScreenState();
// }

// class CommentScreenState extends State<CommentScreen> {
//   final _commentTextEditController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     // Initialize the post and comments
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<PostVM>(builder: (context, vm, _) {
//       return Scaffold(
//         appBar: AppBar(
//           leading: IconButton(
//             icon: Icon(Icons.arrow_back),
//             onPressed: () => Navigator.of(context).pop(),
//           ),
//           title: Text('Post'),
//         ),
//         body: SingleChildScrollView(
//           child: Column(
//             children: [
//               _buildPostContent(vm.amityPost),
//               _buildCommentSection(vm),
//               _buildCommentInputField(),
//             ],
//           ),
//         ),
//       );
//     });
//   }

//   Widget _buildPostContent(AmityPost post) {
//     TextData textData = post.data as TextData;
//     return Card(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           ListTile(
//             leading: CircleAvatar(
//               backgroundImage: NetworkImage(post.postedUser!.avatarUrl!),
//             ),
//             title: Text(post.postedUser!.displayName!),
//             subtitle: Text(DateFormat.yMMMMEEEEd().format(post.createdAt!)),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Text(textData.text ?? ""),
//           ),
//           ButtonBar(
//             children: [
//               // Like, Comment, and Share buttons
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCommentSection(PostVM vm) {
//     return ListView.builder(
//       shrinkWrap: true,
//       physics: NeverScrollableScrollPhysics(),
//       itemCount: vm.amityComments.length,
//       itemBuilder: (context, index) {
//         var comment = vm.amityComments[index];
//         CommentTextData textData = comment.data as CommentTextData;
//         return ListTile(
//           leading: CircleAvatar(
//             backgroundImage: NetworkImage(comment.user!.avatarUrl!),
//           ),
//           title: Text(comment.user!.displayName!),
//           subtitle: Text(textData.text ?? ""),
//         );
//       },
//     );
//   }

// Widget _buildCommentInputField() {
//   return ListTile(
//     leading: CircleAvatar(
//         // User's avatar
//         ),
//     title: TextField(
//       controller: _commentTextEditController,
//       decoration: InputDecoration(
//         hintText: "Write a comment...",
//         border: InputBorder.none,
//       ),
//     ),
//     trailing: IconButton(
//       icon: Icon(Icons.send),
//       onPressed: () {
//         // Logic to post comment
//       },
//     ),
//   );
// }
// }

class ReplyCommentComponent extends StatelessWidget {
  final AmityComment comment;
  const ReplyCommentComponent({
    super.key,
    required this.comment,
  });
  bool isLiked(AsyncSnapshot<AmityComment> snapshot) {
    var comments = snapshot.data!;
    return comments.myReactions?.isNotEmpty ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReplyVM>(builder: (context, vm, _) {
      return StreamBuilder<AmityComment>(
          key: Key(comment.commentId!),
          stream: comment.listen.stream,
          initialData: comment,
          builder: (context, snapshot) {
            var comments = snapshot.data!;
            var commentData = comments.data as CommentTextData;
            return comments.isDeleted!
                ? Container(
                    padding: const EdgeInsets.only(left: 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                              color: Color(0xffEBECEF),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4))),
                          padding: const EdgeInsets.all(5.0),
                          child: const Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              SizedBox(
                                width: 14,
                              ),
                              Icon(
                                Icons.remove_circle_outline,
                                size: 15,
                                color: Color(0xff636878),
                              ),
                              SizedBox(
                                width: 14,
                              ),
                              Text(
                                "This reply has been deleted",
                                style: TextStyle(
                                    color: Color(0xff636878), fontSize: 13),
                              ),
                              SizedBox(
                                width: 14,
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.only(left: 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: GestureDetector(
                            onTap: () {
                              // Navigate to user profile
                            },
                            child: GestureDetector(
                                onTap: () async {
                                  await Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              UserProfileScreen(
                                                  amityUserId: comment.userId!,
                                                  amityUser: comment.user!)));
                                },
                                child: getAvatarImage(comment.user!.avatarUrl)),
                          ),
                          title: Text(
                            comment.user!.displayName!,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: TimeAgoWidget(
                            createdAt: snapshot.data!.createdAt!,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(10.0),
                          margin: const EdgeInsets.only(left: 70.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                            ),
                          ),
                          child: Text(
                            commentData.text!,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 70.0, top: 0),
                          child: Row(
                            children: [
                              // Like Button
                              isLiked(snapshot)
                                  ? GestureDetector(
                                      onTap: () {
                                        vm.removeCommentReaction(comment);
                                      },
                                      child: Row(
                                        children: [
                                          Provider.of<AmityUIConfiguration>(
                                                  context)
                                              .iconConfig
                                              .likedIcon(
                                                  color: Provider.of<
                                                              AmityUIConfiguration>(
                                                          context)
                                                      .primaryColor),
                                          Text(
                                              " ${snapshot.data?.reactionCount ?? 0}"),
                                        ],
                                      ),
                                    )
                                  : GestureDetector(
                                      onTap: () {
                                        vm.addCommentReaction(comment);
                                      },
                                      child: Row(
                                        children: [
                                          Provider.of<AmityUIConfiguration>(
                                                  context)
                                              .iconConfig
                                              .likeIcon(iconSize: 16),
                                          const Text(
                                            " Like",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xff898E9E),
                                                fontSize: 15),
                                          ),
                                        ],
                                      )),

                              // const SizedBox(width: 10),
                              // // Reply Button
                              // Provider.of<AmityUIConfiguration>(context)
                              //     .iconConfig
                              //     .replyIcon(iconSize: 16),

                              // const Text(
                              //   "Reply",
                              //   style: TextStyle(
                              //     color: Color(0xff898E9E),
                              //   ),
                              // ),

                              // More Options Button
                              IconButton(
                                icon: const Icon(
                                  Icons.more_horiz,
                                  color: Color(0xff898E9E),
                                ),
                                onPressed: () {
                                  AmityGeneralCompomemt.showOptionsBottomSheet(
                                      context, [
                                    comment.user?.userId! ==
                                            AmityCoreClient.getCurrentUser()
                                                .userId
                                        ? const SizedBox()
                                        : ListTile(
                                            title: const Text(
                                              'Report',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            onTap: () async {
                                              Navigator.pop(context);
                                            },
                                          ),

                                    ///check admin
                                    comment.user?.userId! !=
                                            AmityCoreClient.getCurrentUser()
                                                .userId
                                        ? const SizedBox()
                                        : ListTile(
                                            title: const Text(
                                              'Edit Comment',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            onTap: () async {
                                              Navigator.pop(context);
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          EditCommentPage(
                                                            initailText: (comments
                                                                        .data
                                                                    as CommentTextData)
                                                                .text!,
                                                            comment: comments,
                                                            postCallback:
                                                                () async {},
                                                          )));
                                            },
                                          ),
                                    comment.user?.userId! !=
                                            AmityCoreClient.getCurrentUser()
                                                .userId
                                        ? const SizedBox()
                                        : ListTile(
                                            title: const Text(
                                              'Delete Comment',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            onTap: () async {
                                              ConfirmationDialog().show(
                                                  context: context,
                                                  title: "Delete this comment",
                                                  detailText:
                                                      " This comment will be permanently deleted. You'll no longer to see and find this comment",
                                                  onConfirm: () {
                                                    vm.deleteComment(comment);
                                                    AmitySuccessDialog
                                                        .showTimedDialog(
                                                            "Success",
                                                            context: context);
                                                    Navigator.pop(context);
                                                  });
                                            },
                                          ),
                                  ]);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
          });
    });
  }
}
