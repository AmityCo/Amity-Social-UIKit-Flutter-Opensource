import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/base_component.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/social/globalfeed/amity_global_feed_component.dart';
import 'package:amity_uikit_beta_service/v4/social/post/amity_post_content_component.dart';
import 'package:amity_uikit_beta_service/v4/social/post/common/post_action.dart';
import 'package:amity_uikit_beta_service/v4/social/user/feed/bloc/user_feed_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/user/feed/user_feed_empty_state_info.dart';
import 'package:amity_uikit_beta_service/v4/social/user/user_feed_empty_state.dart';
import 'package:amity_uikit_beta_service/v4/utils/config_provider.dart';
import 'package:amity_uikit_beta_service/v4/utils/shimmer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visibility_detector/visibility_detector.dart';

class UserFeedComponent extends NewBaseComponent {
  final String userId;
  List<String> viewedPosts = [];
  final AmityUserFollowInfo? userFollowInfo;

  late ScrollController scrollController;

  UserFeedComponent({
    super.key,
    String? pageId,
    required this.userId,
    ScrollController? scrollController,
    this.userFollowInfo,
  }) : super(componentId: "user_feed") {
    if (scrollController != null) {
      this.scrollController = scrollController;
    } else {
      this.scrollController = ScrollController();
    }
  }

  @override
  Widget buildComponent(BuildContext context) {
    return BlocProvider<UserFeedBloc>(
      create: (context) =>
          UserFeedBloc(userId: userId, scrollController: scrollController),
      child: BlocBuilder<UserFeedBloc, UserFeedState>(
        builder: (context, state) {
          if (state.posts.isEmpty && state.isLoading) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                getSkeleton(theme, configProvider),
              ],
            );
          } else if (!state.isLoading && state.posts.isEmpty) {
            final UserFeedEmptyStateInfo info;
            if (userFollowInfo?.status == AmityFollowStatus.BLOCKED) {
              info = getEmptyStateInfo(UserFeedEmptyStateType.blocked);
            } else {
              info = getEmptyStateInfo(
                  state.emptyState ?? UserFeedEmptyStateType.empty);
            }
            return UserFeedEmptyState(info: info);
          } else {
            return Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.posts.length,
                  itemBuilder: (context, index) {
                    final amityPost = state.posts[index];
                    if (((amityPost.children?.isNotEmpty ?? false) &&
                            (amityPost.children!.first.type ==
                                    AmityDataType.FILE ||
                                amityPost.children!.first.type ==
                                    AmityDataType.LIVESTREAM)) ||
                        (amityPost.isDeleted ?? false)) {
                      return Container();
                    } else {
                      var uniqueKey = UniqueKey();
                      return VisibilityDetector(
                        key: Key(amityPost.postId ?? ''),
                        onVisibilityChanged: (VisibilityInfo info) {
                          final visiblePercentage = info.visibleFraction * 100;
                          if (visiblePercentage > 60) {
                            checkVisibilityAndMarkSeen(
                                amityPost, visiblePercentage);
                          }
                        },
                        child: Column(
                          children: [
                            AmityPostContentComponent(
                                style: AmityPostContentComponentStyle.feed,
                                post: amityPost,
                                category: AmityPostCategory.general,
                                key: uniqueKey,
                                hideTarget: true,
                                hideMenu: false,
                                action: AmityPostAction(
                                  onAddReaction: (String) {},
                                  onRemoveReaction: (String) {},
                                  onPostDeleted: (AmityPost post) {},
                                  onPostUpdated: (post) {},
                                )),
                            const SizedBox(height: 8),
                          ],
                        ),
                      );
                    }
                  },
                ),
                if (state.isLoading && state.posts.isNotEmpty)
                  getSkeleton(theme, configProvider),
              ],
            );
          }
        },
      ),
    );
  }

  Widget getSkeleton(AmityThemeColor theme, ConfigProvider configProvider) {
    return Container(
      color: theme.backgroundColor,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer(
            linearGradient: configProvider.getShimmerGradient(),
            child: ListView.separated(
              padding: const EdgeInsets.all(0),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (context, index) {
                return Divider(
                  color: theme.baseColorShade4,
                  thickness: 8,
                );
              },
              itemBuilder: (context, index) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerLoading(
                      isLoading: true,
                      child: skeletonRow(),
                    ),
                  ],
                );
              },
              itemCount: 4,
            ),
          ),
        ],
      ),
    );
  }

  UserFeedEmptyStateInfo getEmptyStateInfo(UserFeedEmptyStateType type) {
    switch (type) {
      case UserFeedEmptyStateType.empty:
        return UserFeedEmptyStateInfo(
            "No posts yet", "", "assets/Icons/amity_ic_feed_empty.svg");
      case UserFeedEmptyStateType.blocked:
        return UserFeedEmptyStateInfo(
            "You've blocked this user",
            "Unblock to see their posts.",
            "assets/Icons/amity_ic_blocked_feed_empty_state.svg");
      case UserFeedEmptyStateType.private:
        return UserFeedEmptyStateInfo(
            "This account is private",
            "Follow this user to see their posts.",
            "assets/Icons/amity_ic_private_feed_empty_state.svg");
    }
  }

  void checkVisibilityAndMarkSeen(AmityPost post, double visiblePercentage) {
    if (visiblePercentage > 60 && !viewedPosts.contains(post.postId)) {
      viewedPosts.add(post.postId!);
      post.analytics().markPostAsViewed();
    }
  }
}
