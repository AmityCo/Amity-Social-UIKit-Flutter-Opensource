import 'dart:convert';

import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/core/theme/amity_color_token.dart';
import 'package:amity_uikit_beta_service/v4/core/theme/amity_theme_defaults.dart';
import 'package:amity_uikit_beta_service/v4/core/theme/amity_token_resolver.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

class ConfigRepository {
  static final ConfigRepository _instance = ConfigRepository._internal();

  factory ConfigRepository() => _instance;

  ConfigRepository._internal();

  Map<String, dynamic> _config = {};
  Set<String> excludedList = {};
  bool _isConfigInitialized = false;

  /// Preferred theme set at runtime via [setPreferredTheme]. Takes precedence
  /// over `preferred_theme` from config.json; null means the config value.
  /// A ValueNotifier so [ConfigProvider] can rebuild the UIKit tree on change.
  final ValueNotifier<AmityThemeStyle?> preferredThemeNotifier =
      ValueNotifier(null);

  /// Changes the effective UIKit theme at runtime, effective immediately.
  /// [AmityThemeStyle.system] follows the device dark-mode setting.
  void setPreferredTheme(AmityThemeStyle style) {
    preferredThemeNotifier.value = style;
  }

  /// Resolved themes, keyed by config id + resolved theme style. See [getTheme].
  final Map<String, AmityThemeColor> _themeCache = {};

  /// The vendored semantic-token table. Empty until [loadConfig] runs, which
  /// makes every token resolve to magenta rather than to a plausible colour.
  AmityTokenTable _tokenTable =
      const AmityTokenTable(alias: {}, semantic: {});

  /// The effective config the token resolver reads: the host's theme block
  /// backfilled from the bundled defaults, plus the per-scope customizations.
  AmityTokenConfig _tokenConfig = const AmityTokenConfig(
      theme: kAmityThemeDefaults, customizations: {});

  /// Resolved token colours: scope -> token index -> [light, dark].
  /// See [resolveToken].
  final Map<String, Map<int, List<Color?>>> _tokenCache = {};

  static const String _globalScope = '*/*/*';

  Future<void> loadConfig() async {
    if (!_isConfigInitialized) {
      _config = await _loadConfigFile('config');
      _tokenTable = AmityTokenResolver.tableFromJson(
          await _loadJsonAsset('assets/tokens/amity-uikit-design-tokens.json'));
      _applyConfig();
      _isConfigInitialized = true;
    }
  }

  /// Replaces the loaded config wholesale. For tests that need a config other
  /// than the bundled asset — resolution depends on `preferred_theme`, on the
  /// theme block and on `customizations`, and none of those can be reached
  /// through the public API.
  @visibleForTesting
  void debugSetConfig(Map<String, dynamic> config,
      {AmityTokenTable? tokenTable}) {
    _config = config;
    if (tokenTable != null) _tokenTable = tokenTable;
    _applyConfig();
    _isConfigInitialized = true;
  }

  /// Recompute everything derived from [_config]. Both caches are keyed on the
  /// resolved theme style, so switching light/dark needs no invalidation — but
  /// a new config changes what those keys resolve TO, so both are dropped here.
  void _applyConfig() {
    excludedList = Set<String>.from(_config['excludes'] ?? []);
    _tokenConfig = _buildTokenConfig();
    _themeCache.clear();
    _tokenCache.clear();
  }

  /// A host app customises by replacing `config.json` wholesale, so its copy can
  /// predate a widening of the key set — hence the backfill from the compiled-in
  /// defaults. Host values always win; a missing key degrades to the bundled
  /// colour rather than to magenta.
  AmityTokenConfig _buildTokenConfig() {
    Map<String, String> hexes(Object? v) =>
        (v as Map?)?.map((k, value) => MapEntry(k as String, '$value')) ??
        const {};

    final theme = <String, Map<String, String>>{};
    (_config['theme'] as Map?)?.forEach((mode, keys) {
      theme['$mode'] = hexes(keys);
    });

    // customizations["<scope>"]["theme"]["<mode>"] -> the resolver wants
    // customizations["<scope>"]["<mode>"].
    final customizations = <String, Map<String, Map<String, String>>>{};
    (_config['customizations'] as Map?)?.forEach((scopeId, block) {
      final byMode = (block as Map?)?['theme'] as Map?;
      if (byMode == null) return;
      customizations['$scopeId'] = {
        for (final e in byMode.entries) '${e.key}': hexes(e.value)
      };
    });

    return AmityTokenResolver.backfillThemeDefaults(
      AmityTokenConfig(theme: theme, customizations: customizations),
      const AmityTokenConfig(theme: kAmityThemeDefaults, customizations: {}),
    );
  }

  Map<String, dynamic> getFeatureFlags() {
    return _config['feature_flags'] as Map<String, dynamic>? ?? {};
  }

  Map<String, dynamic> getConfig(String configId) {
    final id = configId.split('/');
    if (id.length != 3) {
      return {};
    }

    final customizationConfig =
        _config['customizations'] as Map<String, dynamic>? ?? {};

    if (customizationConfig.containsKey(configId)) {
      return customizationConfig[configId] as Map<String, dynamic>;
    }

    final variations = [
      '*/*/*',
      '*/${id[1]}/*',
      '*/*/${id[2]}',
      '*/${id[1]}/${id[2]}',
      '${id[0]}/*/*',
      '${id[0]}/${id[1]}/*',
      '${id[0]}/*/${id[2]}',
      '${id[0]}/${id[1]}/${id[2]}',
    ];

    for (var variation in variations) {
      if (customizationConfig.containsKey(variation)) {
        return customizationConfig[variation] as Map<String, dynamic>;
      }
    }

    return {};
  }

  Future<Map<String, dynamic>> _loadConfigFile(String fileName) =>
      _loadJsonAsset('assets/config/$fileName.json');

  Future<Map<String, dynamic>> _loadJsonAsset(String path) async {
    try {
      final jsonString = await rootBundle
          .loadString('packages/amity_uikit_beta_service/$path');
      return json.decode(jsonString);
    } catch (e) {
      return {};
    }
  }
}

extension ThemeConfig on ConfigRepository {
  AmityThemeStyle _getCurrentThemeStyle() {
    final systemStyle =
        SchedulerBinding.instance.platformDispatcher.platformBrightness;
    final configStyle = preferredThemeNotifier.value ??
        (_config['preferred_theme'] == 'dark'
            ? AmityThemeStyle.dark
            : _config['preferred_theme'] == 'light'
                ? AmityThemeStyle.light
                : AmityThemeStyle.system);

    final style = configStyle == AmityThemeStyle.system
        ? (systemStyle == Brightness.light
            ? AmityThemeStyle.light
            : AmityThemeStyle.dark)
        : (configStyle == AmityThemeStyle.light
            ? AmityThemeStyle.light
            : AmityThemeStyle.dark);
    return style;
  }

  /// Base widgets re-resolve their theme on every build, so this sits on the hot
  /// path — memoize it. The key carries the *resolved* style, so a change to the
  /// OS brightness or to the preferred theme lands on a different key and needs
  /// no explicit invalidation; only [loadConfig] clears the cache.
  AmityThemeColor getTheme(String? configId) {
    final style = _getCurrentThemeStyle();
    final cacheKey = '${configId ?? '*'}|${style.name}';
    return _themeCache[cacheKey] ??= _resolveTheme(configId, style);
  }

  /// Resolve a semantic colour token against the effective config.
  ///
  /// [scopeId] is `page/component/element`, `*` for any part the caller does not
  /// have; null means global. Resolution cascades exact -> `*/component/*` ->
  /// `page/*/*` -> global, so the most specific customization wins.
  ///
  /// Sits on the same hot path as [getTheme] — one call per themed property per
  /// build — and costs more per call (table lookup, alias chase, alpha), so it
  /// is memoized on scope + resolved style + path. The resolved style is in the
  /// key, so a brightness or preferred-theme change lands on a different entry;
  /// only a config change drops the cache.
  ///
  /// An unresolvable token returns magenta, deliberately: a wrong colour that is
  /// impossible to miss beats one that silently looks plausible.
  Color resolveToken(String? scopeId, AmityColorToken token) {
    final isLight = _getCurrentThemeStyle() == AmityThemeStyle.light;
    // Nested map rather than an interpolated key: this runs once per themed
    // property per build — a message list is a few hundred calls a frame — and
    // building '$scope|$mode|$path' allocated a String on every one of them,
    // hit or miss. Two map lookups and no allocation instead.
    final byToken = _tokenCache
        .putIfAbsent(scopeId ?? ConfigRepository._globalScope, () => <int, List<Color?>>{})
        .putIfAbsent(token.index, () => List<Color?>.filled(2, null));
    final slot = isLight ? 0 : 1;
    return byToken[slot] ??= amityTokenColor(AmityTokenResolver.resolveToken(
            _tokenConfig,
            _tokenTable,
            scopeId,
            isLight ? 'light' : 'dark',
            token.path)
        .value);
  }

  /// Whether tokens are currently resolving against the dark palette.
  ///
  /// For the handful of places that swap a whole asset rather than tint one —
  /// an illustration drawn light-on-white has no single fill to re-colour, so
  /// Android ships two drawables and picks between them. Reading the same
  /// signal [resolveToken] uses means an asset can never disagree with the
  /// tokens around it.
  bool get isDarkTheme => _getCurrentThemeStyle() == AmityThemeStyle.dark;

  /// The unresolved detail behind [resolveToken] — value plus where it came
  /// from (`literal`, `theme:<key>@global`, `theme:<key>@scope:<id>`,
  /// `missing`). For debugging a wrong colour; not on any render path.
  AmityResolvedToken debugResolveToken(String? scopeId, AmityColorToken token) {
    final mode =
        _getCurrentThemeStyle() == AmityThemeStyle.light ? 'light' : 'dark';
    return AmityTokenResolver.resolveToken(
        _tokenConfig, _tokenTable, scopeId, mode, token.path);
  }

  AmityThemeColor _resolveTheme(String? configId, AmityThemeStyle style) {
    final fallbackTheme =
        style == AmityThemeStyle.light ? lightTheme : darkTheme;
    final globalTheme = _getGlobalTheme(style, fallbackTheme);

    if (configId == null) {
      return _getThemeColor(globalTheme, fallbackTheme);
    }

    final customizationConfig =
        _config['customizations'] as Map<String, dynamic>?;
    final id = configId.split('/');
    if (id.length != 3) {
      return _getThemeColor(globalTheme, fallbackTheme);
    }

    final pageTheme =
        customizationConfig?['${id[0]}/*/*'] as Map<String, dynamic>?;
    final componentTheme = customizationConfig?['*/${id[1]}/*']
            as Map<String, dynamic>? ??
        customizationConfig?['${id[0]}/${id[1]}/*'] as Map<String, dynamic>?;

    try {
      if (componentTheme != null) {
        final theme = _getThemeColor(
            AmityTheme.fromJson(
                componentTheme["theme"]?[style.toString().split('.').last],
                fallbackTheme),
            fallbackTheme);
        return theme;
      }

      if (pageTheme != null) {
        return _getThemeColor(
            AmityTheme.fromJson(
                pageTheme["theme"]?[style.toString().split('.').last],
                fallbackTheme),
            fallbackTheme);
      }
    } catch (error) {
      return _getThemeColor(globalTheme, fallbackTheme);
    }

    return _getThemeColor(globalTheme, fallbackTheme);
  }

  AmityTheme? _getGlobalTheme(AmityThemeStyle style, AmityTheme fallbackTheme) {
    final globalTheme = _config['theme']?[style.toString().split('.').last]
        as Map<String, dynamic>?;
    if (globalTheme != null) {
      return AmityTheme.fromJson(globalTheme, fallbackTheme);
    }
    return null;
  }

  AmityThemeColor _getThemeColor(AmityTheme? theme, AmityTheme fallbackTheme) {
    return AmityThemeColor(
      primaryColor: theme?.primaryColor ?? fallbackTheme.primaryColor,
      secondaryColor: theme?.secondaryColor ?? fallbackTheme.secondaryColor,
      baseColor: theme?.baseColor ?? fallbackTheme.baseColor,
      baseColorShade1: theme?.baseColorShade1 ?? fallbackTheme.baseColorShade1,
      baseColorShade2: theme?.baseColorShade2 ?? fallbackTheme.baseColorShade2,
      baseColorShade3: theme?.baseColorShade3 ?? fallbackTheme.baseColorShade3,
      baseColorShade4: theme?.baseColorShade4 ?? fallbackTheme.baseColorShade4,
      alertColor: theme?.alertColor ?? fallbackTheme.alertColor,
      backgroundColor: theme?.backgroundColor ?? fallbackTheme.backgroundColor,
      baseInverseColor:
          theme?.baseInverseColor ?? fallbackTheme.baseInverseColor,
      backgroundShade1Color: fallbackTheme.backgroundShade1Color,
      highlightColor: theme?.highlightColor ?? fallbackTheme.highlightColor,
    );
  }

  LinearGradient getShimmerGradient() {
    // One colour at varying alpha, swept across — the model Android uses
    // (AmityComposeExt.kt:146-150, alphas .3/.5/1/.5/.3 over
    // Surface/SkeletonEffect/Default). The dark branch used to hardcode
    // Color.fromARGB(255,167,167,167) at BOTH ends with a dark middle, i.e.
    // the light/dark relationship inverted: the resting state of every
    // skeleton was #A7A7A7, a light grey block on a #191919 sheet
    // (PDT-5151). Deriving both modes from the token keeps them in step with
    // the palette instead of drifting again.
    final base = resolveToken(null, AmityColorToken.surfaceSkeletonEffectDefault);
    return LinearGradient(
      colors: [
        base.withOpacity(0.3),
        base.withOpacity(0.5),
        base.withOpacity(1.0),
        base.withOpacity(0.5),
        base.withOpacity(0.3),
      ],
      stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
      begin: const Alignment(-1.0, -0.3),
      end: const Alignment(1.0, 0.3),
      tileMode: TileMode.clamp,
    );
  }
}

class AmityReactionType {
  final String name;
  final String imagePath;

  AmityReactionType({required this.name, required this.imagePath});
}

extension MessageReactionConfig on ConfigRepository {
  Map<String, AmityReactionType> get availableReactions {
    final reactionsDict = _config['message_reactions'] as List<dynamic>? ?? [];

    Map<String, AmityReactionType> reactionsMap = {};
    for (var item in reactionsDict) {
      String name = item['name'] ?? '';
      String image = item['image'] ?? '';
      if (name.isNotEmpty && image.isNotEmpty) {
        reactionsMap[name] = AmityReactionType(name: name, imagePath: image);
      }
    }
    return reactionsMap;
  }

  List<AmityReactionType> getAllMessageReactions() {
    return availableReactions.values.toList();
  }

  AmityReactionType getReaction(String name) {
    return availableReactions[name] ??
        AmityReactionType(
            name: name,
            imagePath: 'assets/Icons/amity_ic_reaction_not_found.svg');
  }
}

class AmityChatUserActionType {
  final String name;
  final bool enabled;

  AmityChatUserActionType({required this.name, required this.enabled});
}

extension ConversationChatUserActionConfig on ConfigRepository {
  Map<String, AmityChatUserActionType> get availableChatUserActions {
    final actionsDict =
        _config['conversation_chat_user_actions'] as List<dynamic>? ?? [];

    Map<String, AmityChatUserActionType> actionsMap = {};
    for (var item in actionsDict) {
      String name = item['name'] ?? '';
      bool enabled = item['enabled'] ?? true;
      if (name.isNotEmpty) {
        actionsMap[name] =
            AmityChatUserActionType(name: name, enabled: enabled);
      }
    }
    return actionsMap;
  }

  bool isChatUserActionEnabled(String actionName) {
    final action = availableChatUserActions[actionName];
    return action?.enabled ?? true;
  }

  bool hasAnyEnabledChatUserAction() {
    final actions = availableChatUserActions.values;
    return actions.isEmpty || actions.any((action) => action.enabled);
  }
}
