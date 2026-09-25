import 'dart:convert';
import 'dart:io';

import 'package:amity_uikit_beta_service/v4/core/theme/amity_token_resolver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Unit tests for the token resolver. Pure Dart — no widget binding, no assets
/// (the vendored table is read off disk for the shape check at the end).
void main() {
  const missing = AmityTokenResolver.missingColor;

  AmityTokenConfig cfg({
    Map<String, Map<String, String>>? theme,
    Map<String, Map<String, Map<String, String>>>? customizations,
  }) =>
      AmityTokenConfig(
        theme: theme ??
            {
              'light': {'primary_color': '#1054DE', 'white_color': '#FFFFFF'},
              'dark': {'primary_color': '#4A82F2', 'white_color': '#FFFFFF'},
            },
        customizations: customizations ?? const {},
      );

  AmityTokenTable table({
    Map<String, String>? alias,
    Map<String, Map<String, String>>? semantic,
  }) =>
      AmityTokenTable(
        alias: alias ?? const {'Primary/500': '{theme.primary_color}'},
        semantic: semantic ??
            const {
              'Surface/Button': {
                'light': '{Primary/500}',
                'dark': '{Primary/500}'
              },
            },
      );

  String resolve(
    String path, {
    String mode = 'light',
    String? scopeId,
    AmityTokenConfig? config,
    AmityTokenTable? tokens,
  }) =>
      AmityTokenResolver.resolveToken(
              config ?? cfg(), tokens ?? table(), scopeId, mode, path)
          .value;

  group('the semantic -> alias -> theme chain', () {
    test('an alias chases through to the theme key', () {
      expect(resolve('Surface/Button'), '#1054DE');
      expect(resolve('Surface/Button', mode: 'dark'), '#4A82F2');
    });

    test('a literal hex cell is returned as-is, upper-cased', () {
      final t = table(semantic: const {
        'Border/Fixed': {'light': '#abcdef', 'dark': '#abcdef'},
      });
      expect(resolve('Border/Fixed', tokens: t), '#ABCDEF');
      expect(
        AmityTokenResolver.resolveToken(cfg(), t, null, 'light', 'Border/Fixed')
            .source,
        'literal',
      );
    });

    test('an unknown token path is magenta', () {
      expect(resolve('Nope/Not/A/Token'), missing);
    });

    test('an unknown alias is magenta', () {
      final t = table(semantic: const {
        'Surface/Button': {'light': '{No/Such/Alias}', 'dark': '{No/Such}'},
      });
      expect(resolve('Surface/Button', tokens: t), missing);
    });

    test('an alias that does not point at a theme key is magenta', () {
      final t = table(
        alias: const {'Primary/500': '{something.else}'},
        semantic: const {
          'Surface/Button': {'light': '{Primary/500}', 'dark': '{Primary/500}'}
        },
      );
      expect(resolve('Surface/Button', tokens: t), missing);
    });

    test('a theme key absent from the config is magenta', () {
      final t = table(alias: const {'Primary/500': '{theme.nope_color}'});
      expect(resolve('Surface/Button', tokens: t), missing);
    });

    test('a mode the token has no cell for is magenta', () {
      final t = table(semantic: const {
        'Surface/Button': {'light': '{Primary/500}'},
      });
      expect(resolve('Surface/Button', mode: 'dark', tokens: t), missing);
    });
  });

  group('@alpha', () {
    test('applies at the semantic level, alpha last', () {
      final t = table(semantic: const {
        'Surface/Button': {
          'light': '{Primary/500}@alpha:0.5',
          'dark': '{Primary/500}'
        },
      });
      // 0.5 * 255 = 127.5 -> 128 -> 0x80
      expect(resolve('Surface/Button', tokens: t), '#1054DE80');
    });

    test('applies at the alias level', () {
      final t = table(alias: const {
        'Primary/500': '{theme.primary_color}@alpha:0.2',
      });
      expect(resolve('Surface/Button', tokens: t), '#1054DE33');
    });

    test('a semantic-level alpha beats an alias-level one', () {
      final t = table(
        alias: const {'Primary/500': '{theme.primary_color}@alpha:0.2'},
        semantic: const {
          'Surface/Button': {
            'light': '{Primary/500}@alpha:1',
            'dark': '{Primary/500}'
          }
        },
      );
      expect(resolve('Surface/Button', tokens: t), '#1054DEFF');
    });

    test('is clamped to 0..1', () {
      final t = table(alias: const {
        'Primary/500': '{theme.primary_color}@alpha:9',
      });
      expect(resolve('Surface/Button', tokens: t), '#1054DEFF');
    });

    test('overwrites an existing alpha channel rather than appending', () {
      final c = cfg(theme: {
        'light': {'primary_color': '#1054DE00'},
      });
      final t = table(alias: const {
        'Primary/500': '{theme.primary_color}@alpha:1',
      });
      expect(resolve('Surface/Button', config: c, tokens: t), '#1054DEFF');
    });
  });

  group('the scope cascade', () {
    final scoped = cfg(customizations: {
      'chat_page/message_bubble/text': {
        'light': {'primary_color': '#111111'}
      },
      '*/message_bubble/*': {
        'light': {'primary_color': '#222222'}
      },
      'chat_page/*/*': {
        'light': {'primary_color': '#333333'}
      },
    });

    test('candidate order is exact, wildcard-component, wildcard-page, global',
        () {
      expect(
        AmityTokenResolver.cascadeCandidates('chat_page/message_bubble/text'),
        ['chat_page/message_bubble/text', '*/message_bubble/*', 'chat_page/*/*', null],
      );
    });

    test('a null scope collapses to the global candidate only', () {
      expect(AmityTokenResolver.cascadeCandidates(null), ['*/*/*', null]);
    });

    test('the exact scope wins', () {
      expect(
        resolve('Surface/Button',
            scopeId: 'chat_page/message_bubble/text', config: scoped),
        '#111111',
      );
    });

    test('falls through to the component wildcard', () {
      expect(
        resolve('Surface/Button',
            scopeId: 'other_page/message_bubble/avatar', config: scoped),
        '#222222',
      );
    });

    test('falls through to the page wildcard', () {
      expect(
        resolve('Surface/Button',
            scopeId: 'chat_page/other_component/x', config: scoped),
        '#333333',
      );
    });

    test('falls through to global when no scope matches', () {
      expect(
        resolve('Surface/Button', scopeId: 'a/b/c', config: scoped),
        '#1054DE',
      );
    });

    test('a non-hex value at one level is skipped, not fatal', () {
      final broken = cfg(customizations: {
        'a/b/c': {
          'light': {'primary_color': 'not-a-colour'}
        },
      });
      expect(resolve('Surface/Button', scopeId: 'a/b/c', config: broken),
          '#1054DE');
    });

    test('a scope only present in the other mode does not leak', () {
      final darkOnly = cfg(customizations: {
        'a/b/c': {
          'dark': {'primary_color': '#999999'}
        },
      });
      expect(resolve('Surface/Button', scopeId: 'a/b/c', config: darkOnly),
          '#1054DE');
      expect(
        resolve('Surface/Button',
            scopeId: 'a/b/c', mode: 'dark', config: darkOnly),
        '#999999',
      );
    });
  });

  group('backfillThemeDefaults', () {
    test('fills only the keys the host config is missing', () {
      final defaults = cfg(theme: {
        'light': {'primary_color': '#000000', 'white_color': '#FFFFFF'},
        'dark': {'primary_color': '#000000'},
      });
      final host = cfg(theme: {
        'light': {'primary_color': '#1054DE'},
      });
      final merged =
          AmityTokenResolver.backfillThemeDefaults(host, defaults);
      expect(merged.theme['light']!['primary_color'], '#1054DE',
          reason: 'host wins');
      expect(merged.theme['light']!['white_color'], '#FFFFFF',
          reason: 'default fills the gap');
      expect(merged.theme['dark']!['primary_color'], '#000000',
          reason: 'a mode the host omits entirely comes from defaults');
    });

    test('leaves customizations untouched and mutates nothing', () {
      final custom = {
        'a/b/c': {
          'light': {'primary_color': '#123456'}
        }
      };
      final host = cfg(theme: {'light': {}}, customizations: custom);
      final merged = AmityTokenResolver.backfillThemeDefaults(host, cfg());
      expect(merged.customizations, same(custom));
      expect(host.theme['light'], isEmpty, reason: 'input not mutated');
    });
  });

  group('hex -> Color', () {
    test('6-digit is opaque', () {
      expect(amityTokenColor('#1054DE'), const Color(0xFF1054DE));
    });

    test('8-digit reorders alpha from last to first', () {
      expect(amityTokenColor('#1054DE80'), const Color(0x801054DE));
      expect(amityTokenColor('#1054DE00'), const Color(0x001054DE));
    });

    test('works without the leading hash', () {
      expect(amityTokenColor('1054DE'), const Color(0xFF1054DE));
    });

    for (final bad in ['', '#', '#12345', '#1234567', '#GGGGGG', 'nonsense']) {
      test('malformed "$bad" falls back to magenta', () {
        expect(amityTokenColor(bad), const Color(0xFFFF00FF));
      });
    }

    test('the missing-token sentinel is magenta', () {
      expect(amityTokenColor(AmityTokenResolver.missingColor),
          const Color(0xFFFF00FF));
    });
  });

  group('the vendored table', () {
    late AmityTokenTable vendored;

    setUpAll(() {
      final json = jsonDecode(
              File('assets/tokens/amity-uikit-design-tokens.json')
                  .readAsStringSync())
          as Map<String, dynamic>;
      vendored = AmityTokenResolver.tableFromJson(json);
    });

    test('has the shape the Android UIKit ships', () {
      expect(vendored.alias.length, 55);
      expect(vendored.semantic.length, 723);
    });

    test('every semantic cell is a literal hex or a resolvable alias', () {
      final unresolvable = <String>[];
      vendored.semantic.forEach((path, byMode) {
        byMode.forEach((mode, cell) {
          if (cell.startsWith('#')) return;
          final name = cell.startsWith('{') && cell.contains('}')
              ? cell.substring(1, cell.indexOf('}'))
              : null;
          if (name == null || !vendored.alias.containsKey(name)) {
            unresolvable.add('$path[$mode] = $cell');
          }
        });
      });
      expect(unresolvable, isEmpty);
    });

    test('every alias points at a theme key', () {
      final bad = vendored.alias.entries
          .where((e) => !e.value.startsWith('{theme.'))
          .map((e) => '${e.key} -> ${e.value}')
          .toList();
      expect(bad, isEmpty);
    });
  });
}
