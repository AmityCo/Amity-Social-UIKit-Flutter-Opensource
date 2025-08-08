import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/base_component.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/social/globalfeed/amity_empty_newsfeed_component.dart';
import 'package:amity_uikit_beta_service/v4/social/globalfeed/bloc/global_feed_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/post/amity_post_content_component.dart';
import 'package:amity_uikit_beta_service/v4/social/post/common/post_action.dart';
import 'package:amity_uikit_beta_service/v4/social/story/target/amity_story_tab_component.dart';
import 'package:amity_uikit_beta_service/v4/social/story/target/amity_story_tab_component_type.dart';
import 'package:amity_uikit_beta_service/v4/utils/bloc_extension.dart';
import 'package:amity_uikit_beta_service/v4/utils/config_provider.dart';
import 'package:amity_uikit_beta_service/v4/utils/shimmer_widget.dart';
import 'package:amity_uikit_beta_service/v4/utils/skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visibility_detector/visibility_detector.dart';

class AmityGlobalFeedComponent extends NewBaseComponent {
  AmityGlobalFeedComponent({Key? key, String? pageId})
      : super(key: key, pageId: pageId, componentId: 'global_feed_component');

  List<String> viewedPost = [];

  @override
  Widget buildComponent(BuildContext context) {
    final scrollController = ScrollController();

    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        context.read<GlobalFeedBloc>().addEvent(GlobalFeedLoadNext());
      }
    });
    return Container(
      color: theme.backgroundColor,
      child: BlocBuilder<GlobalFeedBloc, GlobalFeedState>(
          builder: (context, state) {
        if (state.isFetching && state.list.isEmpty) {
          viewedPost = [];
          return FeedSkeleton(theme, configProvider);
        } else {
          return BaseComponent(
              child: Container(
            width: double.infinity,
            decoration: BoxDecoration(color: theme.baseColorShade4),
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<GlobalFeedBloc>().add(GlobalFeedRefresh());
              },
              child: CustomScrollView(
                controller: scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: Visibility(
                      visible: configProvider.getFeatureConfig().story.viewStoryTabEnabled,
                      child: AmityStoryTabComponent(
                        type: GlobalFeedStoryTab(),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                      child: Container(
                    color: theme.baseColorShade4,
                    height: 8,
                  )),
                  if (state.list.isNotEmpty)
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final amityPost = state.list[index];

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
                                final visiblePercentage =
                                    info.visibleFraction * 100;
                                if (visiblePercentage > 60) {
                                  checkVisibilityAndMarkSeen(
                                      amityPost, visiblePercentage);
                                }
                              },
                              child: Column(
                                children: [
                                  AmityPostContentComponent(
                                      style:
                                          AmityPostContentComponentStyle.feed,
                                      post: amityPost,
                                      category: (state.pinnedPostIds
                                              .contains(amityPost.postId))
                                          ? AmityPostCategory.globalFeatured
                                          : AmityPostCategory.general,
                                      key: uniqueKey,
                                      hideTarget: false,
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
                        childCount: state.list.length,
                      ),
                    )
                  else
                    SliverFillRemaining(
                      child: Container(
                        color: theme.backgroundColor,
                        alignment: Alignment.center,
                        child: state.isFetching
                            ? const CircularProgressIndicator()
                            : AmityEmptyNewsFeedComponent(
                                pageId: pageId,
                              ),
                      ),
                    ),
                  if (state.isFetching && state.list.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(),
                      ),
                    ),
                ],
              ),
            ),
          ));
        }
      }),
    );
  }

  void checkVisibilityAndMarkSeen(AmityPost post, double visiblePercentage) {
    if (visiblePercentage > 60 && !viewedPost.contains(post.postId)) {
      viewedPost.add(post.postId!);
      post.analytics().markPostAsViewed();
    }
  }
}

Widget FeedSkeleton(AmityThemeColor theme, ConfigProvider configProvider) {
  return Container(
    color: theme.backgroundColor,
    width: double.infinity,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Shimmer(
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
        ),
      ],
    ),
  );
}

Widget skeletonRow() {
  return Container(
    height: 200,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SkeletonCircle(
                size: 32,
              ),
              const SizedBox(
                width: 8,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonRectangle(
                    height: 8,
                    width: 180,
                  ),
                  const SizedBox(height: 8),
                  SkeletonRectangle(
                    height: 8,
                    width: 64,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          SkeletonRectangle(
            height: 8,
            width: 240,
          ),
          const SizedBox(
            height: 12,
          ),
          SkeletonRectangle(
            height: 8,
            width: 180,
          ),
          const SizedBox(
            height: 12,
          ),
          SkeletonRectangle(
            height: 8,
            width: 290,
          )
        ],
      ),
    ),
  );
}
