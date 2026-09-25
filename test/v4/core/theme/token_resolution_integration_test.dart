import 'dart:convert';
import 'dart:io';

import 'package:amity_uikit_beta_service/v4/core/config_repository.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/core/theme/amity_color_token.dart';
import 'package:amity_uikit_beta_service/v4/core/theme/amity_token_resolver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Token resolution as the widgets actually reach it: through the
/// ConfigRepository singleton, against an injected config.
///
/// The injection seam ([ConfigRepository.debugSetConfig]) exists because
/// resolution depends on `preferred_theme`, on the theme block and on
/// `customizations`, and none of the three is reachable through the public API.
/// It is also what finally lets PR #221's finding 1 be a test rather than a
/// manual step.
void main() {
  const bubble = AmityColorToken.surfaceChatBubbleMessageInboundDefault;
  late AmityTokenTable table;

  setUpAll(() {
    table = AmityTokenResolver.tableFromJson(
        jsonDecode(File('assets/tokens/amity-uikit-design-tokens.json')
            .readAsStringSync()) as Map<String, dynamic>);
  });

  // ConfigRepository is a singleton, so the runtime override outlives a test.
  // The public setter cannot express "no override" — AmityThemeStyle has no
  // null — so reset the notifier directly.
  void clearPreferredTheme() {
    ConfigRepository().preferredThemeNotifier.value = null;
  }

  setUp(clearPreferredTheme);
  tearDown(clearPreferredTheme);

  void useConfig(Map<String, dynamic> config) =>
      ConfigRepository().debugSetConfig(config, tokenTable: table);

  Map<String, dynamic> config({
    String preferredTheme = 'default',
    Map<String, String>? light,
    Map<String, String>? dark,
    Map<String, dynamic>? customizations,
  }) =>
      {
        'preferred_theme': preferredTheme,
        'theme': {
          'light': {'neutral_grey_shade1_color': '#EBECEF', ...?light},
          'dark': {'neutral_grey_shade6_color': '#292B32', ...?dark},
        },
        'customizations': customizations ?? const {},
      };

  Color resolve(WidgetTester tester, Brightness brightness,
      {String? scopeId}) {
    tester.platformDispatcher.platformBrightnessTestValue = brightness;
    return ConfigRepository().resolveToken(scopeId, bubble);
  }

  group('mode', () {
    testWidgets('light and dark follow different theme keys', (tester) async {
      // The token itself declares which key each mode follows.
      expect(bubble.themeKeyLight, 'neutral_grey_shade1_color');
      expect(bubble.themeKeyDark, 'neutral_grey_shade6_color');

      useConfig(config());
      expect(resolve(tester, Brightness.light), const Color(0xFFEBECEF));
      expect(resolve(tester, Brightness.dark), const Color(0xFF292B32));
    });

    // PR #221 finding 1, now a real test: `preferred_theme: "dark"` in the
    // config, a LIGHT device, and setPreferredTheme never called. Pre-fix this
    // fell through to `system` and rendered light — which for the token layer
    // would mean every one of the 723 tokens resolving to its light value on a
    // customer who asked for dark.
    testWidgets('config preferred_theme "dark" beats a light device',
        (tester) async {
      useConfig(config(preferredTheme: 'dark'));
      expect(resolve(tester, Brightness.light), const Color(0xFF292B32));
    });

    testWidgets('config preferred_theme "light" beats a dark device',
        (tester) async {
      useConfig(config(preferredTheme: 'light'));
      expect(resolve(tester, Brightness.dark), const Color(0xFFEBECEF));
    });

    testWidgets('a runtime override beats the config', (tester) async {
      useConfig(config(preferredTheme: 'light'));
      ConfigRepository().setPreferredTheme(AmityThemeStyle.dark);
      expect(resolve(tester, Brightness.light), const Color(0xFF292B32));
    });
  });

  group('the customization cascade', () {
    Map<String, dynamic> scoped(String scopeId, String hex) => {
          scopeId: {
            'theme': {
              'light': {'neutral_grey_shade1_color': hex}
            }
          }
        };

    testWidgets('the exact element scope wins over both wildcards',
        (tester) async {
      useConfig(config(customizations: {
        ...scoped('chat_page/message_bubble/text', '#111111'),
        ...scoped('*/message_bubble/*', '#222222'),
        ...scoped('chat_page/*/*', '#333333'),
      }));
      expect(
        resolve(tester, Brightness.light,
            scopeId: 'chat_page/message_bubble/text'),
        const Color(0xFF111111),
      );
    });

    testWidgets('an element-scoped entry beats a component-scoped one',
        (tester) async {
      useConfig(config(customizations: {
        ...scoped('chat_page/message_bubble/text', '#111111'),
        ...scoped('*/message_bubble/*', '#222222'),
      }));
      expect(
        resolve(tester, Brightness.light,
            scopeId: 'chat_page/message_bubble/avatar'),
        const Color(0xFF222222),
        reason: 'a different element falls back to the component wildcard',
      );
    });

    testWidgets('falls through to the page wildcard, then global',
        (tester) async {
      useConfig(config(customizations: scoped('chat_page/*/*', '#333333')));
      expect(
        resolve(tester, Brightness.light, scopeId: 'chat_page/other/x'),
        const Color(0xFF333333),
      );
      expect(
        resolve(tester, Brightness.light, scopeId: 'other_page/other/x'),
        const Color(0xFFEBECEF),
      );
    });

    testWidgets('a customization block with no theme key is ignored',
        (tester) async {
      useConfig(config(customizations: {
        'chat_page/message_bubble/text': {'title': 'Chat'}
      }));
      expect(
        resolve(tester, Brightness.light,
            scopeId: 'chat_page/message_bubble/text'),
        const Color(0xFFEBECEF),
      );
    });
  });

  group('memoization', () {
    testWidgets('a brightness change is not served from the cache',
        (tester) async {
      useConfig(config());
      expect(resolve(tester, Brightness.light), const Color(0xFFEBECEF));
      expect(resolve(tester, Brightness.dark), const Color(0xFF292B32));
      expect(resolve(tester, Brightness.light), const Color(0xFFEBECEF));
    });

    testWidgets('two scopes do not share a cache entry', (tester) async {
      useConfig(config(customizations: {
        'chat_page/message_bubble/text': {
          'theme': {
            'light': {'neutral_grey_shade1_color': '#111111'}
          }
        }
      }));
      expect(
          resolve(tester, Brightness.light,
              scopeId: 'chat_page/message_bubble/text'),
          const Color(0xFF111111));
      expect(resolve(tester, Brightness.light, scopeId: 'a/b/c'),
          const Color(0xFFEBECEF));
    });

    testWidgets('a new config drops the cache', (tester) async {
      useConfig(config());
      expect(resolve(tester, Brightness.light), const Color(0xFFEBECEF));
      useConfig(config(light: {'neutral_grey_shade1_color': '#ABCDEF'}));
      expect(resolve(tester, Brightness.light), const Color(0xFFABCDEF));
    });
  });

  group('degradation', () {
    testWidgets('a config missing the key backfills to the bundled default',
        (tester) async {
      useConfig({
        'preferred_theme': 'light',
        'theme': {
          'light': {'primary_color': '#1054DE'}
        },
      });
      // neutral_grey_shade1_color is absent from that config; the compiled-in
      // defaults fill it rather than the token going magenta.
      expect(resolve(tester, Brightness.light), const Color(0xFFEBECEF));
    });

    testWidgets('a token with no table entry is magenta, loudly',
        (tester) async {
      ConfigRepository().debugSetConfig(config(),
          tokenTable: const AmityTokenTable(alias: {}, semantic: {}));
      expect(resolve(tester, Brightness.light), const Color(0xFFFF00FF));
    });

    testWidgets('debugResolveToken reports where a value came from',
        (tester) async {
      useConfig(config(customizations: {
        'chat_page/message_bubble/text': {
          'theme': {
            'light': {'neutral_grey_shade1_color': '#111111'}
          }
        }
      }));
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
      expect(
        ConfigRepository()
            .debugResolveToken('chat_page/message_bubble/text', bubble)
            .source,
        'theme:neutral_grey_shade1_color@scope:chat_page/message_bubble/text',
      );
      expect(
        ConfigRepository().debugResolveToken('a/b/c', bubble).source,
        'theme:neutral_grey_shade1_color@global',
      );
    });
  });
}
