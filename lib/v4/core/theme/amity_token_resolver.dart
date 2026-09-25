import 'dart:ui' show Color;

/// Resolves a semantic colour token to a hex value.
///
/// A 1:1 port of the Android UIKit's `AmityTokenResolver.kt`. Deliberately free
/// of `package:flutter` so it unit-tests without a widget binding, mirroring the
/// Kotlin file's "pure JVM, no Android imports" constraint — the only pull from
/// the engine is `dart:ui`'s [Color], for [amityTokenColor].
///
/// Resolution chain: semantic cell -> literal hex, or "{Alias}" -> alias table ->
/// `"{theme.<key>}"` -> theme-key lookup through the scope cascade (exact scope,
/// wildcard-component, wildcard-page, global), then an optional "@alpha:<0..1>"
/// modifier (a semantic-level alpha wins over an alias-level one). Both JSON
/// artifacts are machine-generated, so anything that doesn't match these shapes
/// resolves to [missingColor] — the visible magenta is the debug signal for a
/// broken token.
class AmityTokenResolver {
  AmityTokenResolver._();

  static const String missingColor = '#FF00FF';

  /// Vendored table artifact: assets/tokens/amity-uikit-design-tokens.json.
  ///
  /// [alias] maps aliasName -> `"{theme.<key>}(@alpha:x)?"`.
  /// [semantic] maps tokenPath -> mode -> cell ("{Alias}(@alpha:x)?" or literal hex).
  static AmityTokenTable tableFromJson(Map<String, dynamic> json) {
    Map<String, String> flat(Object? v) => (v as Map?)
            ?.map((k, value) => MapEntry(k as String, value as String)) ??
        const {};
    final semantic = <String, Map<String, String>>{};
    (json['semantic'] as Map?)?.forEach((path, byMode) {
      semantic[path as String] = flat(byMode);
    });
    return AmityTokenTable(alias: flat(json['alias']), semantic: semantic);
  }

  static bool _isHex(String? value) =>
      value != null &&
      (value.length == 7 || value.length == 9) &&
      value[0] == '#' &&
      value
          .substring(1)
          .split('')
          .every((c) => RegExp(r'[0-9a-fA-F]').hasMatch(c));

  /// "{Name}" from "{Name}@alpha:x", or null when the shape doesn't match.
  static String? _refName(String cell) {
    if (!cell.startsWith('{') || !cell.contains('}')) return null;
    return cell.substring(1, cell.indexOf('}'));
  }

  /// The "@alpha:x" suffix as a double, or null when absent/unparseable.
  static double? _refAlpha(String cell) {
    const marker = '@alpha:';
    final i = cell.indexOf(marker);
    if (i < 0) return null;
    return double.tryParse(cell.substring(i + marker.length));
  }

  /// Append the alpha byte as #RRGGBBAA (overwriting any existing alpha channel).
  static String _applyAlpha(String hex, double? alpha) {
    if (alpha == null) return hex;
    final byte = (alpha.clamp(0.0, 1.0) * 255).round();
    return hex.substring(0, 7) +
        byte.toRadixString(16).toUpperCase().padLeft(2, '0');
  }

  /// Ordered cascade candidates, most-specific first:
  /// exact scope, then wildcard-component, then wildcard-page, then null (global).
  static List<String?> cascadeCandidates(String? scopeId) {
    final parts = (scopeId ?? '').split('/');
    String at(int i) {
      final p = i < parts.length ? parts[i] : '';
      return p.isEmpty ? '*' : p;
    }

    final exact = '${at(0)}/${at(1)}/${at(2)}';
    final byComponent = '*/${at(1)}/*';
    final byPage = '${at(0)}/*/*';
    final candidates = <String?>[exact];
    if (byComponent != exact) candidates.add(byComponent);
    if (byPage != exact && byPage != byComponent) candidates.add(byPage);
    candidates.add(null); // global
    return candidates;
  }

  /// Walk the cascade candidates for [key], reading
  /// customizations[candidate].theme[mode][key] (or config.theme[mode][key] for
  /// the global/null candidate). A value present but failing the hex check is
  /// skipped, falling through to the next cascade level.
  static AmityResolvedToken resolveThemeKey(
    AmityTokenConfig config,
    String? scopeId,
    String mode,
    String key,
  ) {
    for (final cId in cascadeCandidates(scopeId)) {
      final themeBlock =
          cId == null ? config.theme[mode] : config.customizations[cId]?[mode];
      final v = themeBlock?[key];
      if (v == null) continue;
      if (_isHex(v)) {
        final source =
            cId == null ? 'theme:$key@global' : 'theme:$key@scope:$cId';
        return AmityResolvedToken(v.toUpperCase(), source);
      }
    }
    return const AmityResolvedToken(missingColor, 'missing');
  }

  /// The semantic/alias/theme chain — see the class doc.
  static AmityResolvedToken resolveToken(
    AmityTokenConfig config,
    AmityTokenTable table,
    String? scopeId,
    String mode,
    String tokenPath,
  ) {
    final cell = table.semantic[tokenPath]?[mode];
    if (cell == null) return const AmityResolvedToken(missingColor, 'missing');

    if (_isHex(cell)) {
      return AmityResolvedToken(cell.toUpperCase(), 'literal');
    }

    final aliasName = _refName(cell);
    if (aliasName == null) {
      return const AmityResolvedToken(missingColor, 'missing');
    }
    final aliasTarget = table.alias[aliasName];
    if (aliasTarget == null) {
      return const AmityResolvedToken(missingColor, 'missing');
    }
    final aliasRef = _refName(aliasTarget);
    if (aliasRef == null || !aliasRef.startsWith('theme.')) {
      return const AmityResolvedToken(missingColor, 'missing');
    }
    final themeKey = aliasRef.substring('theme.'.length);

    final resolved = resolveThemeKey(config, scopeId, mode, themeKey);
    if (resolved.source == 'missing') return resolved;

    // Semantic-level alpha wins over alias-level.
    final alpha = _refAlpha(cell) ?? _refAlpha(aliasTarget);
    return AmityResolvedToken(
        _applyAlpha(resolved.value, alpha).toUpperCase(), resolved.source);
  }

  /// Build the EFFECTIVE config to resolve against. A host app customises by
  /// replacing the bundled `config.json` wholesale, so it can be missing theme
  /// keys — an app carrying a config from before the key set was widened has
  /// only the original 11. This fills any global theme key absent from [config]
  /// with the value from [defaults], per mode. Host-set values always win;
  /// `customizations` is left untouched. Pure — returns a new object, mutates
  /// nothing.
  static AmityTokenConfig backfillThemeDefaults(
    AmityTokenConfig config,
    AmityTokenConfig defaults,
  ) {
    final out = <String, Map<String, String>>{};
    final modes = {...defaults.theme.keys, ...config.theme.keys};
    for (final mode in modes) {
      out[mode] = {
        ...?defaults.theme[mode],
        ...?config.theme[mode], // host wins
      };
    }
    return AmityTokenConfig(theme: out, customizations: config.customizations);
  }
}

/// The vendored token table: alias chain + per-mode semantic cells.
class AmityTokenTable {
  const AmityTokenTable({required this.alias, required this.semantic});

  /// aliasName -> `"{theme.<key>}(@alpha:x)?"`
  final Map<String, String> alias;

  /// tokenPath -> mode -> cell ("{Alias}(@alpha:x)?" or literal hex)
  final Map<String, Map<String, String>> semantic;
}

/// The effective config to resolve against.
class AmityTokenConfig {
  const AmityTokenConfig({required this.theme, required this.customizations});

  /// mode (`"light"`|`"dark"`) -> themeKey -> hex
  final Map<String, Map<String, String>> theme;

  /// scopeId (`"page/component/element"`) -> mode -> themeKey -> hex
  final Map<String, Map<String, Map<String, String>>> customizations;
}

class AmityResolvedToken {
  const AmityResolvedToken(this.value, this.source);

  final String value;

  /// Where the value came from: `literal`, `theme:<key>@global`,
  /// `theme:<key>@scope:<id>`, or `missing`. Kept for debugging a wrong colour.
  final String source;
}

/// Convert a resolver hex string to a [Color]. The token system emits 6-digit
/// "#RRGGBB" or 8-digit "#RRGGBBAA" (alpha LAST); Dart's Color(int) wants
/// 0xAARRGGBB, so 8-digit values are reordered. Anything malformed (including
/// the [AmityTokenResolver.missingColor] path) falls back to loud magenta.
Color amityTokenColor(String hex) {
  final h = hex.startsWith('#') ? hex.substring(1) : hex;
  try {
    if (h.length == 6) return Color(int.parse('FF$h', radix: 16));
    if (h.length == 8) {
      final rgb = h.substring(0, 6);
      final alpha = h.substring(6, 8);
      return Color(int.parse('$alpha$rgb', radix: 16));
    }
  } on FormatException {
    return const Color(0xFFFF00FF);
  }
  return const Color(0xFFFF00FF);
}
