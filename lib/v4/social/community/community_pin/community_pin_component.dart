import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/base_component.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_pin/bloc/community_pin_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/post/amity_post_content_component.dart';
import 'package:amity_uikit_beta_service/v4/social/post/common/post_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:visibility_detector/visibility_detector.dart';

class CommunityPinComponent extends NewBaseComponent {
  final String communityId;
  List<String> viewedPosts = [];

  late ScrollController scrollController;

  CommunityPinComponent({
    super.key,
    required this.communityId,
    ScrollController? scrollController,
  }) : super(componentId: "community_feed") {
    if (scrollController != null) {
      this.scrollController = scrollController;
    } else {
      this.scrollController = ScrollController();
    }
  }

  @override
  Widget buildComponent(BuildContext context) {
    return BlocProvider<CommunityPinBloc>(
      create: (context) => CommunityPinBloc(
          communityId: communityId, scrollController: scrollController),
      child: BlocBuilder<CommunityPinBloc, CommunityPinState>(
        builder: (context, state) {
          if (state.isFetching && state.pins.isEmpty) {
            return SliverToBoxAdapter(child: Container());
          } else if (state.pins.isEmpty) {
            return SliverToBoxAdapter(
                child: Container(
              padding: const EdgeInsets.only(bottom: 120),
              width: double.infinity,
              height: 550,
              color: theme.backgroundColor,
              child: getEmptyFeed(theme),
            ));
          } else {
            bool hasAnnouncement = state.announcements.any((element) =>
                state.pins.map((e) => e.postId).contains(element.postId));
            return SliverMainAxisGroup(
              slivers: [
                if (hasAnnouncement)
                  SliverList(
                      delegate: SliverChildBuilderDelegate(
                          childCount: state.announcements.length,
                          (context, index) {
                    return _getAnnouncementPost(index, state);
                  })),
                if (state.announcements.isNotEmpty)
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 8),
                  ),
                SliverList(
                    delegate: SliverChildBuilderDelegate(
                        childCount: state.pins.length, (context, index) {
                  return _getPinPost(index, state);
                })),
              ],
            );
          }
        },
      ),
    );
  }

  Widget getEmptyFeed(AmityThemeColor theme) {
    return Container(
      width: double.infinity,
      height: 138,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 60,
                  height: 45,
                  child: SvgPicture.asset(
                    'assets/Icons/amity_ic_feed_empty.svg',
                    package: 'amity_uikit_beta_service',
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 252,
            child: Text(
              'No pinned post yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.baseColorShade3,
                fontSize: 17,
                fontFamily: 'SF Pro Text',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void checkVisibilityAndMarkSeen(AmityPost post, double visiblePercentage) {
    if (visiblePercentage > 60 && !viewedPosts.contains(post.postId)) {
      viewedPosts.add(post.postId!);
      post.analytics().markPostAsViewed();
    }
  }

  Widget _getAnnouncementPost(int index, CommunityPinState state) {
    final post = state.announcements[index].post;
    if (post == null) {
      return Container();
    }
    final amityPost = post;
    if (((amityPost.children?.isNotEmpty ?? false) &&
            (amityPost.children!.first.type == AmityDataType.FILE ||
                amityPost.children!.first.type == AmityDataType.LIVESTREAM)) ||
        (amityPost.isDeleted ?? false)) {
      return Container();
    } else {
      var uniqueKey = UniqueKey();
      return VisibilityDetector(
        key: Key(amityPost.postId ?? ''),
        onVisibilityChanged: (VisibilityInfo info) {
          final visiblePercentage = info.visibleFraction * 100;
          if (visiblePercentage > 60) {
            checkVisibilityAndMarkSeen(amityPost, visiblePercentage);
          }
        },
        child: Column(
          children: [
            if (index > 0) const SizedBox(height: 8),
            AmityPostContentComponent(
                style: AmityPostContentComponentStyle.feed,
                post: amityPost,
                key: uniqueKey,
                category:
                    (state.pins.map((e) => e.postId).contains(amityPost.postId))
                        ? AmityPostCategory.announcementAndPin
                        : AmityPostCategory.announcement,
                hideTarget: true,
                action: AmityPostAction(
                  onAddReaction: (String) {},
                  onRemoveReaction: (String) {},
                  onPostDeleted: (AmityPost post) {},
                  onPostUpdated: (post) {},
                )),
          ],
        ),
      );
    }
  }

  Widget _getPinPost(int index, CommunityPinState state) {
    final amityPost = state.pins[index].post!;
    if (((amityPost.children?.isNotEmpty ?? false) &&
            (amityPost.children!.first.type == AmityDataType.FILE ||
                amityPost.children!.first.type == AmityDataType.LIVESTREAM)) ||
        (amityPost.isDeleted ?? false) ||
        (state.announcements.map((e) => e.postId).contains(amityPost.postId))) {
      return Container();
    } else {
      var uniqueKey = UniqueKey();
      return VisibilityDetector(
        key: Key(amityPost.postId ?? uniqueKey.toString()),
        onVisibilityChanged: (VisibilityInfo info) {
          final visiblePercentage = info.visibleFraction * 100;
          if (visiblePercentage > 60) {
            checkVisibilityAndMarkSeen(amityPost, visiblePercentage);
          }
        },
        child: Column(
          children: [
            AmityPostContentComponent(
                style: AmityPostContentComponentStyle.feed,
                post: amityPost,
                category: AmityPostCategory.pin,
                key: uniqueKey,
                hideTarget: true,
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
  }
}
