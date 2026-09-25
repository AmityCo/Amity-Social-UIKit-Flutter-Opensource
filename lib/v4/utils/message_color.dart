import 'dart:ui';

import 'package:amity_uikit_beta_service/v4/core/theme/amity_color_token.dart';

/// The eleven colours a chat bubble draws with.
///
/// Each one now defaults to the semantic token the Android UIKit binds to the
/// same visual element (`AmityMessageBubble.kt` uses these exact field names),
/// rather than to a value derived from the flat theme — the derivations were
/// approximations of the design system that had drifted from it.
///
/// The legacy per-colour config keys (`left_bubble_color`,
/// `right_bubble_text_color`, …) still win when a host config supplies them.
/// They are a customization surface apps already depend on; they were dropped
/// from the bundled `config.json` so tokens drive by default, but a host copy
/// that still carries them keeps working. Deprecated — prefer a `customizations`
/// entry scoped to `*/message_bubble/*`, which the token cascade honours.
class MessageColor {
  MessageColor({
    required this.config,
    required Color Function(AmityColorToken) token,
  }) {
    leftBubbleDefault = _override('left_bubble_color') ??
        token(AmityColorToken.surfaceChatBubbleMessageInboundDefault);
    leftBubblePressed = _override('left_bubble_pressed_color') ??
        token(AmityColorToken.surfaceChatBubbleMessageInboundPressed);
    leftBubbleText = _override('left_bubble_text_color') ??
        token(AmityColorToken.textChatBubbleInboundMessagesDefault);
    leftBubbleSubtleText = _override('left_bubble_subtle_text_color') ??
        token(AmityColorToken.textChatBubbleInboundSeeMoreDefault);
    leftBubblePreviewLinkColor = _override('left_bubble_preview_link_color') ??
        token(AmityColorToken.surfaceCardPreviewLinkDefault);
    rightBubbleDefault = _override('right_bubble_color') ??
        token(AmityColorToken.surfaceChatBubbleMessageOutboundDefault);
    rightBubblePressed = _override('right_bubble_pressed_color') ??
        token(AmityColorToken.surfaceChatBubbleMessageOutboundPressed);
    rightBubbleText = _override('right_bubble_text_color') ??
        token(AmityColorToken.textChatBubbleOutboundMessagesDefault);
    rightBubbleSubtleText = _override('right_bubble_subtle_text_color') ??
        token(AmityColorToken.textChatBubbleOutboundSeeMoreDefault);
    rightBubblePreviewLinkColor = _override('right_bubble_preview_link_color') ??
        token(AmityColorToken.surfaceCardPreviewLinkDefault);
    bubbleDivider = _override('bubble_divider_color') ??
        token(AmityColorToken.lineChatBubbleInboundDividerDefault);
    // Android overrides only the outbound side and lets the inbound one double
    // as the shared default (AmityMessageBubble.kt:683), so the legacy
    // bubble_divider_color key keeps meaning the inbound divider.
    outboundBubbleDivider =
        token(AmityColorToken.lineChatBubbleOutboundDividerDefault);
    leftBubbleSeeMoreIcon =
        token(AmityColorToken.iconChatBubbleInboundSeeMoreDefault);
    rightBubbleSeeMoreIcon =
        token(AmityColorToken.iconChatBubbleOutboundSeeMoreDefault);
  }

  final Map<String, dynamic> config;

  late Color leftBubbleDefault;
  late Color leftBubblePressed;
  late Color leftBubbleText;
  late Color leftBubbleSubtleText;
  late Color leftBubblePreviewLinkColor;
  late Color rightBubbleDefault;
  late Color rightBubblePressed;
  late Color rightBubbleText;
  late Color rightBubbleSubtleText;
  late Color rightBubblePreviewLinkColor;
  late Color bubbleDivider;
  late Color outboundBubbleDivider;
  late Color leftBubbleSeeMoreIcon;
  late Color rightBubbleSeeMoreIcon;

  /// The legacy config value for [key], or null to fall through to the token.
  ///
  /// Returning null on an absent key is a fix, not just a refactor: the previous
  /// implementation ran a missing key through its hex parser, which answered
  /// `Color(0x00000000)`. Every one of these keys shipped in the bundled config,
  /// so it never showed — but a host config that omitted one drew that element
  /// fully transparent instead of falling back.
  Color? _override(String key) {
    final value = config[key];
    return value is String ? _colorFromHex(value) : null;
  }

  static Color? _colorFromHex(String hexColor) {
    var hex = hexColor.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    if (hex.length != 8) return null;
    final value = int.tryParse(hex, radix: 16);
    return value == null ? null : Color(value);
  }
}
