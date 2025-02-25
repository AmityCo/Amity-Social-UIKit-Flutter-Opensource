import 'package:amity_sdk/amity_sdk.dart';
import 'package:flutter/material.dart';

class AmityCommunityCategoryView extends StatelessWidget {
  final List<AmityCommunityCategory?> categories;
  final int maxPreview;

  const AmityCommunityCategoryView({
    Key? key,
    required this.categories,
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).dividerColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        categoryName,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          overflow: TextOverflow.ellipsis,
        ),
        maxLines: 1,
      ),
    );
  }
}
