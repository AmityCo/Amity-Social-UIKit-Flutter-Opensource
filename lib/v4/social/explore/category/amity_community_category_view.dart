import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:flutter/material.dart';

class AmityCommunityCategoryView extends StatelessWidget {
  final List<AmityCommunityCategory?> categories;
  final int maxPreview;
  final AmityThemeColor theme;

  const AmityCommunityCategoryView({
    Key? key,
    required this.categories,
    required this.theme,
    this.maxPreview = 2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final previewCategories = categories.take(maxPreview).toList();
    final remainingCount = categories.length - maxPreview;

    return Row(
      mainAxisSize: MainAxisSize.min, 
      children: [
        ...previewCategories.map((category) {
          return Flexible(
            child: Container(
              constraints: const BoxConstraints(minWidth: 0),
              child: _buildCategoryChip(context, category?.name ?? ''),
            ),
          );
        }),
        if (remainingCount > 0) 
          _buildCategoryChip(context, '+$remainingCount'),
      ],
    );
  }

  Widget _buildCategoryChip(BuildContext context, String categoryName) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
      decoration: BoxDecoration(
        color: theme.baseColorShade4,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        categoryName,
        style: AmityTextStyle.caption(theme.baseColor),
        maxLines: 1,
      ),
    );
  }
}
