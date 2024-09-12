import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/base_element.dart';
import 'package:amity_uikit_beta_service/v4/social/community/profile/element/community_name.dart';
import 'package:amity_uikit_beta_service/v4/social/my_community/my_community_component.dart';
import 'package:flutter/material.dart';

class AmityCommunityProfileTitleView extends BaseElement {
  final AmityCommunity? community;

  AmityCommunityProfileTitleView({
    super.key,
    required this.community,
  }) : super(elementId: 'community_title');

  @override
  Widget buildElement(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (community?.isPublic == false)
            Container(
              width: 28,
              height: 28,
              margin: const EdgeInsets.only(top: 1),
              child: AmityPrivateBadgeElement(),
            ),
          Flexible(
            flex: 1,
            fit: FlexFit.loose,
            child: AmityCommunityName(community: community),
          ),
          if (community?.isOfficial == true)
            Container(
              width: 28,
              height: 28,
              margin: const EdgeInsets.only(top: 2),
              child: AmityOfficialBadgeElement()
            ),
        ],
      ),
    );
  }
}
