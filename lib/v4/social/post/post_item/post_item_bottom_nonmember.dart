import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:amity_uikit_beta_service/v4/core/base_element.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:flutter/material.dart';

class PostBottomNonMember extends BaseElement {
  PostBottomNonMember({super.key}) : super(elementId: 'post_bottom_nonmember');

  @override
  Widget buildElement(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 7),
          child: Container(
            width: double.infinity,
            height: 1,
            color: theme.baseColorShade4,
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(
            top: 4,
            left: 16,
            right: 16,
            bottom: 12,
          ),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(color: theme.backgroundColor),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  context.l10n.post_item_bottom_nonmember_label,
                  style: AmityTextStyle.body(theme.baseColorShade2),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
