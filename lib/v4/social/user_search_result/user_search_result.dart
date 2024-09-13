import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/base_component.dart';
import 'package:amity_uikit_beta_service/v4/social/global_search/view_model/global_search_view_model.dart';
import 'package:amity_uikit_beta_service/v4/utils/network_image.dart';
import 'package:amity_uikit_beta_service/v4/utils/shimmer.dart';
import 'package:amity_uikit_beta_service/v4/utils/skeleton.dart';
import 'package:amity_uikit_beta_service/view/user/user_profile_v2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AmityUserSearchResultComponent extends NewBaseComponent {
  AmityGlobalSearchViewModel viewModel;

  AmityUserSearchResultComponent({
    Key? key,
    String? pageId,
    required this.viewModel,
  }) : super(key: key, pageId: pageId, componentId: 'user_search_result');

  @override
  Widget buildComponent(BuildContext context) {
    if (viewModel.users.isEmpty) {
      if (viewModel.isUsersFetching) {
        return userSkeletonList();
      } else {
        return Center(
          child: Column(
            mainAxisSize:
                MainAxisSize.min, // Centers the children within the column
            children: [
              SvgPicture.asset(
                'assets/Icons/amity_ic_search_not_found.svg',
                package: 'amity_uikit_beta_service',
                colorFilter:
                    ColorFilter.mode(theme.baseColorShade4, BlendMode.srcIn),
                width: 47,
                height: 47,
              ),
              const SizedBox(
                  height: 10), // Optional spacing between icon and text
              Text(
                'No results found',
                style: TextStyle(
                  color: theme.baseColorShade3,
                  fontWeight: FontWeight.w600,
                  fontSize: 17,
                ),
              ),
            ],
          ),
        );
      }
    } else {
      return Container(
        color: theme.backgroundColor,
        child: getUserList(context, viewModel.users),
      );
    }
  }

  Widget getUserList(BuildContext context, List<AmityUser> users) {
    viewModel.scrollController.addListener(() {
      if (viewModel.scrollController.position.pixels ==
          viewModel.scrollController.position.maxScrollExtent) {
        viewModel.onLoadMore?.call();
      }
    });

    return Container(
      decoration: BoxDecoration(color: theme.backgroundColor),
      child: Column(children: [
        Divider(
          color: theme.baseColorShade4,
          thickness: 0.5,
          height: 0,
        ),
        Expanded(
          child: ListView.separated(
            controller: viewModel.scrollController,
            itemCount: users.length,
            separatorBuilder: (context, index) {
              return const SizedBox(height: 4);
            },
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(top: index == 0 ? 0.0 : 0.0),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      userRow(context, users[index]),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }

  Widget userRow(BuildContext context, AmityUser user) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => UserProfileScreen(
              amityUserId: user.userId ?? '',
              amityUser: null,
            ),
          ),
        );
      },
      child: SizedBox(
        height: 56,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(width: 12),
            avatarImage(user),
            const SizedBox(width: 8),
            displayName(user.displayName ?? ""),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  Widget avatarImage(AmityUser user) {
    return Container(
      padding: const EdgeInsets.all(4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: SizedBox(
          width: 40,
          height: 40,
          child: AmityNetworkImage(
              imageUrl: user.avatarUrl,
              placeHolderPath:
                  "assets/Icons/amity_ic_user_avatar_placeholder.svg"),
        ),
      ),
    );
  }

  Widget displayName(String displayName) {
    return Expanded(
      child: Text(
        displayName,
        style: TextStyle(
          color: theme.baseColor,
          fontSize: 15,
          fontWeight: FontWeight.bold,
          fontFamily: 'SF Pro Text',
        ),
      ),
    );
  }

  Widget userSkeletonList() {
    return Container(
      decoration: BoxDecoration(color: theme.backgroundColor),
      child: Column(children: [
        Divider(
          color: theme.baseColorShade4,
          thickness: 0.5,
          height: 0,
        ),
        Expanded(
          child: Container(
            alignment: Alignment.topCenter,
            child: Shimmer(
              linearGradient: configProvider.getShimmerGradient(),
              child: ListView(
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  skeletonItem(),
                  skeletonItem(),
                  skeletonItem(),
                  skeletonItem(),
                  skeletonItem(),
                ],
              ),
            ),
          ),
        )
      ]),
    );
  }

  Widget skeletonItem() {
    return ShimmerLoading(
      isLoading: true,
      child: SizedBox(
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
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 14.0),
                SkeletonText(width: 180),
                SizedBox(height: 12.0),
                SkeletonText(width: 108),
              ],
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}
