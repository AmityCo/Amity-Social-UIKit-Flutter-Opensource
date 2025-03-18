import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/base_element.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AmityMessageAvatar extends BaseElement {
  final AmityChannelMember? channelMember;
  final String avatarPlaceholder =
      "assets/Icons/amity_ic_user_avatar_placeholder.svg";

  late final String? avatarUrl;
  late final bool isDeletedUser;
  late final String displayName;

  AmityMessageAvatar(
      {required this.channelMember,
      super.key,
      super.pageId = "",
      super.componentId = "",
      super.elementId = "chat-avatar"}) {
    avatarUrl = channelMember?.user?.avatarUrl;
    isDeletedUser = channelMember?.isDeleted ?? true;
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
        return avatarCharacter();
      }
    }
  }

  Widget avatarCharacter() {
    return Container(
      height: 32,
      width: 32,
      decoration: BoxDecoration(
        color: theme.primaryColor.blend(ColorBlendingOption.shade2),
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
