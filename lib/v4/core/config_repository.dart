import 'dart:convert';

import 'package:amity_uikit_beta_service/amity_uikit.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

class ConfigRepository {
  static final ConfigRepository _instance = ConfigRepository._internal();

  factory ConfigRepository() => _instance;

  ConfigRepository._internal();

  late Map<String, dynamic> _config;
  late Set<String> excludedList;
  bool _isConfigInitialized = false;

  Future<void> loadConfig() async {
    if (!_isConfigInitialized) {
      _config = await _loadConfigFile('config');
      excludedList = Set<String>.from(_config['excludes'] ?? []);
      _isConfigInitialized = true;
    }
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

  Future<Map<String, dynamic>> _loadConfigFile(String fileName) async {
    try {
      final jsonString = await rootBundle.loadString(
          'packages/amity_uikit_beta_service/assets/config/$fileName.json');
      return json.decode(jsonString);
    } catch (e) {
      return {};
    }
  }
}

extension ThemeConfig on ConfigRepository {
  AmityThemeStyle _getCurrentThemeStyle() {
    final behavior = AmityUIKit4Manager.freedomBehavior.themeBehavior;
    final systemStyle = behavior.systemStyle ??
        SchedulerBinding.instance.platformDispatcher.platformBrightness;
    final configStyle = behavior.theme ??
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

  AmityThemeColor getTheme(String? configId) {
    final fallbackTheme = _getCurrentThemeStyle() == AmityThemeStyle.light
        ? lightTheme
        : darkTheme;
    final globalTheme =
        _getGlobalTheme(_getCurrentThemeStyle(), fallbackTheme);

    if (configId == null) {
      return _getThemeColor(globalTheme, fallbackTheme);
    }

    final customizationConfig =
        _config['customizations'] as Map<String, dynamic>?;
    final id = configId.split('/');
    if (id.length != 3) {
      return _getThemeColor(globalTheme, fallbackTheme);
    }

    final style = _getCurrentThemeStyle();
    final pageTheme =
        customizationConfig?['${id[0]}/*/*'] as Map<String, dynamic>?;
    final componentTheme = customizationConfig?['*/${id[1]}/*']
            as Map<String, dynamic>? ??
        customizationConfig?['${id[0]}/${id[1]}/*'] as Map<String, dynamic>?;

    try {
      if (componentTheme != null) {
        final theme = _getThemeColor(
            AmityTheme.fromJson(
                componentTheme["theme"]?[style.toString().split('.').last], fallbackTheme),
            fallbackTheme);
        return theme;
      }

      if (pageTheme != null) {
        return _getThemeColor(
            AmityTheme.fromJson(
                pageTheme["theme"]?[style.toString().split('.').last], fallbackTheme),
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
    final style = _getCurrentThemeStyle() == AmityThemeStyle.light
        ? lightTheme
        : darkTheme;
    if (style == lightTheme) {
      return const LinearGradient(
        colors: [
          Color(0xFFEBEBF4),
          Color(0xFFF4F4F4),
          Color(0xFFEBEBF4),
        ],
        stops: [
          0.1,
          0.3,
          0.4,
        ],
        begin: Alignment(-1.0, -0.3),
        end: Alignment(1.0, 0.3),
        tileMode: TileMode.clamp,
      );
    } else {
      return const LinearGradient(
        colors: [
          Color.fromARGB(255, 167, 167, 167),
          Color.fromARGB(255, 46, 45, 45),
          Color.fromARGB(255, 167, 167, 167),
        ],
        stops: [
          0.1,
          0.3,
          0.4,
        ],
        begin: Alignment(-1.0, -0.3),
        end: Alignment(1.0, 0.3),
        tileMode: TileMode.clamp,
      );
    }
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
