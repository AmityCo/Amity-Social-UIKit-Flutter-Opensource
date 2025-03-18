import 'package:amity_uikit_beta_service/v4/core/base_component.dart';
import 'package:amity_uikit_beta_service/v4/utils/shimmer_widget.dart';
import 'package:amity_uikit_beta_service/v4/utils/skeleton.dart';
import 'package:flutter/material.dart';

class AmityTrendingCommunityShimmer extends NewBaseComponent {
  AmityTrendingCommunityShimmer({super.key})
      : super(componentId: "amity_community_trending_community_shimmer");

  @override
  Widget buildComponent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Shimmer(
            linearGradient: configProvider.getShimmerGradient(),
            child: SkeletonRectangle(
                width: 180,
                height: 12,
              )
          ),
        ),
        ...List.generate(
          3,
          (index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Shimmer(
              linearGradient: configProvider.getShimmerGradient(),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: theme.baseColorShade4,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonRectangle(
                          width: 200,
                          height: 12,
                        ),
                        const SizedBox(height: 12),
                        SkeletonRectangle(
                          width: 120,
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
