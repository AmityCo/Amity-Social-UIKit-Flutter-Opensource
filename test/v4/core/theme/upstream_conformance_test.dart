import 'dart:convert';
import 'dart:io';

import 'package:amity_uikit_beta_service/v4/core/theme/amity_token_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

/// The design system's own conformance suite for schema_version 3 resolution.
///
/// `test/fixtures/upstream/` is vendored from the cleverden colour-system repo
/// (`colors-v2/config-resolution-testvectors.json` and
/// `uikit/amity-uikit-config.json`, branch `feat/figma-extract-pipeline`,
/// commit f652b4e4, 2026-07-24) — the same pipeline that emits
/// `amity-uikit-design-tokens.json`, whose vendored copy here is sha256-identical
/// to the upstream one.
///
/// This is a stronger oracle than the Android-derived checks next door: those
/// compare against another implementation's output, this states what the
/// resolution chain is *supposed* to do, including the failure modes. Twenty
/// vectors, each with an expected value AND an expected source string.
///
/// Runner semantics, quoting the fixture: start from the base config,
/// deep-merge `configOverrides` (objects merge recursively; arrays and scalars
/// replace wholesale), then resolve `token` for `scope` + `mode`.
///
/// Two vectors also carry `tableOverrides`, which inject a synthetic token into
/// the table — the shipped table contains no `@alpha` cell at all, so the alpha
/// rules can only be exercised that way. Ignoring that field made
/// `alpha-out-of-range-clamps-to-opaque` fail (the token simply did not exist)
/// and made `unknown-alias-referenced-by-semantic-ref` pass for the wrong
/// reason: it expects magenta, and a missing token is also magenta.
void main() {
  late Map<String, dynamic> vectorFile;
  late Map<String, dynamic> baseConfig;
  late Map<String, dynamic> baseTable;
  late AmityTokenTable table;

  setUpAll(() {
    Map<String, dynamic> read(String p) =>
        jsonDecode(File(p).readAsStringSync()) as Map<String, dynamic>;
    vectorFile = read('test/fixtures/upstream/config-resolution-testvectors.json');
    baseConfig = read('test/fixtures/upstream/upstream-config.json');
    baseTable = read('assets/tokens/amity-uikit-design-tokens.json');
    table = AmityTokenResolver.tableFromJson(baseTable);
  });

  /// Objects merge key-by-key; anything else replaces.
  Map<String, dynamic> deepMerge(
      Map<String, dynamic> base, Map<String, dynamic> patch) {
    final out = Map<String, dynamic>.from(base);
    patch.forEach((k, v) {
      final existing = out[k];
      out[k] = (v is Map<String, dynamic> && existing is Map<String, dynamic>)
          ? deepMerge(existing, v)
          : v;
    });
    return out;
  }

  /// Reshape a raw config into what the resolver reads: the theme block, and
  /// `customizations[scope].theme[mode]` flattened to `customizations[scope][mode]`.
  AmityTokenConfig toTokenConfig(Map<String, dynamic> config) {
    Map<String, String> hexes(Object? v) =>
        (v as Map?)?.map((k, value) => MapEntry(k as String, '$value')) ??
        const {};
    final theme = <String, Map<String, String>>{};
    (config['theme'] as Map?)?.forEach((mode, keys) => theme['$mode'] = hexes(keys));
    final customizations = <String, Map<String, Map<String, String>>>{};
    (config['customizations'] as Map?)?.forEach((scope, block) {
      final byMode = (block as Map?)?['theme'] as Map?;
      if (byMode == null) return;
      customizations['$scope'] = {
        for (final e in byMode.entries) '${e.key}': hexes(e.value)
      };
    });
    return AmityTokenConfig(theme: theme, customizations: customizations);
  }

  /// The table a vector resolves against: the shipped one, plus any synthetic
  /// entries the vector injects.
  AmityTokenTable tableFor(Map<String, dynamic> v) {
    final patch = v['tableOverrides'] as Map<String, dynamic>?;
    if (patch == null) return table;
    return AmityTokenResolver.tableFromJson(deepMerge(baseTable, patch));
  }

  test('the fixture is the schema this resolver implements', () {
    expect(vectorFile['schema_version'], 3);
    expect((vectorFile['vectors'] as List).length, 20);
  });

  test('all 20 upstream vectors resolve to the expected value and source', () {
    final failures = <String>[];
    for (final raw in vectorFile['vectors'] as List) {
      final v = raw as Map<String, dynamic>;
      final overrides = v['configOverrides'] as Map<String, dynamic>?;
      final config = toTokenConfig(
          overrides == null ? baseConfig : deepMerge(baseConfig, overrides));

      final got = AmityTokenResolver.resolveToken(config, tableFor(v),
          v['scope'] as String?, v['mode'] as String, v['token'] as String);
      final want = v['expected'] as Map<String, dynamic>;

      if (got.value.toUpperCase() !=
          (want['value'] as String).toUpperCase()) {
        failures.add('${v['name']}: value ${got.value}, expected ${want['value']}');
      }
      if (got.source != want['source']) {
        failures.add('${v['name']}: source ${got.source}, expected ${want['source']}');
      }
    }
    expect(failures, isEmpty);
  });

  // Named individually so a regression says which rule broke rather than just
  // "one of twenty". These are the chain's edges: alpha, literals, bad hex,
  // unknown refs, and each rung of the cascade.
  for (final name in const [
    'global-light-ordinary',
    'global-dark-ordinary',
    'alias-lands-on-new-key',
    'alias-lands-on-existing-key',
    'scope-override-recolors-token',
    'scope-override-of-new-key',
    'wildcard-component-beats-page-and-global',
    'wildcard-page-applies-when-no-component-match',
    'wildcard-exact-beats-component-and-page',
    'primary-shade4-designed-value',
    'alpha-modifier-produces-8-digit-hex',
    'transparent-white-alias-alpha-8digit',
    'literal-hex-cell',
    'atomic-name-alias-black-black',
    'unknown-token-path',
    'unknown-alias-referenced-by-semantic-ref',
    'bad-hex-in-scope-override-falls-through',
    'bad-hex-in-global-theme-is-missing',
    'alpha-out-of-range-clamps-to-opaque',
    'mixed-case-theme-value-uppercased',
  ]) {
    test('vector: $name', () {
      final v = (vectorFile['vectors'] as List)
          .cast<Map<String, dynamic>>()
          .firstWhere((x) => x['name'] == name,
              orElse: () => throw StateError('vector "$name" is gone — the '
                  'fixture changed and this list did not'));
      final overrides = v['configOverrides'] as Map<String, dynamic>?;
      final config = toTokenConfig(
          overrides == null ? baseConfig : deepMerge(baseConfig, overrides));
      final got = AmityTokenResolver.resolveToken(config, tableFor(v),
          v['scope'] as String?, v['mode'] as String, v['token'] as String);
      final want = v['expected'] as Map<String, dynamic>;
      expect(got.value.toUpperCase(), (want['value'] as String).toUpperCase());
      expect(got.source, want['source']);
    });
  }
}
