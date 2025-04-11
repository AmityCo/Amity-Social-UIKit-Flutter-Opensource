import 'dart:math';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:amity_uikit_beta_service/amity_uikit.dart';
import 'package:amity_uikit_beta_service/v4/core/base_element.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/core/ui/expandable_text.dart';
import 'package:amity_uikit_beta_service/v4/core/ui/mention/mention_field.dart';
import 'package:amity_uikit_beta_service/v4/core/ui/mention/mention_text_editing_controller.dart';
import 'package:amity_uikit_beta_service/v4/social/comment/comment_extention.dart';
import 'package:amity_uikit_beta_service/v4/social/comment/comment_item/bloc/comment_item_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/comment/comment_item/comment_action.dart';
import 'package:amity_uikit_beta_service/v4/social/comment/comment_list/bloc/comment_list_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/comment/comment_list/reply_list.dart';
import 'package:amity_uikit_beta_service/v4/social/post/common/post_moderator_badge.dart';
import 'package:amity_uikit_beta_service/v4/social/reaction/reaction_list.dart';
import 'package:amity_uikit_beta_service/v4/utils/compact_string_converter.dart';
import 'package:amity_uikit_beta_service/v4/utils/date_time_extension.dart';
import 'package:amity_uikit_beta_service/v4/utils/user_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class CommentItem extends BaseElement {
  final ScrollController parentScrollController;
  final CommentAction commentAction;
  final MentionTextEditingController controller =
      MentionTextEditingController();
  final ScrollController scrollController = ScrollController();
  final bool shouldAllowInteraction;

  CommentItem({
    Key? key,
    String? pageId,
    String? componentId,
    required this.shouldAllowInteraction,
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
      final plainText = state.editedText;
      var mentionList = <AmityUserMentionMetadata>[];

      if (state.comment.metadata != null) {
        final mentionedGetter =
            AmityMentionMetadataGetter(metadata: state.comment.metadata!);
        mentionList = mentionedGetter.getMentionedUsers();
      }

      // Only call populate if the incoming plainText is different.
      if (plainText != controller.text) {
        controller.populate(plainText, mentionList);
      }

      return buildCommentItem(context, state.comment, state.isReacting,
          state.isExpanded, state.isEditing);
    });
  }

  Widget buildCommentItem(BuildContext context, AmityComment comment,
      bool isReacting, bool isExpanded, bool isEditing) {
    var isModerator = false;
    var communityId = null;
    if (comment.target is CommunityCommentTarget) {
      var roles =
          (comment.target as CommunityCommentTarget).creatorMember?.roles;
      if (roles != null &&
          (roles.contains("moderator") ||
              roles.contains("community-moderator"))) {
        isModerator = true;
      }
      communityId = (comment.target as CommunityCommentTarget).communityId;
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
          GestureDetector(
            onTap: () {
              final userId = comment.user?.userId;
              if (userId != null && userId.isNotEmpty) {
                AmityUIKit4Manager.behavior.commentTrayBehavior.goToUserProfilePage(context, userId);
              }
            },
            child: SizedBox(
              width: 32,
              height: 32,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: AmityUserImage(
                  user: comment.user,
                  theme: theme,
                  size: 32,
                ),
              ),
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
                                          final userId = comment.user?.userId;
                                          if (userId != null && userId.isNotEmpty) {
                                            AmityUIKit4Manager.behavior.commentTrayBehavior.goToUserProfilePage(context, userId);
                                          }
                                        },
                                        child: Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                comment.user?.displayName ?? "",
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                style: AmityTextStyle.custom(
                                                    15,
                                                    FontWeight.w500,
                                                    theme.baseColor),
                                              ),
                                            ),
                                            if (comment.user?.isBrand ?? false)
                                              brandBadge(),
                                          ],
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
                                    getCommentTextContent(
                                        context, comment, theme)
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
                                                child: MentionTextField(
                                                  theme: theme,
                                                  suggestionMaxRow: 2,
                                                  suggestionDisplayMode:
                                                      SuggestionDisplayMode
                                                          .inline,
                                                  mentionContentType:
                                                      MentionContentType
                                                          .comment,
                                                  communityId: communityId,
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
                                                        context.l10n.comment_create_hint,
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
                        height: 120, // Maintain fixed height for edit bubble
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
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              // Wrap in Expanded to constrain the child within available space
                              child: Container(
                                alignment: Alignment.topLeft,
                                width: double.infinity,
                                child: Scrollbar(
                                  controller: scrollController,
                                  thumbVisibility: true,
                                  child: SingleChildScrollView(
                                    // Add SingleChildScrollView for scrolling
                                    controller: scrollController,
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: MentionTextField(
                                        theme: theme,
                                        suggestionMaxRow: 2,
                                        suggestionDisplayMode:
                                            SuggestionDisplayMode.inline,
                                        mentionContentType:
                                            MentionContentType.comment,
                                        communityId: communityId,
                                        controller: controller,
                                        scrollController:
                                            null, // Remove the scrollController from TextField as we're using it on the SingleChildScrollView
                                        onChanged: (value) {},
                                        keyboardType: TextInputType.multiline,
                                        maxLines: null,
                                        minLines: 1,
                                        textAlignVertical: TextAlignVertical
                                            .top, // Align text at the top
                                        decoration: InputDecoration(
                                          isDense: true,
                                          contentPadding: const EdgeInsets.symmetric(
                                              horizontal: 0, vertical: 0),
                                          hintText: context.l10n.comment_create_hint,
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
                            ),
                          ],
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

  Widget getCommentTextContent(
      BuildContext context, AmityComment comment, AmityThemeColor theme) {
    // Get the text content from the comment.
    final String textContent = comment.data is CommentTextData
        ? (comment.data as CommentTextData).text ?? ""
        : "";

    // Define normal and mention styles.
    final normalStyle = TextStyle(
      color: theme.baseColor,
      fontSize: 15,
      fontWeight: FontWeight.w400,
    );
    final mentionStyle = TextStyle(
      color: theme.highlightColor,
      fontSize: 15,
      fontWeight: FontWeight.w400,
    );

    List<AmityUserMentionMetadata>? mentionedUsers;

    if (comment.metadata != null && comment.metadata!['mentioned'] != null) {
      // Obtain the mention metadata from the comment.
      final mentionedGetter =
          AmityMentionMetadataGetter(metadata: comment.metadata!);
      mentionedUsers = mentionedGetter.getMentionedUsers();

      // Sort mention metadata by starting index.
      mentionedUsers.sort((a, b) => a.index.compareTo(b.index));
    }

    return ExpandableText(
      text: textContent,
      mentionedUsers: mentionedUsers,
      maxLines: 8,
      style: normalStyle,
      linkStyle: mentionStyle,
      useLayoutBuilder: false,
      onMentionTap: (userId) => _goToUserProfilePage(context, userId),
    );
  }

  Widget renderCommentBottom(
      BuildContext context, AmityComment comment, bool isReacting) {
    return shouldAllowInteraction
        ? Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "${comment.createdAt?.toSocialTimestamp() ?? ""}${(comment.editedAt != comment.createdAt) ? context.l10n.general_edited_suffix : ""}",
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
                        context.l10n.comment_reply,
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
              renderReactionPreview(
                  context, comment, isReacting, shouldAllowInteraction),
            ],
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              renderReactionPreview(
                  context, comment, isReacting, shouldAllowInteraction),
            ],
          );
  }

  Widget renderReactionButton(
      BuildContext context, AmityComment comment, bool isReacting) {
    final hasMyReaction = comment.hasMyReactions();
    if (isReacting) {
      return (hasMyReaction)
          ? Text(
              context.l10n.post_like,
              style: TextStyle(
                color: theme.baseColorShade2,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            )
          : Text(
              context.l10n.post_like,
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
                context.l10n.post_like,
                style: TextStyle(
                  color: theme.primaryColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              )
            : Text(
                context.l10n.post_like,
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
                        context.l10n.comment_view_reply_count(childrenNumber),
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
              child: ReplyList(
                  shouldAllowInteraction: shouldAllowInteraction,
                  scrollController: scrollController),
            ),
          ],
        ),
      ),
    );
  }

  Widget renderReactionPreview(BuildContext context, AmityComment comment,
      bool isReacting, bool shouldAllowInteraction) {
    final hasMyReactions = comment.hasMyReactions();
    var reactionCount = comment.reactionCount ?? 0;
    if (isReacting) {
      reactionCount = (hasMyReactions) ? reactionCount - 1 : reactionCount + 1;
    }
    if (reactionCount > 0) {
      return Expanded(
        child: Row(
          mainAxisAlignment: shouldAllowInteraction
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
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
                child: AmityReactionList(
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
          (comment.parentId == null) ? context.l10n.comment_unreport : context.l10n.comment_reply_unreport;
    } else {
      reportButtonLabel =
          (comment.parentId == null) ? context.l10n.comment_report : context.l10n.comment_reply_report;
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
                              ? context.l10n.comment_edit
                              : context.l10n.comment_reply_edit,
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
                              ? context.l10n.comment_delete
                              : context.l10n.comment_reply_delete),
                          content: Text(
                              context.l10n.comment_delete_description(
                              (comment.parentId == null)
                                  ? context.l10n.post_comment.toLowerCase()
                                  : context.l10n.comment_reply.toLowerCase())),
                          actions: [
                            CupertinoDialogAction(
                              child: Text(context.l10n.general_cancel,
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
                                context.l10n.general_delete,
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
                              ? context.l10n.comment_delete
                              : context.l10n.comment_reply_delete,
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
        final hasChanges = state.editedText.trim() != commentText.trim() &&
            state.editedText.trim().isNotEmpty;
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
                            context.l10n.general_cancel,
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
                        commentId: comment.commentId!,
                        text: controller.text,
                        mentionMetadataList:
                            controller.getAmityMentionMetadata(),
                        mentionUserIds: controller.getMentionUserIds()))
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
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            context.l10n.general_save,
                            style: const TextStyle(
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

  Widget brandBadge() {
    return Container(
      padding: const EdgeInsets.only(left: 4),
      child: SvgPicture.asset(
        'assets/Icons/amity_ic_brand.svg',
        package: 'amity_uikit_beta_service',
        fit: BoxFit.fill,
        width: 18,
        height: 18,
      ),
    );
  }

  void _goToUserProfilePage(BuildContext context, String userId) {
    AmityUIKit4Manager.behavior.commentTrayBehavior.goToUserProfilePage(
      context,
      userId,
    );
  }
}
