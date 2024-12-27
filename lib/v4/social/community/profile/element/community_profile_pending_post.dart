import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/base_element.dart';
import 'package:amity_uikit_beta_service/v4/utils/compact_string_converter.dart';
import 'package:amity_uikit_beta_service/view/social/pending_page.dart';
import 'package:flutter/material.dart';

class AmityCommunityPendingPost extends BaseElement {
  final AmityCommunity community;
  final int pendingPostCount;
  final bool isModerator;

  AmityCommunityPendingPost(
      {Key? key,
      required this.community,
      required this.pendingPostCount,
      required this.isModerator})
      : super(elementId: 'community_pending_post', key: key);

  @override
  Widget buildElement(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to Edit Profile Page or perform an action
        if (isModerator) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => PendingFeddScreen(
                    community: community,
                  )));
        }
      },
      child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          width: double.infinity,
          decoration: ShapeDecoration(
            color: const Color(0xFFEBECEF),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: ShapeDecoration(
                      color: theme.primaryColor,
                      shape: const OvalBorder(),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Pending posts',
                    style: TextStyle(
                      color: theme.baseColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                isModerator
                    ? '${pendingPostCount.formattedCompactString()} ${(pendingPostCount == 1) ? 'post' : 'posts'} need approval'
                    : 'Your posts are pending for review',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF636878),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          )),
    );
  }
}
