import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/utils/config_provider.dart';
import 'package:amity_uikit_beta_service/v4/utils/shimmer_widget.dart';
import 'package:amity_uikit_beta_service/v4/utils/skeleton.dart';
import 'package:amity_uikit_beta_service/v4/utils/user_image.dart';
import 'package:flutter/material.dart';

Widget userList(
    {required BuildContext context,
    required ScrollController scrollController,
    required List<AmityUser> users,
    required AmityThemeColor theme,
    required void Function() loadMore,
    required void Function(AmityUser) onTap,
    bool excludeCurrentUser = false}) {
  scrollController.addListener(() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      loadMore();
    }
  });
  return Container(
    decoration: BoxDecoration(color: theme.backgroundColor),
    child: Column(children: [
      Expanded(
        child: ListView.separated(
          controller: scrollController,
          itemCount: users.length,
          separatorBuilder: (context, index) {
            return const SizedBox(height: 4);
          },
          itemBuilder: (context, index) {
            final user = users[index];
            final currentUserId = AmityCoreClient.getUserId();
            return Padding(
              padding: EdgeInsets.only(top: index == 0 ? 0.0 : 0.0),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!excludeCurrentUser || user.userId != currentUserId)
                      userRow(context, user, theme, onTap),
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

Widget userRow(BuildContext context, AmityUser user, AmityThemeColor theme,
    void Function(AmityUser) onTap) {
  return GestureDetector(
    onTap: () {
      onTap(user);
    },
    child: SizedBox(
      height: 56,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 12),
          avatarImage(user, theme),
          const SizedBox(width: 8),
          displayName(user.displayName ?? "", theme),
          const SizedBox(width: 16),
        ],
      ),
    ),
  );
}

Widget avatarImage(AmityUser user, AmityThemeColor theme) {
  return Container(
    padding: const EdgeInsets.all(4),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: SizedBox(
        width: 40,
        height: 40,
        child: AmityUserImage(user: user, theme: theme, size: 40),
      ),
    ),
  );
}

Widget displayName(String displayName, AmityThemeColor theme) {
  return Expanded(
    child: Text(
      overflow: TextOverflow.ellipsis,
      displayName,
      maxLines: 1,
      style: AmityTextStyle.bodyBold(theme.baseColor),
    ),
  );
}

Widget userSkeletonList(AmityThemeColor theme, ConfigProvider configProvider,
    {int itemCount = 5}) {
  return Container(
    decoration: BoxDecoration(color: theme.backgroundColor),
    child: Column(
      children: [
        Expanded(
          child: Container(
            alignment: Alignment.topCenter,
            child: Shimmer(
              linearGradient: configProvider.getShimmerGradient(),
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: itemCount,
                itemBuilder: (context, index) {
                  return skeletonItem();
                },
              ),
            ),
          ),
        ),
      ],
    ),
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
            padding:
                const EdgeInsets.only(top: 8, left: 16, right: 12, bottom: 8),
            child: const SkeletonImage(
              height: 40,
              width: 40,
              borderRadius: 40,
            ),
          ),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonText(width: 140, height: 10),
            ],
          ),
        ],
      ),
    ),
  );
}
