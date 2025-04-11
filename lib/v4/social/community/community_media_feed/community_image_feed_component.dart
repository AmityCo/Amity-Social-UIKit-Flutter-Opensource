import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/base_component.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_media_feed/bloc/community_media_feed_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/globalfeed/amity_global_feed_component.dart';
import 'package:amity_uikit_beta_service/v4/social/user/image_feed/element/user_image_feed_element.dart';
import 'package:amity_uikit_beta_service/v4/utils/config_provider.dart';
import 'package:amity_uikit_beta_service/v4/utils/shimmer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

// ignore: must_be_immutable
class AmityCommunityImageFeedComponent extends NewBaseComponent {
  final String communityId;

  late ScrollController scrollController;
  final AmityUserFollowInfo? userFollowInfo;

  AmityCommunityImageFeedComponent({
    super.key,
    String? pageId,
    required this.communityId,
    ScrollController? scrollController,
    this.userFollowInfo,
  }) : super(componentId: "community_image_feed") {
    if (scrollController != null) {
      this.scrollController = scrollController;
    } else {
      this.scrollController = ScrollController();
    }
  }

  @override
  Widget buildComponent(BuildContext context) {
    return BlocProvider<CommunityMediaFeedBloc>(
      create: (context) => CommunityMediaFeedBloc(
          communityId: communityId,
          feedType: CommunityMediaFeedType.image,
          scrollController: scrollController),
      child: BlocBuilder<CommunityMediaFeedBloc, CommunityMediaFeedState>(
        builder: (context, state) {
          if (!state.isLoading && state.posts.isEmpty) {
            return SliverToBoxAdapter(
                child: Container(
              padding: const EdgeInsets.only(bottom: 120),
              width: double.infinity,
              height: 550,
              color: theme.backgroundColor,
              child: _getEmptyFeed(theme),
            ));
          } else if (state.posts.isEmpty && state.isLoading) {
            return SliverToBoxAdapter(
                child: Container(
                    color: theme.backgroundColor,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        getSkeleton(theme, configProvider),
                      ],
                    )));
          } else {
            return DecoratedSliver(
                decoration: BoxDecoration(color: theme.backgroundColor),
                sliver: SliverMainAxisGroup(slivers: [
                  SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverGrid(
                          delegate: SliverChildBuilderDelegate(
                              childCount: state.posts.length, (context, index) {
                            final post = state.posts[index];
                            return UserImageFeedElement(
                                post: post, theme: theme);
                          }),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 8.0,
                            crossAxisSpacing: 8.0,
                            childAspectRatio: 1.0,
                          ))),
                  if (state.isLoading && state.posts.isNotEmpty)
                    SliverToBoxAdapter(
                      child: getSkeleton(theme, configProvider),
                    )
                ]));
          }
        },
      ),
    );
  }

  Widget getSkeleton(AmityThemeColor theme, ConfigProvider configProvider) {
    return Container(
      color: theme.backgroundColor,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Shimmer(
          linearGradient: configProvider.getShimmerGradient(),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8.0,
              crossAxisSpacing: 8.0,
              childAspectRatio: 1.0,
            ),
            itemCount: 6, // Show 6 skeleton items (3 rows of 2)
            itemBuilder: (context, index) {
              return ShimmerLoading(
                isLoading: true,
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.baseColorShade4,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _getEmptyFeed(AmityThemeColor theme) {
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
                    'assets/Icons/amity_ic_image_feed_empty.svg',
                    package: 'amity_uikit_beta_service',
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 252,
            child: Text('No photos yet',
                textAlign: TextAlign.center,
                style: AmityTextStyle.titleBold(theme.baseColorShade3)),
          ),
        ],
      ),
    );
  }
}
