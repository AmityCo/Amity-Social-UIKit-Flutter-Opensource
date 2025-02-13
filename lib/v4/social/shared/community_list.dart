import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/social/community/profile/amity_community_profile_page.dart';
import 'package:amity_uikit_beta_service/v4/social/my_community/my_community_component.dart';
import 'package:amity_uikit_beta_service/v4/utils/config_provider.dart';
import 'package:amity_uikit_beta_service/v4/utils/shimmer_widget.dart';
import 'package:amity_uikit_beta_service/v4/utils/skeleton.dart';
import 'package:flutter/material.dart';

Widget communityList(
  BuildContext context,
  ScrollController scrollController,
  List<AmityCommunity> communities,
  AmityThemeColor theme,
  void Function() loadMore,
) {
  scrollController.addListener(() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      loadMore();
    }
  });

  return Container(
    decoration: BoxDecoration(color: theme.backgroundColor),
    child: IntrinsicHeight(
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
          return Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [communityRow(context, communities[index], theme)],
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}

Widget communityRow(
    BuildContext context, AmityCommunity community, AmityThemeColor theme) {
  var categoriesName =
      community.categories?.map((category) => category?.name).toList();

  return GestureDetector(
    onTap: () {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AmityCommunityProfilePage(communityId: community.communityId!),
        ),
      );
    },
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Container(
            color: theme.baseColorShade3,
            width: 80,
            height: 80,
            child: CommunityImageAvatarElement(
                avatarUrl: community.avatarImage?.fileUrl,
                placeHolderPath: "assets/Icons/amity_ic_community_avatar_placeholder_rectangle.svg",
                elementId: AmityMyCommunityElement.communityAvatar.stringValue),
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
                        fontSize: 15,
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

Widget communitySkeletonList(
    AmityThemeColor theme, ConfigProvider configProvider) {
  return Container(
    decoration: BoxDecoration(color: theme.backgroundColor),
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
                    child: communitySkeletonRow(),
                  ),
                ],
              ),
            );
          },
          itemCount: 5,
        ),
      ),
    ),
  );
}

Widget communitySkeletonRow() {
  return SizedBox(
    height: 96,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 104,
          height: 96,
          padding: const EdgeInsets.only(top: 8, left: 16, right: 8, bottom: 8),
          child: const SkeletonImage(
            height: 80,
            width: 80,
            borderRadius: 4,
          ),
        ),
        const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(height: 30.0),
          SkeletonText(width: 180, height: 12),
          SizedBox(height: 12.0),
          SkeletonText(
            width: 108,
            height: 10,
          )
        ]),
      ],
    ),
  );
}
