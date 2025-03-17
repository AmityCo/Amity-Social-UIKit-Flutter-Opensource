import 'package:amity_uikit_beta_service/v4/core/base_component.dart';
import 'package:amity_uikit_beta_service/v4/utils/shimmer_widget.dart';
import 'package:flutter/material.dart';

class AmityExploreCategoryShimmer extends NewBaseComponent {
  AmityExploreCategoryShimmer({super.key})
      : super(componentId: "amity_explore_category_shimmer");

  @override
  Widget buildComponent(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16),
      child: Shimmer(
        linearGradient: configProvider.getShimmerGradient(),
        child: Row(
          children: List.generate(
            5,
            (index) => Container(
              margin: const EdgeInsets.only(right: 8),
              width: 90,
              height: 36,
              decoration: BoxDecoration(
                color: theme.baseColorShade4,
                borderRadius: BorderRadius.circular(40),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
