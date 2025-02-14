import 'package:amity_uikit_beta_service/v4/core/base_component.dart';
import 'package:amity_uikit_beta_service/v4/utils/shimmer_widget.dart';
import 'package:amity_uikit_beta_service/v4/utils/skeleton.dart';
import 'package:flutter/material.dart';

class UserSkeletonLoadingView extends NewBaseComponent {

  final int itemCount;

  UserSkeletonLoadingView({Key? key, this.itemCount = 8})
      : super(key: key, componentId: "user_skeleton_loading_page");

  @override
  Widget buildComponent(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: theme.backgroundColor),
      margin: const EdgeInsets.only(top: 8),
      child: Column(children: [
        Expanded(
          child: Container(
            alignment: Alignment.topCenter,
            child: Shimmer(
              linearGradient: configProvider.getShimmerGradient(),
              child: ListView(
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  for (int i = 0; i < itemCount; i++) skeletonItem(),
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: const Row(
          children: [
            SkeletonImage(width: 40, height: 40, borderRadius: 20),
            SizedBox(width: 12),
            SkeletonText(width: 180, height: 10),
          ],
        ),
      ),
    );
  }
}
