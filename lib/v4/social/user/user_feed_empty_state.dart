import 'package:amity_uikit_beta_service/v4/core/base_element.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/social/user/feed/user_feed_empty_state_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class UserFeedEmptyState extends BaseElement {
  final UserFeedEmptyStateInfo info;

  UserFeedEmptyState({Key? key, required this.info})
      : super(key: key, elementId: "user_feed_empty_state_view");

  @override
  Widget buildElement(BuildContext context) {
    return Container(
      height: 400,
      color: theme.backgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            info.icon,
            package: 'amity_uikit_beta_service',
          ),
          const SizedBox(height: 8),
          Text(
            info.title,
            textAlign: TextAlign.center,
            style: AmityTextStyle.titleBold(theme.baseColorShade3),
          ),
          const SizedBox(height: 8),
          Text(
            info.description,
            textAlign: TextAlign.center,
            style: AmityTextStyle.caption(theme.baseColorShade3),
          ),
        ],
      ),
    );
  }
}
