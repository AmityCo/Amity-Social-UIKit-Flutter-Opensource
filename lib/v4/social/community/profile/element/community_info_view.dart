import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:amity_uikit_beta_service/v4/core/base_element.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_membership/community_membership_page.dart';
import 'package:amity_uikit_beta_service/v4/utils/compact_string_converter.dart';
import 'package:flutter/material.dart';

class AmityCommunityInfoView extends BaseElement {
  final AmityCommunity community;

  AmityCommunityInfoView({super.key, required this.community})
      : super(elementId: 'community_info');

  @override
  Widget buildElement(BuildContext context) {
    final postCount = community.postsCount ?? 0;
    final memberCount = community.membersCount ?? 0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          postCount.formattedCompactString(),
          style: TextStyle(
            color: theme.baseColor,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          context.l10n.profile_posts_count(postCount),
          style: TextStyle(
            color: theme.baseColorShade2,
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(width: 16),
        Container(
          width: 1,
          height: 20,
          color: const Color(0xFFE5E5E5),
        ),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: () => {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    AmityCommunityMembershipPage(community: community),
              ),
            ),
          },
          child: Row(
            children: [
              Text(
                memberCount.formattedCompactString(),
                style: TextStyle(
                  color: theme.baseColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                context.l10n.profile_members_count(memberCount),
                style: TextStyle(
                  color: theme.baseColorShade2,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
