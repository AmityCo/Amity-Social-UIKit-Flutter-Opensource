import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/base_element.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/core/theme/amity_color_token.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AmityMessageAvatar extends BaseElement {
  final AmityMessage? message;
  final bool isModerator;
  final String avatarPlaceholder =
      "assets/Icons/amity_ic_user_avatar_placeholder.svg";

  late final String? avatarUrl;
  late final bool isDeletedUser;
  late final String displayName;

  AmityMessageAvatar(
      {required this.message,
      this.isModerator = false,
      super.key,
      super.pageId = "",
      super.componentId = "",
      super.elementId = "chat-avatar"}) {
    avatarUrl = message?.user?.avatarUrl;
    isDeletedUser = message?.user?.isDeleted ?? false;
    displayName = message?.user?.displayName ?? "";
  }

  @override
  Widget buildElement(BuildContext context) {
    Widget avatarWidget;

    if (isDeletedUser) {
      // Same Avatar-atom treatment as the chat list row, at the bubble's 32.
      avatarWidget = Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: token(AmityColorToken.surfaceAvatarProfileDefault),
        ),
        child: Center(
          child: SvgPicture.asset(
            "assets/Icons/amity_ic_user_s.svg",
            package: 'amity_uikit_beta_service',
            width: 20,
            height: 20,
            colorFilter: ColorFilter.mode(
                token(AmityColorToken.iconAvatarDefault), BlendMode.srcIn),
          ),
        ),
      );
    } else {
      final isAvatarAvailable = avatarUrl != null && avatarUrl!.isNotEmpty;
      if (isAvatarAvailable) {
        avatarWidget = SizedBox(
          width: 32,
          height: 32,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Image.network(
              avatarUrl!,
              fit: BoxFit.cover,
              loadingBuilder: (BuildContext context, Widget child,
                  ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                } else {
                  return SvgPicture.asset(
                    avatarPlaceholder,
                    package: 'amity_uikit_beta_service',
                  );
                }
              },
              errorBuilder:
                  (BuildContext context, Object error, StackTrace? stackTrace) {
                return avatarCharacter();
              },
            ),
          ),
        );
      } else {
        avatarWidget = avatarCharacter();
      }
    }

    if (isModerator) {
      return Container(
        height: isModerator ? 36 : 32,
        width: isModerator ? 36 : 32,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            avatarWidget,
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: token(
                      AmityColorToken.surfaceBadgeSemanticBadgeUserStatusModerator),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/Icons/amity_ic_community_moderator.svg',
                    package: 'amity_uikit_beta_service',
                    width: 12,
                    height: 12,
                    // The disc above flips (#DDDEF8 light -> #3B41EC dark) but
                    // the glyph was never tinted, so it kept the asset's baked
                    // #1054DE. On the pale light disc that reads; on the blue
                    // dark disc it is the same blue, and the badge collapses
                    // to a solid dot. The paired Icon token flips to white for
                    // exactly this reason.
                    colorFilter: ColorFilter.mode(
                      token(AmityColorToken
                          .iconBadgeSemanticBadgeUserStatusModeratorDefault),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return avatarWidget;
  }

  Widget avatarCharacter() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        // An avatar disc, not a disabled button. The two are near-neighbours in
        // light — pale blue either way — so this survived review; in dark the
        // button token goes to full-saturation primary and the chat-room
        // avatars stop matching the ones in the channel list.
        color: token(AmityColorToken.surfaceAvatarProfileDefault),
        shape: BoxShape.circle,
      ),
      child: Center(
          child: Text(
        displayName.isEmpty ? "" : displayName[0].toUpperCase(),
        style: AmityTextStyle.custom(16, FontWeight.w400, Colors.white),
      )),
    );
  }
}
