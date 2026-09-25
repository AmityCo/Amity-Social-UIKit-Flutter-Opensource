import 'dart:convert';
import 'dart:io';

import 'package:amity_uikit_beta_service/v4/core/theme/amity_color_token.dart';
import 'package:amity_uikit_beta_service/v4/core/theme/amity_theme_defaults.dart';
import 'package:amity_uikit_beta_service/v4/core/theme/amity_token_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards the generated token model against drift from the artifacts it was
/// generated from. Runs without the Android checkout: the vendored table and the
/// bundled config are the only inputs.
void main() {
  late AmityTokenTable table;
  late Map<String, dynamic> config;

  setUpAll(() {
    table = AmityTokenResolver.tableFromJson(
        jsonDecode(File('assets/tokens/amity-uikit-design-tokens.json')
            .readAsStringSync()) as Map<String, dynamic>);
    config =
        jsonDecode(File('assets/config/config.json').readAsStringSync())
            as Map<String, dynamic>;
  });

  test('one entry per semantic token in the vendored table', () {
    expect(AmityColorToken.values.length, 723);
    expect(AmityColorToken.values.length, table.semantic.length);
  });

  test('paths are unique and all exist in the table', () {
    final paths = AmityColorToken.values.map((t) => t.path).toList();
    expect(paths.toSet().length, paths.length, reason: 'duplicate path');
    expect(paths.where((p) => !table.semantic.containsKey(p)), isEmpty);
  });

  // The theme keys are the load-bearing half of the model: they are what the
  // resolver actually follows. Recompute them from the alias chain and compare.
  test('every themeKeyLight/themeKeyDark matches the alias chain', () {
    String? refName(String cell) => cell.startsWith('{') && cell.contains('}')
        ? cell.substring(1, cell.indexOf('}'))
        : null;
    String? derive(String path, String mode) {
      final cell = table.semantic[path]?[mode];
      if (cell == null || cell.startsWith('#')) return null;
      final target = table.alias[refName(cell)];
      if (target == null) return '<unresolved alias>';
      final ref = refName(target);
      return (ref != null && ref.startsWith('theme.'))
          ? ref.substring('theme.'.length)
          : '<not a theme key>';
    }

    final mismatches = <String>[];
    for (final t in AmityColorToken.values) {
      if (derive(t.path, 'light') != t.themeKeyLight) {
        mismatches.add('${t.path}[light]');
      }
      if (derive(t.path, 'dark') != t.themeKeyDark) {
        mismatches.add('${t.path}[dark]');
      }
    }
    expect(mismatches, isEmpty);
  });

  test('every named theme key exists in the bundled config', () {
    final theme = config['theme'] as Map<String, dynamic>;
    final unknown = <String>{};
    for (final t in AmityColorToken.values) {
      for (final e in {
        'light': t.themeKeyLight,
        'dark': t.themeKeyDark,
      }.entries) {
        final key = e.value;
        if (key != null && !(theme[e.key] as Map).containsKey(key)) {
          unknown.add('${e.key}:$key');
        }
      }
    }
    expect(unknown, isEmpty,
        reason: 'a token follows a theme key config.json does not define, '
            'which resolves to magenta');
  });

  test('no token resolves to magenta against the bundled config', () {
    final effective = AmityTokenConfig(
      theme: (config['theme'] as Map).map((mode, keys) => MapEntry(
          mode as String, (keys as Map).cast<String, String>())),
      customizations: const {},
    );
    final broken = AmityColorToken.values
        .expand((t) => ['light', 'dark'].map((mode) => MapEntry(t, mode)))
        .where((e) =>
            AmityTokenResolver.resolveToken(
                effective, table, null, e.value, e.key.path)
                .value ==
            AmityTokenResolver.missingColor)
        .map((e) => '${e.key.path}[${e.value}]')
        .toList();
    expect(broken, isEmpty);
  });

  test('the defaults table mirrors the bundled config theme block', () {
    final theme = config['theme'] as Map<String, dynamic>;
    expect(kAmityThemeDefaults.keys.toSet(), theme.keys.toSet());
    for (final mode in theme.keys) {
      expect(kAmityThemeDefaults[mode], (theme[mode] as Map).cast<String, String>(),
          reason: 'regenerate from cleverden: node scripts/uikit-build-token-model.mjs '
              '&& node scripts/sync-flutter-tokens.mjs --apply');
    }
  });

  test('backfill rescues a config that predates the widened key set', () {
    // The 11 keys Flutter shipped before plan 36.
    const legacy = {
      'primary_color', 'secondary_color', 'base_color', 'base_inverse_color',
      'base_shade1_color', 'base_shade2_color', 'base_shade3_color',
      'base_shade4_color', 'alert_color', 'background_color', 'highlight_color',
    };
    final stale = AmityTokenConfig(
      theme: {
        for (final mode in kAmityThemeDefaults.keys)
          mode: {
            for (final e in kAmityThemeDefaults[mode]!.entries)
              if (legacy.contains(e.key)) e.key: e.value
          }
      },
      customizations: const {},
    );
    final effective = AmityTokenResolver.backfillThemeDefaults(
        stale,
        const AmityTokenConfig(
            theme: kAmityThemeDefaults, customizations: {}));

    final magenta = AmityColorToken.values
        .expand((t) => ['light', 'dark'].map((mode) => MapEntry(t, mode)))
        .where((e) =>
            AmityTokenResolver.resolveToken(
                effective, table, null, e.value, e.key.path)
                .value ==
            AmityTokenResolver.missingColor)
        .toList();
    expect(magenta, isEmpty,
        reason: 'a stale host config must degrade to bundled colours, '
            'not to magenta');
  });
}
