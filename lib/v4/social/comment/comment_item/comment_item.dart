import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/base_element.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/comment/comment_extention.dart';
import 'package:amity_uikit_beta_service/v4/social/comment/comment_item/bloc/comment_item_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/comment/comment_item/comment_action.dart';
import 'package:amity_uikit_beta_service/v4/social/comment/comment_list/bloc/comment_list_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/comment/comment_list/reply_list.dart';
import 'package:amity_uikit_beta_service/v4/social/post/common/post_moderator_badge.dart';
import 'package:amity_uikit_beta_service/v4/social/reaction/reaction_list.dart';
import 'package:amity_uikit_beta_service/v4/utils/compact_string_converter.dart';
import 'package:amity_uikit_beta_service/v4/utils/date_time_extension.dart';
import 'package:amity_uikit_beta_service/v4/utils/network_image.dart';
import 'package:amity_uikit_beta_service/view/user/user_profile_v2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class CommentItem extends BaseElement {
  final ScrollController parentScrollController;
  final CommentAction commentAction;
  final TextEditingController controller = TextEditingController();
  final ScrollController scrollController = ScrollController();

  CommentItem({
    Key? key,
    String? pageId,
    String? componentId,
    required this.parentScrollController,
    required this.commentAction,
  }) : super(
            key: key,
            pageId: pageId,
            componentId: componentId,
            elementId: 'comment');

  @override
  Widget buildElement(BuildContext context) {
    return BlocBuilder<CommentItemBloc, CommentItemState>(
        builder: (context, state) {
      controller.text = state.editedText;
      return buildCommentItem(context, state.comment, state.isReacting,
          state.isExpanded, state.isEditing);
    });
  }

  Widget buildCommentItem(BuildContext context, AmityComment comment,
      bool isReacting, bool isExpanded, bool isEditing) {
    var isModerator = false;
    if (comment.target is CommunityCommentTarget) {
      var roles =
          (comment.target as CommunityCommentTarget).creatorMember?.roles;
      if (roles != null &&
          (roles.contains("moderator") ||
              roles.contains("community-moderator"))) {
        isModerator = true;
      }
    }
    controller.addListener(() {
      context.read<CommentItemBloc>().add(
            CommentItemEditChanged(text: controller.text),
          );
    });
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 0, right: 0, top: 4, bottom: 12),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: AmityNetworkImage(
                  imageUrl: comment.user?.avatarUrl,
                  placeHolderPath:
                      "assets/Icons/amity_ic_user_avatar_placeholder.svg"),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                (!isEditing)
                    ? IntrinsicWidth(
                        child: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.all(12),
                          decoration: ShapeDecoration(
                            color: theme.baseColorShade4,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(12),
                                bottomLeft: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ),
                            ),
                          ),
                          child: (!isEditing)
                              ? Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  UserProfileScreen(
                                                amityUserId:
                                                    comment.user?.userId ?? '',
                                                amityUser: null,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          comment.user?.displayName ?? "",
                                          style: TextStyle(
                                            color: theme.baseColor,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                    (isModerator)
                                        ? const Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 4, horizontal: 0),
                                            child: CommunityModeratorBadge(),
                                          )
                                        : Container(),
                                    Flexible(
                                      fit: FlexFit.loose,
                                      child: Text(
                                        // "To make a SizedBox in Flutter wrap its content in terms of height, you cannot directly achieve this because SizedBox requires explicit width and height values. However, you can use alternative widgets like Wrap, FittedBox, or FractionallySizedBox to achieve similar effects based on the content size or parent constraints.",
                                        comment.data is CommentTextData
                                            ? (comment.data as CommentTextData)
                                                    .text ??
                                                ""
                                            : "",

                                        softWrap: true,
                                        overflow: TextOverflow.visible,
                                        style: TextStyle(
                                          color: theme.baseColor,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : SizedBox(
                                  width: double.infinity,
                                  child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(12),
                                          child: SizedBox(
                                            width: double.infinity,
                                            child: MediaQuery.removePadding(
                                              // Remove padding to fix wrong scroll indicator position
                                              context: context,
                                              removeTop: true,
                                              removeBottom: true,
                                              child: Scrollbar(
                                                controller: scrollController,
                                                child: TextField(
                                                  controller: controller,
                                                  scrollController:
                                                      scrollController,
                                                  onChanged: (value) {},
                                                  keyboardType:
                                                      TextInputType.multiline,
                                                  maxLines: null,
                                                  minLines: 1,
                                                  textAlignVertical:
                                                      TextAlignVertical.bottom,
                                                  decoration: InputDecoration(
                                                    isDense: true,
                                                    contentPadding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 0,
                                                            vertical: 0),
                                                    hintText:
                                                        'Say something nice...',
                                                    border: InputBorder.none,
                                                    hintStyle: TextStyle(
                                                      color:
                                                          theme.baseColorShade2,
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ]),
                                ),
                        ),
                      )
                    : Container(
                        alignment: Alignment.topLeft,
                        height: 120,
                        decoration: ShapeDecoration(
                          color: theme.baseColorShade4,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                          ),
                        ),
                        child: Container(
                          alignment: Alignment.topLeft,
                          width: double.infinity,
                          child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  child: Container(
                                    alignment: Alignment.topLeft,
                                    width: double.infinity,
                                    child: MediaQuery.removePadding(
                                      // Remove padding to fix wrong scroll indicator position
                                      context: context,
                                      removeTop: true,
                                      removeBottom: true,
                                      removeLeft: true,
                                      removeRight: true,
                                      child: Scrollbar(
                                        controller: scrollController,
                                        child: TextField(
                                          controller: controller,
                                          scrollController: scrollController,
                                          onChanged: (value) {},
                                          keyboardType: TextInputType.multiline,
                                          maxLines: null,
                                          minLines: 1,
                                          textAlignVertical:
                                              TextAlignVertical.bottom,
                                          decoration: InputDecoration(
                                            isDense: true,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 0, vertical: 0),
                                            hintText: 'Say something nice...',
                                            border: InputBorder.none,
                                            hintStyle: TextStyle(
                                              color: theme.baseColor,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ]),
                        ),
                      ),
                const SizedBox(height: 8),
                (isEditing)
                    ? renderCommentEditAction(context, comment)
                    : renderCommentBottom(context, comment, isReacting),
                (isExpanded)
                    ? renderReplyExpanded(comment, parentScrollController)
                    : renderReplyCollapsed(context, comment),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget renderCommentBottom(
      BuildContext context, AmityComment comment, bool isReacting) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "${comment.createdAt?.toSocialTimestamp() ?? ""}${(comment.editedAt != comment.createdAt) ? " (edited)" : ""}",
          style: TextStyle(
            color: theme.baseColorShade2,
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(width: 8),
        renderReactionButton(context, comment, isReacting),
        const SizedBox(width: 8),
        (comment.parentId == null)
            ? GestureDetector(
                onTap: () => {commentAction.onReply(comment)},
                child: Text(
                  'Reply',
                  style: TextStyle(
                    color: theme.baseColorShade2,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            : Container(),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            showCommentAction(context, comment);
          },
          child: Container(
            width: 20,
            height: 20,
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: SvgPicture.asset(
              'assets/Icons/amity_ic_post_item_option.svg',
              package: 'amity_uikit_beta_service',
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(
                theme.baseColorShade2,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
        renderReactionPreview(context, comment, isReacting),
      ],
    );
  }

  Widget renderReactionButton(
      BuildContext context, AmityComment comment, bool isReacting) {
    final hasMyReaction = comment.hasMyReactions();
    if (isReacting) {
      return (hasMyReaction)
          ? Text(
              'Like',
              style: TextStyle(
                color: theme.baseColorShade2,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            )
          : Text(
              'Liked',
              style: TextStyle(
                color: theme.primaryColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            );
    } else {
      return GestureDetector(
        onTap: () {
          if (hasMyReaction) {
            context.read<CommentItemBloc>().add(
                  RemoveReactionToComment(
                    comment: comment,
                    reactionType: comment.myReactions!.first,
                  ),
                );
          } else {
            context.read<CommentItemBloc>().add(
                  AddReactionToComment(
                    comment: comment,
                    reactionType: 'like',
                  ),
                );
          }
          HapticFeedback.lightImpact();
        },
        child: (hasMyReaction)
            ? Text(
                'Liked',
                style: TextStyle(
                  color: theme.primaryColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              )
            : Text(
                'Like',
                style: TextStyle(
                  color: theme.baseColorShade2,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
      );
    }
  }

  Widget renderReplyCollapsed(BuildContext context, AmityComment comment) {
    final int childrenNumber = comment.childrenNumber ?? 0;
    if (childrenNumber > 0) {
      return Container(
        padding: const EdgeInsets.only(top: 12, bottom: 4),
        child: GestureDetector(
          onTap: () {
            context
                .read<CommentListBloc>()
                .add(CommentListEventExpandItem(commentId: comment.commentId!));
          },
          child: Container(
            padding:
                const EdgeInsets.only(top: 5, left: 8, right: 12, bottom: 5),
            decoration: ShapeDecoration(
              color: theme.backgroundColor,
              shape: RoundedRectangleBorder(
                side: BorderSide(width: 1, color: theme.baseColorShade4),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: SvgPicture.asset(
                          'assets/Icons/amity_ic_expand_reply_comment.svg',
                          package: 'amity_uikit_beta_service',
                          width: 16,
                          height: 16,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'View $childrenNumber reply',
                        style: TextStyle(
                          color: theme.baseColorShade1,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget renderReplyExpanded(
      AmityComment comment, ScrollController scrollController) {
    final referenceId = comment.referenceId!;
    final referenceType = comment.referenceType!;
    return BlocProvider(
      create: (context) =>
          CommentListBloc(referenceId, referenceType, comment.commentId!),
      child: Container(
        padding: const EdgeInsets.only(top: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: ReplyList(scrollController: scrollController),
            ),
          ],
        ),
      ),
    );
  }

  Widget renderReactionPreview(
      BuildContext context, AmityComment comment, bool isReacting) {
    final hasMyReactions = comment.hasMyReactions();
    var reactionCount = comment.reactionCount ?? 0;
    if (isReacting) {
      reactionCount = (hasMyReactions) ? reactionCount - 1 : reactionCount + 1;
    }
    if (reactionCount > 0) {
      return Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            getReactionPreview(
              context,
              comment.commentId!,
              reactionCount,
              comment.hasReactions(),
              isReacting,
              hasMyReactions,
            ),
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  Widget getReactionPreview(
    BuildContext context,
    String commentId,
    int reactionCount,
    bool hasReactions,
    bool isReacting,
    bool hasMyReactions,
  ) {
    return Row(
      children: [
        getReactionCount(reactionCount),
        const SizedBox(width: 4),
        getReactionIcon(
            context, commentId, hasReactions, isReacting, hasMyReactions),
      ],
    );
  }

  Widget getReactionIcon(BuildContext context, String commentId,
      bool hasReactions, bool isReacting, bool hasMyReactions) {
    void showReactionsBottomSheet() {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(25.0),
          ),
        ),
        isScrollControlled: true,
        builder: (context) {
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.6,
            minChildSize: 0.25,
            maxChildSize: 0.75,
            builder: (BuildContext context, scrollController) {
              return Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                child: AmityReactionListComponent(
                  pageId: 'reactions_page',
                  referenceId: commentId,
                  referenceType: AmityReactionReferenceType.COMMENT,
                ),
              );
            },
          );
        },
      );
    }

    var showReactionIcon = hasReactions;
    if (isReacting) {
      showReactionIcon = !hasMyReactions;
    }
    if (showReactionIcon) {
      return GestureDetector(
        onTap: () {
          showReactionsBottomSheet();
        },
        child: SvgPicture.asset(
          'assets/Icons/amity_ic_post_reaction_like.svg',
          package: 'amity_uikit_beta_service',
          width: 20,
          height: 20,
        ),
      );
    } else {
      return Container();
    }
  }

  Widget getReactionCount(int reactionCount) {
    return Text(reactionCount.formattedCompactString(),
        style: TextStyle(
          color: theme.baseColorShade2,
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ));
  }

  void showCommentAction(BuildContext context, AmityComment comment) {
    final currentUserId = AmityCoreClient.getUserId();

    if (comment.userId == currentUserId) {
      showCommentModerationAction(context, comment);
    } else {
      showCommentGeneralAction(context, comment);
    }
  }

  void showCommentGeneralAction(BuildContext context, AmityComment comment) {
    onReport() => (comment.isFlaggedByMe)
        ? context.read<CommentItemBloc>().add(CommentItemUnFlag(
              comment: comment,
              toastBloc: context.read<AmityToastBloc>(),
            ))
        : context.read<CommentItemBloc>().add(CommentItemFlag(
              comment: comment,
              toastBloc: context.read<AmityToastBloc>(),
            ));
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        backgroundColor: theme.backgroundColor,
        builder: (BuildContext context) {
          return SizedBox(
            height: 140,
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 36,
                  padding: const EdgeInsets.only(top: 12, bottom: 20),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 36,
                        height: 4,
                        decoration: ShapeDecoration(
                          color: theme.baseColorShade3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                renderReportButton(context, comment, onReport),
              ],
            ),
          );
        });
  }

  Widget renderReportButton(
      BuildContext context, AmityComment comment, Function onReport) {
    final isFlaggedByMe = comment.isFlaggedByMe;
    var reportButtonLabel = "";
    if (isFlaggedByMe) {
      reportButtonLabel =
          (comment.parentId == null) ? 'Unreport comment' : "Unreport reply";
    } else {
      reportButtonLabel =
          (comment.parentId == null) ? 'Report comment' : "Report reply";
    }

    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onReport();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.only(top: 2, bottom: 2),
              child: SvgPicture.asset(
                'assets/Icons/amity_ic_flag.svg',
                package: 'amity_uikit_beta_service',
                width: 24,
                height: 20,
                colorFilter: ColorFilter.mode(
                  theme.baseInverseColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              reportButtonLabel,
              style: TextStyle(
                color: theme.baseColor,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showCommentModerationAction(BuildContext context, AmityComment comment) {
    onEdit() => context.read<CommentItemBloc>().add(CommentItemEdit());
    onDelete() => context
        .read<CommentItemBloc>()
        .add(CommentItemDelete(comment: comment));
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        builder: (BuildContext context) {
          return SizedBox(
            height: 196,
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 36,
                  padding: const EdgeInsets.only(top: 12, bottom: 20),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 36,
                        height: 4,
                        decoration: ShapeDecoration(
                          color: theme.baseColorShade3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    onEdit();
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 20),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(top: 2, bottom: 2),
                          child: SvgPicture.asset(
                            'assets/Icons/amity_ic_edit_comment.svg',
                            package: 'amity_uikit_beta_service',
                            width: 24,
                            height: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          (comment.parentId == null)
                              ? 'Edit comment'
                              : "Edit reply",
                          style: TextStyle(
                            color: theme.baseColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return CupertinoAlertDialog(
                          title: Text((comment.parentId == null)
                              ? "Delete comment"
                              : "Delete reply"),
                          content: Text(
                              "This ${(comment.parentId == null) ? "comment" : "reply"} will be permanently removed."),
                          actions: [
                            CupertinoDialogAction(
                              child: Text("Cancel",
                                  style: TextStyle(
                                    color: theme.primaryColor,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w400,
                                  )),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            CupertinoDialogAction(
                              child: Text(
                                "Delete",
                                style: TextStyle(
                                  color: theme.alertColor,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                                onDelete();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 20),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(top: 2, bottom: 2),
                          child: SvgPicture.asset(
                            'assets/Icons/amity_ic_delete.svg',
                            package: 'amity_uikit_beta_service',
                            width: 24,
                            height: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          (comment.parentId == null)
                              ? 'Delete comment'
                              : "Delete reply",
                          style: TextStyle(
                            color: theme.baseColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  Widget renderCommentEditAction(BuildContext context, AmityComment comment) {
    return BlocConsumer<CommentItemBloc, CommentItemState>(
      listener: (context, state) {},
      builder: (context, state) {
        final commentText = getTextComment(comment);
        final hasChanges = state.editedText.trim() != commentText.trim() && state.editedText.trim().isNotEmpty;
        return Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => {
                context.read<CommentItemBloc>().add(CommentItemCancelEdit())
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 1, color: theme.baseColorShade2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Cancel',
                            style: TextStyle(
                              color: theme.baseColorShade1,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => {
                if (hasChanges)
                  {
                    context.read<CommentItemBloc>().add(CommentItemUpdate(
                        commentId: comment.commentId!, text: controller.text))
                  }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: ShapeDecoration(
                  color: (hasChanges)
                      ? theme.primaryColor
                      : theme.primaryColor.withAlpha(100),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Save',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
