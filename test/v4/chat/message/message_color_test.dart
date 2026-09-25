import 'dart:ui';

import 'package:amity_uikit_beta_service/v4/core/theme/amity_color_token.dart';
import 'package:amity_uikit_beta_service/v4/utils/message_color.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Every token gets a distinct colour so a swapped binding shows up as a
  // wrong value rather than a coincidental match.
  final seen = <AmityColorToken>[];
  Color fakeToken(AmityColorToken t) {
    seen.add(t);
    return Color(0xFF000000 | t.index);
  }

  Color of(AmityColorToken t) => Color(0xFF000000 | t.index);

  setUp(seen.clear);

  test('each bubble colour binds to the Android UIKit token for that element',
      () {
    final c = MessageColor(config: const {}, token: fakeToken);

    expect(c.leftBubbleDefault,
        of(AmityColorToken.surfaceChatBubbleMessageInboundDefault));
    expect(c.leftBubblePressed,
        of(AmityColorToken.surfaceChatBubbleMessageInboundPressed));
    expect(c.leftBubbleText,
        of(AmityColorToken.textChatBubbleInboundMessagesDefault));
    expect(c.leftBubbleSubtleText,
        of(AmityColorToken.textChatBubbleInboundSeeMoreDefault));
    expect(c.leftBubblePreviewLinkColor,
        of(AmityColorToken.surfaceCardPreviewLinkDefault));
    expect(c.rightBubbleDefault,
        of(AmityColorToken.surfaceChatBubbleMessageOutboundDefault));
    expect(c.rightBubblePressed,
        of(AmityColorToken.surfaceChatBubbleMessageOutboundPressed));
    expect(c.rightBubbleText,
        of(AmityColorToken.textChatBubbleOutboundMessagesDefault));
    expect(c.rightBubbleSubtleText,
        of(AmityColorToken.textChatBubbleOutboundSeeMoreDefault));
    expect(c.rightBubblePreviewLinkColor,
        of(AmityColorToken.surfaceCardPreviewLinkDefault));
    expect(c.bubbleDivider,
        of(AmityColorToken.lineChatBubbleInboundDividerDefault));
  });

  group('the legacy config shim', () {
    test('a supplied key wins over the token', () {
      final c = MessageColor(
        config: const {'left_bubble_color': '#123456'},
        token: fakeToken,
      );
      expect(c.leftBubbleDefault, const Color(0xFF123456));
      expect(c.rightBubbleDefault,
          of(AmityColorToken.surfaceChatBubbleMessageOutboundDefault),
          reason: 'the other ten still come from tokens');
    });

    test('8-digit hex keeps its alpha', () {
      final c = MessageColor(
        config: const {'left_bubble_color': '#12345680'},
        token: fakeToken,
      );
      expect(c.leftBubbleDefault, const Color(0x12345680));
    });

    // The previous implementation ran an absent key through its hex parser,
    // which answered Color(0x00000000) — transparent — instead of the default.
    // Every key shipped in the bundled config so it never showed, but a host
    // config omitting one drew that element invisible.
    test('an absent key falls through to the token, not to transparent', () {
      final c = MessageColor(config: const {}, token: fakeToken);
      expect(c.leftBubbleDefault.a, 1.0);
    });

    test('a malformed value falls through to the token', () {
      for (final bad in ['', 'not-a-colour', '#12', '#GGGGGG', 42]) {
        final c = MessageColor(
          config: {'left_bubble_color': bad},
          token: fakeToken,
        );
        expect(c.leftBubbleDefault,
            of(AmityColorToken.surfaceChatBubbleMessageInboundDefault),
            reason: 'value: $bad');
      }
    });
  });
}
