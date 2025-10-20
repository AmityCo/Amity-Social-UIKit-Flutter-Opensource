import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:amity_uikit_beta_service/v4/core/base_component.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/social/community/pending_posts/amity_pending_post_content_component.dart';
import 'package:amity_uikit_beta_service/v4/social/community/pending_posts/pending_posts_cubit.dart';
import 'package:amity_uikit_beta_service/v4/social/community/pending_posts/pending_posts_state.dart';
import 'package:amity_uikit_beta_service/v4/social/globalfeed/amity_global_feed_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AmityPendingPostListComponent extends NewBaseComponent {
  final AmityCommunity community;
  final Function(List<AmityPost>)? onPendingPostsLoaded;
  final ScrollController _scrollController = ScrollController();

  AmityPendingPostListComponent({
    Key? key,
    required this.community,
    required String pageId,
    this.onPendingPostsLoaded,
  }) : super(key: key, pageId: pageId, componentId: 'pendingPostListComponent');

  @override
  Widget buildComponent(BuildContext context) {
    return BlocProvider(
      create: (context) => PendingPostsCubit(
        community: community,
      ),
      child: BlocConsumer<PendingPostsCubit, PendingPostsState>(
        listenWhen: (previous, current) =>
            previous.posts.length != current.posts.length,
        listener: (context, state) {},
        builder: (context, state) {
          // Check if content is not scrollable and load more if possible
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients && 
                !state.isLoading &&
                !state.loadingMore &&
                _scrollController.position.maxScrollExtent <= 0) {
              context.read<PendingPostsCubit>().postLiveCollection.loadNext();
            }
          });

          if (!state.isLoading &&
              !state.hasError &&
              onPendingPostsLoaded != null) {
            onPendingPostsLoaded!(state.posts);
          }
          return _buildContent(context, state);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, PendingPostsState state) {
    return Column(
      children: [
        if (state.isModerator)
          Container(
            height: 60,
            color: theme.backgroundShade1Color,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  context.l10n.community_pending_posts_warning,
                  style: AmityTextStyle.caption(theme.baseColor),
                ),
              ),
            ),
          ),
        Expanded(
          child: state.showLoading
              ? FeedSkeleton(theme, configProvider)
              : state.posts.isEmpty
                  ? _buildEmptyView(context)
                  : _buildPostListView(context, state),
        ),
      ],
    );
  }

  Widget _buildEmptyView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/Icons/amity_ic_pending_post_empty.svg',
            package: 'amity_uikit_beta_service',
            width: 60,
            height: 60,
          ),
          const SizedBox(height: 8),
          Text(context.l10n.community_pending_posts_empty,
              style: AmityTextStyle.titleBold(theme.baseColorShade3)),
        ],
      ),
    );
  }

  Widget _buildPostListView(BuildContext context, PendingPostsState state) {
    return RefreshIndicator(
      backgroundColor: theme.backgroundColor,
      onRefresh: () async {
        final cubit = context.read<PendingPostsCubit>();

        cubit.recheckUserRole();

        await cubit.getPendingCommunityFeedPosts();
      },
      child: ListView.separated(
        controller: _scrollController,
        key: ValueKey('pending_posts_list_${community.communityId}'),
        itemCount: state.posts.length,
        separatorBuilder: (context, index) =>
            Divider(height: 8, thickness: 8, color: theme.baseColorShade4),
        itemBuilder: (context, index) {
          final post = state.posts[index];

          // Load more posts when reaching near the end of the list
          if (index >= state.posts.length - 3 && !state.loadingMore) {
            context.read<PendingPostsCubit>().loadMorePosts();
          }

          return AmityPendingPostContentComponent(
            key: ValueKey('post_${post.postId}'),
            post: post,
            pageId: pageId ?? 'communityPendingPostPage',
            isModerator: state.isModerator,
            onDelete: () {
              context
                  .read<PendingPostsCubit>()
                  .handlePostAction(post.postId!, true);
            },
          );
        },
      ),
    );
  }
}
