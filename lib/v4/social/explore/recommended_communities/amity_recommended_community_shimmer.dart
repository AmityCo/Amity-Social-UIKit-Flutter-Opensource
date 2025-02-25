import 'package:amity_uikit_beta_service/v4/core/base_component.dart';
import 'package:amity_uikit_beta_service/v4/utils/shimmer_widget.dart';
import 'package:amity_uikit_beta_service/v4/utils/skeleton.dart';
import 'package:flutter/material.dart';

class AmityRecommendedCommunityShimmer extends NewBaseComponent {
  AmityRecommendedCommunityShimmer({super.key})
      : super(componentId: "community_recommended_community_shimmer");

  @override
  Widget buildComponent(BuildContext context) {
    return Shimmer(
      linearGradient: configProvider.getShimmerGradient(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              child: SkeletonRectangle(
                width: 180,
                height: 12,
              )),
          SizedBox(
            height: 210,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 3,
              itemBuilder: (context, index) => _buildShimmerCard(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      width: 268,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            width: 268,
            height: 125,
            decoration: BoxDecoration(
              color: theme.baseColorShade4,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
          ),
          Container(
            height: 78,
            width: 268,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(8)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonRectangle(
                  width: 100,
                  height: 10,
                ),
                const SizedBox(height: 14),
                SkeletonRectangle(
                  width: 140,
                  height: 8,
                ),
                const SizedBox(height: 10),
                SkeletonRectangle(
                  width: 200,
                  height: 8,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
