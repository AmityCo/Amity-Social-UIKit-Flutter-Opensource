import 'dart:convert';
import 'dart:io';

import 'package:amity_uikit_beta_service/v4/core/theme/amity_color_token.dart';
import 'package:amity_uikit_beta_service/v4/core/theme/amity_theme_defaults.dart';
import 'package:amity_uikit_beta_service/v4/core/theme/amity_token_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

/// Parity between the resolver and the generated token model.
///
/// The model's themeKeyLight/themeKeyDark are emitted by cleverden's
/// `scripts/uikit-build-token-model.mjs` walking the alias chain — the same
/// generator that emits the Swift, Kotlin and TypeScript models. Re-resolving
/// all 723 x 2 cells through this implementation and requiring the answer to
/// equal the value at the generator's recorded key checks the whole chain —
/// alias chase, theme lookup, hex normalisation — against an artifact this
/// code had no hand in producing.
///
/// Renamed from android_parity_test: the artifact was never Android's. Flutter
/// used to transliterate it out of `AmityColorToken.kt`, which made a consumer
/// look like the source. The independence this test relies on is real either
/// way, but it comes from the generator, not from Android.
///
/// For what the chain is *supposed* to do — as opposed to what another emit of
/// the same generator agrees it does — see upstream_conformance_test.dart,
/// which runs the design system's own twenty vectors.
void main() {
  late AmityTokenTable table;

  setUpAll(() {
    table = AmityTokenResolver.tableFromJson(
        jsonDecode(File('assets/tokens/amity-uikit-design-tokens.json')
            .readAsStringSync()) as Map<String, dynamic>);
  });

  const config =
      AmityTokenConfig(theme: kAmityThemeDefaults, customizations: {});

  ({String? key, String expected}) contract(AmityColorToken t, String mode) =>
      mode == 'light'
          ? (key: t.themeKeyLight, expected: t.defaultLightHex)
          : (key: t.themeKeyDark, expected: t.defaultDarkHex);

  test('all 723 tokens x 2 modes resolve to the key the generator recorded', () {
    final mismatches = <String>[];
    for (final t in AmityColorToken.values) {
      for (final mode in ['light', 'dark']) {
        final c = contract(t, mode);
        final got =
            AmityTokenResolver.resolveToken(config, table, null, mode, t.path)
                .value;
        final want = c.key == null
            ? c.expected // a fixed literal: the table carries the hex itself
            : kAmityThemeDefaults[mode]![c.key]!;
        if (got.toUpperCase() != want.toUpperCase()) {
          mismatches.add('${t.path}[$mode] via ${c.key}: '
              'expected $want, resolver gave $got');
        }
      }
    }
    expect(mismatches, isEmpty,
        reason: '${mismatches.length} of ${AmityColorToken.values.length * 2} '
            'cells diverge from the generated model');
  });

  test('the resolver reports the theme key it actually followed', () {
    final wrongSource = <String>[];
    for (final t in AmityColorToken.values) {
      for (final mode in ['light', 'dark']) {
        final key = contract(t, mode).key;
        if (key == null) continue;
        final source = AmityTokenResolver
            .resolveToken(config, table, null, mode, t.path)
            .source;
        if (source != 'theme:$key@global') {
          wrongSource.add('${t.path}[$mode]: $source, expected key $key');
        }
      }
    }
    expect(wrongSource, isEmpty);
  });

  // The generator records defaultLightHex/defaultDarkHex from the design
  // system, upstream of the alias table. The alias table is lossy on purpose —
  // several design values collapse onto one customer-facing theme key, so a
  // customer gets one knob where the design system had two. This pins that
  // collapse rather than leaving it as a surprise: these tokens look different
  // out of the box and are identical once a config drives them, on BOTH
  // platforms equally.
  test('the alias table collapses distinct design values onto one theme key',
      () {
    final byKey = <String, Set<String>>{};
    for (final t in AmityColorToken.values) {
      for (final mode in ['light', 'dark']) {
        final c = contract(t, mode);
        if (c.key == null) continue;
        (byKey['$mode:${c.key}'] ??= {}).add(c.expected.toUpperCase());
      }
    }
    final collapsed = byKey.entries.where((e) => e.value.length > 1).toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    expect(collapsed.length, 11,
        reason: 'the number of lossy keys changed — re-check the alias table '
            'against Android before accepting: '
            '${collapsed.map((e) => '${e.key} -> ${e.value.toList()..sort()}').join('; ')}');

    // Every one of them still resolves to a single colour at runtime, which is
    // the point: the loss happens in the table, not in this implementation.
    for (final e in collapsed) {
      final parts = e.key.split(':');
      expect(kAmityThemeDefaults[parts[0]]![parts[1]], isNotNull);
    }
  });

  test('a scope with no customization resolves exactly like no scope at all',
      () {
    final drifted = AmityColorToken.values
        .where((t) => ['light', 'dark'].any((mode) =>
            AmityTokenResolver.resolveToken(config, table, null, mode, t.path)
                .value !=
            AmityTokenResolver.resolveToken(config, table,
                    'no_page/no_component/no_element', mode, t.path)
                .value))
        .toList();
    expect(drifted, isEmpty,
        reason: 'otherwise a widget that passes a scope id would drift from '
            'one that does not');
  });
}
