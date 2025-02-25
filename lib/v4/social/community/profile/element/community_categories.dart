import 'package:amity_uikit_beta_service/v4/core/base_element.dart';
import 'package:flutter/widgets.dart';

class AmityCommunityCategoryList extends BaseElement {
  final List<String?> tags;
  final double paddingStart;

  AmityCommunityCategoryList(
      {Key? key, String? pageId, String? componentId, required this.tags, this.paddingStart = 16})
      : super(
            key: key,
            pageId: pageId,
            componentId: componentId,
            elementId: "community_categories");

  @override
  Widget buildElement(BuildContext context) {
    return getCategoryRow(tags);
  }

  Widget getCategoryRow(List<String?> categories) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: paddingStart),
          ...categories.where((element) => element != null).map((category) => Container(
              padding: const EdgeInsets.only(right: 8),
              child: getCategoryWidget(label: category!))),
        ],
      ),
    );
  }

  Widget getCategoryWidget({required String label}) {
    return Container(
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
