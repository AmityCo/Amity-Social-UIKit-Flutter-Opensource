import 'package:amity_uikit_beta_service/v4/core/base_element.dart';
import 'package:flutter/material.dart';

class AmityCommunityCategoryListElement extends BaseElement {
  final List<String> categories;

  AmityCommunityCategoryListElement({super.key, 
    required this.categories,
  }) : super(elementId: 'community_categories');

  @override
  Widget buildElement(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: getCategoryRow(categories),
    );
  }

  Widget getCategoryRow(List<String?> tags) {
    const int maxTags = 3;
    final int remainingTagsCount = tags.length - maxTags;
    final List<String?> displayedTags = tags.take(maxTags).toList();

    if (remainingTagsCount > 0) {
      displayedTags.add('+$remainingTagsCount');
    }
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final double maxTagWidth =
                (constraints.maxWidth / displayedTags.length)
                    .clamp(0.0, constraints.maxWidth);

            return Wrap(
              spacing: 4.0,
              children: displayedTags.map((tag) {
                return getCategoryWidget(
                    label: tag ?? '', maxWidth: maxTagWidth);
              }).toList(),
            );
          },
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget getCategoryWidget({required String label, required double maxWidth}) {
    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: theme.baseColorShade4,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Text(
        label,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        style: TextStyle(
            color: theme.baseColor, fontSize: 12, fontWeight: FontWeight.w400),
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  final String title;

  const CategoryItem({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
      color: Colors.grey[300],
      borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: Colors.black,
      ),
      textAlign: TextAlign.center,
      ),
    );
  }
}