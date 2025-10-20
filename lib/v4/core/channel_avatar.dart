import 'dart:ui';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/base_element.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AmityChannelAvatar extends BaseElement {
  late final String avatarPlaceholder;
  late final String? avatarUrl;
  late final Size placeholderSize;
  late final String displayName;
  late final Size avatarSize;
  late final TextStyle? characterTextStyle;
  late final double borderRadius;
  late final AmityChannel? channel;
  late final bool showPrivateBadge;

  AmityChannelAvatar({
    this.avatarUrl,
    required this.displayName,
    this.avatarSize = const Size(40, 40),
    this.placeholderSize = const Size(16, 16),
    this.avatarPlaceholder =
        "assets/Icons/amity_ic_group_chat_avatar_placeholder.svg",
    this.characterTextStyle,
    this.borderRadius = 10.0,
    this.showPrivateBadge = false,
    super.key,
    super.pageId = "",
    super.componentId = "",
    super.elementId = "",
  }) : channel = null;

  AmityChannelAvatar.withChannel({
    AmityChannel? channel,
    this.avatarSize = const Size(40, 40),
    this.placeholderSize = const Size(16, 16),
    this.avatarPlaceholder =
        "assets/Icons/amity_ic_group_chat_avatar_placeholder.svg",
    this.characterTextStyle,
    this.borderRadius = 10.0,
    this.showPrivateBadge = false,
    super.key,
    super.pageId = "",
    super.componentId = "",
    super.elementId = "",
  }) {
    this.channel = channel;
    avatarUrl = channel?.avatar?.getUrl(AmityImageSize.MEDIUM);
    displayName = channel?.displayName ?? "";
  }

  @override
  Widget buildElement(BuildContext context) {
    final isAvatarAvailable = avatarUrl != null && avatarUrl!.isNotEmpty;

    Widget avatarWidget;
    if (isAvatarAvailable) {
      avatarWidget = SizedBox(
        width: avatarSize.width,
        height: avatarSize.height,
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
          child: Image.network(
            avatarUrl!,
            fit: BoxFit.cover,
            loadingBuilder: (BuildContext context, Widget child,
                ImageChunkEvent? loadingProgress) {
              if (loadingProgress == null) {
                return child;
              } else {
                return placeHolderImage();
              }
            },
            errorBuilder:
                (BuildContext context, Object error, StackTrace? stackTrace) {
              return placeHolderImage();
            },
          ),
        ),
      );
    } else {
      avatarWidget = placeHolderImage();
    }

    if (showPrivateBadge) {
      return Container(
        height: avatarSize.height + 2,
        width: avatarSize.width + 2,
        child: Stack(
          // clipBehavior: Clip.none,
          children: [
            avatarWidget,
            Positioned(
              bottom: 0,
              right: 0,
              child: _buildPrivateBadge(),
            ),
          ],
        ),
      );
    } else {
      return avatarWidget;
    }
  }

  Widget placeHolderImage() {
    return Container(
      height: avatarSize.height,
      width: avatarSize.width,
      decoration: BoxDecoration(
        color: theme.primaryColor.blend(ColorBlendingOption.shade2),
        borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
      ),
      child: Center(
        child: SvgPicture.asset(
          avatarPlaceholder,
          package: 'amity_uikit_beta_service',
          height: placeholderSize.height,
          width: placeholderSize.width,
        ),
      ),
    );
  }

  Widget _buildPrivateBadge() {
    return Container(
      width: 16,
      height: 16,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: theme.primaryColor.blend(ColorBlendingOption.shade2),
        shape: BoxShape.circle,
        border: Border.all(
          color: theme.backgroundColor,
          width: 1,
        ),
      ),
      child: SvgPicture.asset(
        "assets/Icons/amity_ic_private_community_channel.svg",
        package: 'amity_uikit_beta_service',
        color: theme.backgroundColor,
      ),
    );
  }
}
