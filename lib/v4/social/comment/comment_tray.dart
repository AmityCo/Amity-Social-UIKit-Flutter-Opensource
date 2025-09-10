import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/amity_uikit.dart';
import 'package:amity_uikit_beta_service/v4/core/base_component.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/social/comment/comment_creator/comment_creator.dart';
import 'package:amity_uikit_beta_service/v4/social/comment/comment_creator/comment_creator_action.dart';
import 'package:amity_uikit_beta_service/v4/social/comment/comment_item/comment_action.dart';
import 'package:amity_uikit_beta_service/v4/social/comment/comment_list/comment_list_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AmityCommentTrayComponent extends NewBaseComponent {
  final String referenceId;
  final AmityCommentReferenceType referenceType;
  final AmityCommunity? community;
  final bool shouldAllowInteraction;
  final bool shouldAllowComments;
  final ScrollController scrollController;
  String? pageId;
  AmityCommentTrayComponent({
    super.key,
    required this.referenceId,
    required this.referenceType,
    this.pageId,
    this.community,
    required this.shouldAllowInteraction,
    required this.shouldAllowComments,
    required this.scrollController,
  }) : super(
          pageId: pageId,
          componentId: "comment_tray_component",
        );

  @override
  Widget buildComponent(BuildContext context) {
    return CommentTrayComponent(
      referenceId: referenceId,
      theme: theme,
      shouldAllowInteraction: shouldAllowInteraction,
      shouldAllowComments: shouldAllowComments,
      scrollController: scrollController,
      referenceType: referenceType,
      community: community, // Add this missing parameter
    );
  }
}

class CommentTrayComponent extends StatefulWidget {
  final String referenceId;
  final bool shouldAllowInteraction;
  final bool shouldAllowComments;
  final AmityCommentReferenceType referenceType;
  final ScrollController scrollController;
  final AmityCommunity? community; // Add this missing property
  AmityThemeColor theme;
  CommentTrayComponent({
    super.key,
    required this.theme,
    required this.referenceId,
    required this.referenceType,
    required this.shouldAllowInteraction,
    required this.shouldAllowComments,
    required this.scrollController,
    this.community, // Include in constructor
  });

  final _getText =
      AmityUIKit4Manager.freedomBehavior.localizationBehavior.getText;

  @override
  State<CommentTrayComponent> createState() => _CommentTrayComponentState();
}

class _CommentTrayComponentState extends State<CommentTrayComponent> {
  AmityComment? replyToComment;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      decoration: BoxDecoration(
        color: widget.theme.backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0), // Adjust the radius value as needed
          topRight: Radius.circular(20.0),
        ),
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        body: SizedBox(
          height: double.infinity,
          child: Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  shrinkWrap: true,
                  controller: widget.scrollController,
                  slivers: [
                    SliverAppBar(
                      title: Text(
                        widget._getText(context, 'story_comments_title') ??
                            'Comments',
                      ),
                      titleTextStyle: TextStyle(
                        color: widget.theme.baseColor,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      backgroundColor: widget.theme.backgroundColor,
                      foregroundColor: Colors.white,
                      pinned: true,
                      automaticallyImplyLeading: false,
                      centerTitle: true,
                    ),
                    SliverToBoxAdapter(
                      child: getSectionDivider(widget.theme.baseColorShade4),
                    ),
                    SliverPadding(
                      padding:
                          const EdgeInsets.only(left: 12, right: 16, top: 7),
                      sliver: AmityCommentListComponent(
                        referenceId: widget.referenceId,
                        referenceType: widget.referenceType,
                        shouldAllowInteraction: widget.shouldAllowInteraction,
                        parentScrollController: widget.scrollController,
                        commentAction: CommentAction(
                          onReply: (AmityComment? comment) {
                            setState(
                              () {
                                replyToComment = comment;
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.shouldAllowInteraction)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    children: [
                      getSectionDivider(widget.theme.baseColorShade4),
                      (widget.shouldAllowComments)
                          ? AmityCommentCreator(
                              referenceType: widget.referenceType,
                              referenceId: widget.referenceId,
                              replyTo: replyToComment,
                              action: CommentCreatorAction(
                                onDissmiss: () {
                                  removeReplyToComment();
                                },
                              ),
                              communityId: widget.community?.communityId,
                            )
                          : Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    'assets/Icons/ic_lock_gray.svg',
                                    package: 'amity_uikit_beta_service',
                                    height: 16,
                                  ),
                                  const SizedBox(width: 16),
                                  const Text(
                                    "Comments are disabled for this story",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontFamily: "SF Pro Text",
                                      color: Color(
                                        0xff898E9E,
                                      ),
                                    ),
                                  ),
                                ],
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
  }

  removeReplyToComment() {
    setState(
      () {
        replyToComment = null;
      },
    );
  }

  Widget getSectionDivider(Color color) {
    return Container(
      width: double.infinity,
      height: 1,
      color: color,
    );
  }
}
