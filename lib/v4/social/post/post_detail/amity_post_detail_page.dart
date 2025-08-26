
import 'dart:developer';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:amity_uikit_beta_service/v4/core/base_page.dart';
import 'package:amity_uikit_beta_service/v4/social/comment/comment_creator/comment_creator.dart';
import 'package:amity_uikit_beta_service/v4/social/comment/comment_creator/comment_creator_action.dart';
import 'package:amity_uikit_beta_service/v4/social/comment/comment_item/comment_action.dart';
import 'package:amity_uikit_beta_service/v4/social/comment/comment_list/comment_list_component.dart';
import 'package:amity_uikit_beta_service/v4/social/post/amity_post_content_component.dart';
import 'package:amity_uikit_beta_service/v4/social/post/common/post_action.dart';
import 'package:amity_uikit_beta_service/v4/social/post/post_detail/bloc/post_detail_bloc.dart';
import 'package:amity_uikit_beta_service/v4/utils/shimmer_widget.dart';
import 'package:amity_uikit_beta_service/v4/utils/skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AmityPostDetailPage extends NewBasePage {
  final String postId;
  final AmityPost? post;
  final AmityPostCategory category;
  final bool hideMenu;
  final AmityPostAction? action;

  AmityPostDetailPage({
    Key? key,
    required this.postId,
    this.post,
    this.category = AmityPostCategory.general,
    this.hideMenu = false,
    this.action,
  }) : super(key: key, pageId: 'post_detail_page');

  @override
  Widget buildPage(BuildContext context) {
    return BlocProvider(
      create: (context) => PostDetailBloc(postId: postId, post: post),
      child: BlocBuilder<PostDetailBloc, PostDetailState>(
          builder: (context, state) {
        return Scaffold(
          backgroundColor: theme.backgroundColor,
          body: buildPostDetail(context, state),
        );
      }),
    );
  }

  Widget buildPostDetail(BuildContext context, PostDetailState state) {
    if (state is PostDetailStateInitial) {
      context.read<PostDetailBloc>().add(
          PostDetailLoad(postId: (state as PostDetailStateInitial).postId));
      return Container(
          padding: const EdgeInsets.only(top: 74),
          decoration: BoxDecoration(color: theme.backgroundColor),
          child: showShimmerContent(context));
    } else if (state is PostDetailStateError) {
      return Text(state.message);
    } else if (state is PostDetailStateLoaded) {
      return renderPage(
          context: context,
          post: state.post,
          replyTo: state.replyTo,
          category: category,
          hideMenu: hideMenu);
    } else {
      return Container();
    }
  }

  Widget renderPage({
    required BuildContext context,
    required AmityPost post,
    AmityComment? replyTo,
    required AmityPostCategory category,
    required bool hideMenu,
  }) {
    ScrollController scrollController = ScrollController();
    var isJoinedCommunity = true;
    String? communityId;
    if (post.target is CommunityTarget) {
      final target = post.target as CommunityTarget;
      final community = target.targetCommunity;
      isJoinedCommunity = community?.isJoined ?? true;
      communityId = target.targetCommunityId;
      log("communityId: $communityId");
    }
    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverAppBar(
                backgroundColor: theme.backgroundColor,
                title: Text(context.l10n.general_post),
                titleTextStyle: TextStyle(
                  color: theme.baseColor,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
                pinned: true,
                centerTitle: true,
              ),
              SliverToBoxAdapter(
                child: Container(
                  child: renderPost(
                    context: context,
                    post: post,
                    category: category,
                    hideMenu: hideMenu,
                    scrollController: scrollController,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.only(left: 12, right: 16, top: 7),
                sliver: AmityCommentListComponent(
                  referenceId: postId,
                  referenceType: AmityCommentReferenceType.POST,
                  shouldAllowInteraction: isJoinedCommunity,
                  parentScrollController: scrollController,
                  commentAction:
                      CommentAction(onReply: (AmityComment? comment) {
                    context
                        .read<PostDetailBloc>()
                        .add(PostDetailReplyComment(replyTo: comment));
                  }),
                ),
              ),
            ],
          ),
        ),
        if (!hideMenu) ...[
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              children: [
                getSectionDivider(),
                AmityCommentCreator(
                  referenceId: postId,
                  referenceType: AmityCommentReferenceType.POST,
                  communityId: communityId,
                  replyTo: replyTo,
                  action: CommentCreatorAction(onDissmiss: () {
                    context
                        .read<PostDetailBloc>()
                        .add(const PostDetailReplyComment(replyTo: null));
                  }),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget renderPost({
    required BuildContext context,
    required AmityPost post,
    required AmityPostCategory category,
    required bool hideMenu,
    required ScrollController scrollController,
  }) {
    return Column(
      children: [
        AmityPostContentComponent(
          style: AmityPostContentComponentStyle.detail,
          post: post,
          category: category,
          hideMenu: hideMenu,
          action: action,
        ),
        getSectionDivider(),
      ],
    );
  }

  Widget getSectionDivider() {
    return Container(
      width: double.infinity,
      height: 1,
      color: theme.baseColorShade4,
    );
  }

  Widget showShimmerContent(BuildContext context) {
    return Shimmer(
      linearGradient: configProvider.getShimmerGradient(),
      child: ShimmerLoading(
        isLoading: true,
        child: SizedBox(
          height: 180,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 19),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 60,
                      padding: const EdgeInsets.only(
                          top: 12, left: 0, right: 8, bottom: 8),
                      child: const SkeletonImage(
                        height: 40,
                        width: 40,
                        borderRadius: 40,
                      ),
                    ),
                    const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 6.0),
                          SkeletonText(width: 120),
                          SizedBox(height: 12.0),
                          SkeletonText(width: 88),
                        ]),
                  ],
                ),
                const SizedBox(height: 14.0),
                const SkeletonText(width: 240),
                const SizedBox(height: 12.0),
                const SkeletonText(width: 297),
                const SizedBox(height: 12.0),
                const SkeletonText(width: 180),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
