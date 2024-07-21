import 'package:amity_uikit_beta_service/v4/utils/Shimmer.dart';
import 'package:amity_uikit_beta_service/v4/utils/skeleton.dart';
import 'package:amity_uikit_beta_service/viewmodel/configuration_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoadingSkeleton extends StatelessWidget {
  final BuildContext context;

  const LoadingSkeleton({super.key, required this.context});
  Widget skeletonList() {
    return Container(
      decoration: BoxDecoration(
          color: Provider.of<AmityUIConfiguration>(context)
              .appColors
              .baseBackground),
      child: Column(children: [
        Container(
          color:
              Provider.of<AmityUIConfiguration>(context).appColors.baseShade4,
          height: 8,
        ),
        Expanded(
          child: Container(
            alignment: Alignment.topCenter,
            child: Shimmer(
              linearGradient: LinearGradient(
                colors: [
                  Provider.of<AmityUIConfiguration>(context)
                      .appColors
                      .baseShade4,
                  const Color(0xFFF4F4F4),
                  const Color(0xFFEBEBF4),
                ],
                stops: const [
                  0.1,
                  0.3,
                  0.4,
                ],
                begin: const Alignment(-1.0, -0.3),
                end: const Alignment(1.0, 0.3),
                tileMode: TileMode.clamp,
              ),
              child: ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (context, index) {
                  return Divider(
                    color: Provider.of<AmityUIConfiguration>(context)
                        .appColors
                        .baseShade4,
                    thickness: 8,
                    height: 24,
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
                itemCount: 4,
              ),
            ),
          ),
        )
      ]),
    );
  }

  Widget skeletonRow() {
    return SizedBox(
      height: 180,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 19),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 60,
                  padding: const EdgeInsets.only(
                      top: 12, left: 0, right: 8, bottom: 8),
                  child: const SkeletonImage(
                    height: 40,
                    width: 40,
                    borderRadius: 40,
                  ),
                ),
                const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 6.0),
                      SkeletonText(width: 120),
                      SizedBox(height: 12.0),
                      SkeletonText(width: 88),
                    ]),
              ],
            ),
            const SizedBox(height: 14.0),
            const SkeletonText(width: 240),
            const SizedBox(height: 12.0),
            const SkeletonText(width: 297),
            const SizedBox(height: 12.0),
            const SkeletonText(width: 180),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return skeletonList();
  }
}
