import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/base_element.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/core/theme/amity_color_token.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AmityUserAvatar extends BaseElement {
  late final String avatarPlaceholder;
  late final String? avatarUrl;
  late final bool isDeletedUser;
  late final String displayName;
  late final Size avatarSize;
  late final TextStyle? characterTextStyle;

  AmityUserAvatar({
    this.avatarUrl,
    required this.displayName,
    required this.isDeletedUser,
    this.avatarSize = const Size(40, 40),
    this.avatarPlaceholder =
        "assets/Icons/amity_ic_user_avatar_placeholder.svg",
    this.characterTextStyle,
    super.key,
    super.pageId = "",
    super.componentId = "",
    super.elementId = "",
  });

  AmityUserAvatar.withChannelMember({
    AmityChannelMember? channelMember,
    this.avatarSize = const Size(40, 40),
    this.avatarPlaceholder =
        "assets/Icons/amity_ic_user_avatar_placeholder.svg",
    this.characterTextStyle,
    super.key,
    super.pageId = "",
    super.componentId = "",
    super.elementId = "",
  }) {
    avatarUrl = channelMember?.user?.avatarUrl;
    isDeletedUser = channelMember?.isDeleted ?? false;
    displayName = channelMember?.user?.displayName ?? "";
  }

  @override
  Widget buildElement(BuildContext context) {
    if (isDeletedUser) {
      return SvgPicture.asset(
        "assets/Icons/amity_ic_chat_deleted_user_avatar.svg",
        package: 'amity_uikit_beta_service',
      );
    } else {
      final isAvatarAvailable = avatarUrl != null && avatarUrl!.isNotEmpty;
      if (isAvatarAvailable) {
        return SizedBox(
          width: avatarSize.width,
          height: avatarSize.height,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(avatarSize.width / 2),
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
        return avatarCharacter();
      }
    }
  }

  Widget avatarCharacter() {
    return Container(
      height: avatarSize.height,
      width: avatarSize.width,
      decoration: BoxDecoration(
        // Every rung of the primary ramp is the same hex in both modes, so a
        // computed shade cannot flip. The avatar's flip lives in the token,
        // which points at a *different rung* per mode — shade2 on light,
        // shade1 on dark. blend() always lands on shade2, and does not even
        // reproduce the configured one (#C0D3FA computed vs #A9C4F9 in the
        // palette), so this was off from Android in light too.
        color: token(AmityColorToken.surfaceAvatarProfileDefault),
        shape: BoxShape.circle,
      ),
      child: Center(
          child: Text(
        displayName.isEmpty ? "" : displayName[0].toUpperCase(),
        style: characterTextStyle ??
            AmityTextStyle.custom(20, FontWeight.w400, Colors.white),
      )),
    );
  }
}
