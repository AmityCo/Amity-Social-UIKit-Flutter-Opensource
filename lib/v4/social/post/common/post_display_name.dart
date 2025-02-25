import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/social/community/profile/amity_community_profile_page.dart';
import 'package:amity_uikit_beta_service/v4/social/post/common/post_moderator_badge.dart';
import 'package:amity_uikit_beta_service/v4/social/user/profile/amity_user_profile_page.dart';
import 'package:amity_uikit_beta_service/v4/utils/date_time_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class PostDisplayName extends StatelessWidget {
  final AmityPost post;
  final AmityThemeColor theme;
  final bool hideTarget;

  const PostDisplayName({
    Key? key,
    required this.post,
    required this.theme,
    required this.hideTarget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var isModerator = false;
    if (post.target is CommunityTarget) {
      var roles = (post.target as CommunityTarget).postedCommunityMember?.roles;
      if (roles != null &&
          (roles.contains("moderator") ||
              roles.contains("community-moderator"))) {
        isModerator = true;
      }
    }

    var timestampText = post.createdAt?.toSocialTimestamp() ?? "";
    if (post.editedAt != post.createdAt) {
      timestampText += " (edited)";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: (!hideTarget &&
                    post.target != null &&
                    ((post.target is CommunityTarget) ||
                        (post.target is UserTarget &&
                            (post.target as UserTarget).targetUserId !=
                                post.postedUserId)))
                ? [
                    Flexible(child: DisplayName(context, post.postedUser)),
                    TargetArrow(),
                    Expanded(flex: 2, child: PostTarget(context, post.target!)),
                  ]
                : [
                    Flexible(
                        fit: FlexFit.loose,
                        child: DisplayName(context, post.postedUser))
                  ],
          ),
          Row(
            children: [
              if (isModerator) const CommunityModeratorBadge(),
              if (isModerator)
                Container(
                    padding: const EdgeInsets.only(left: 2),
                    child: Text(
                      "• ",
                      style: TextStyle(
                        color: theme.baseColorShade2,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    )),
              Container(
                alignment: Alignment.topLeft,
                child: Text(
                  timestampText,
                  style: TextStyle(
                    color: theme.baseColorShade2,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget DisplayName(BuildContext context, AmityUser? user) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                AmityUserProfilePage(userId: user?.userId ?? ""),
          ),
        );
      },
      child: Text(
        user?.displayName ?? "Unknown",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AmityTextStyle.bodyBold(theme.baseColor),
      ),
    );
  }

  Widget PostTarget(BuildContext context, AmityPostTarget target) {
    VoidCallback? onTap;
    var targetName = '';
    if (target is CommunityTarget && target.targetCommunity != null) {
      targetName =
          (post.target as CommunityTarget).targetCommunity?.displayName ??
              'Unknown';

      onTap = () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AmityCommunityProfilePage(
                communityId: target.targetCommunityId!),
          ),
        );
      };
    } else if (target is UserTarget) {
      if (post.postedUserId != target.targetUserId) {
        if (post.postedUserId != target.targetUserId) {
          targetName =
              (post.target as UserTarget).targetUser?.displayName ?? 'Unknown';
        }
        onTap = () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  AmityUserProfilePage(userId: target.targetUser?.userId ?? ''),
            ),
          );
        };
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Text(
        targetName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        // softWrap: false,
        style: AmityTextStyle.bodyBold(theme.baseColor),
      ),
    );
  }

  Widget TargetArrow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: SvgPicture.asset(
        'assets/Icons/amity_ic_post_target_arrow.svg',
        package: 'amity_uikit_beta_service',
        width: 12,
        height: 10,
      ),
    );
  }
}
