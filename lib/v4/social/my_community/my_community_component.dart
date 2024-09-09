import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/base_component.dart';
import 'package:amity_uikit_beta_service/v4/core/base_element.dart';
import 'package:amity_uikit_beta_service/v4/social/my_community/bloc/my_community_bloc.dart';
import 'package:amity_uikit_beta_service/v4/utils/compact_string_converter.dart';
import 'package:amity_uikit_beta_service/v4/utils/network_image.dart';
import 'package:amity_uikit_beta_service/v4/utils/shimmer.dart';
import 'package:amity_uikit_beta_service/v4/utils/skeleton.dart';
import 'package:amity_uikit_beta_service/view/social/community_feed.dart';
import 'package:amity_uikit_beta_service/view/social/community_feedV2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../../view/social/community_feedV2.dart';

part 'my_community_elements.dart';
part 'my_community_ui_ids.dart';

class AmityMyCommunitiesComponent extends NewBaseComponent {
  AmityMyCommunitiesComponent({Key? key, required String pageId})
      : super(
            key: key,
            pageId: pageId,
            componentId: AmityComponent.myCommunities.stringValue);

  @override
  Widget buildComponent(BuildContext context) {
    return BlocProvider(
      create: (context) => MyCommunityBloc(),
      child: Builder(builder: (context) {
        context.read<MyCommunityBloc>().add(MyCommunityEventInitial());

        return BlocBuilder<MyCommunityBloc, MyCommunityState>(
          builder: (context, state) {
            if (state is MyCommunityLoading) {
              return skeletonList();
            } else if (state is MyCommunityLoaded) {
              return Column(
                children: [
                  Container(
                    color: theme.baseColorShade4,
                    height: 8,
                  ),
                  Container(child: communityRow(context, state)),
                ],
              );
            } else {
              return Container();
            }
          },
        );
      }),
    );
  }

  Widget communityRow(BuildContext context, MyCommunityLoaded state) {
    final ScrollController scrollController = ScrollController();

    final communities = state.list;

    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        context.read<MyCommunityBloc>().add(MyCommunityEventLoadMore());
      }
    });

    return Expanded(
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 16),
        controller: scrollController,
        itemCount: communities.length,
        separatorBuilder: (context, index) {
          return Divider(
            color: theme.baseColorShade4,
            thickness: 0.5,
            indent: 16,
            endIndent: 16,
            height: 25,
          );
        },
        itemBuilder: (context, index) {
          return SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [getCommunityRow(context, communities[index])],
            ),
          );
        },
      ),
    );
  }

  Widget getCommunityRow(BuildContext context, AmityCommunity community) {
    var categoriesName =
        community.categories?.map((category) => category?.name).toList();

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CommunityScreen(community: community),
          ),
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: SizedBox(
              width: 40,
              height: 40,
              child: CommunityImageAvatarElement(
                  avatarUrl: community.avatarImage?.fileUrl,
                  elementId:
                      AmityMyCommunityElement.communityAvatar.stringValue),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (!(community.isPublic ?? false))
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: AmityPrivateBadgeElement(),
                      ),
                    Flexible(
                      child: Text(
                        community.displayName ?? '',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: theme.baseColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (community.isOfficial ?? true)
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: AmityOfficialBadgeElement(),
                      ),
                    const SizedBox(width: 16),
                  ],
                ),
                const SizedBox(height: 4),
                if (categoriesName != null && categoriesName.isNotEmpty)
                  AmityCommunityCategoriesName(tags: categoriesName),
                CommunityMemberCountElement(
                  memberCount: community.membersCount,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget skeletonList() {
    return Container(
      decoration: BoxDecoration(color: theme.backgroundColor),
      child: Column(children: [
        Container(
          color: theme.baseColorShade4,
          height: 8,
        ),
        Expanded(
          child: Container(
            alignment: Alignment.topCenter,
            child: Shimmer(
              linearGradient: configProvider.getShimmerGradient(),
              child: ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (context, index) {
                  return Divider(
                    color: theme.baseColorShade4,
                    thickness: 0.5,
                    indent: 16,
                    endIndent: 16,
                    height: 25,
                  );
                },
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: double.infinity,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerLoading(
                          isLoading: true,
                          child: skeletonRow(),
                        ),
                      ],
                    ),
                  );
                },
                itemCount: 5,
              ),
            ),
          ),
        )
      ]),
    );
  }

  Widget skeletonRow() {
    return SizedBox(
      height: 56,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 56,
            padding:
                const EdgeInsets.only(top: 8, left: 16, right: 8, bottom: 8),
            child: const SkeletonImage(
              height: 40,
              width: 40,
              borderRadius: 40,
            ),
          ),
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(height: 14.0),
            SkeletonText(width: 180),
            SizedBox(height: 12.0),
            SkeletonText(width: 108)
          ]),
        ],
      ),
    );
  }
}
