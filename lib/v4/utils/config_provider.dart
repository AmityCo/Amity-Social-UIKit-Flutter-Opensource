import 'package:amity_uikit_beta_service/v4/core/config_repository.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:flutter/material.dart';

class ConfigProvider extends ChangeNotifier {
  final ConfigRepository _configRepository = ConfigRepository();
  bool _isConfigInitialized = false;

  Future<void> loadConfig() async {
    if(!_isConfigInitialized) {
      await _configRepository.loadConfig();
      notifyListeners();
      _isConfigInitialized = true;
    }
  }

  Map<String, dynamic> getConfig(String configId) {
    return _configRepository.getConfig(configId);
  }

  Map<String, dynamic> getMapConfig(
    String? pageId,
    String? componentId,
    String? elementId,
  ) {
    String configId = '${getId(pageId)}/${getId(componentId)}/${getId(elementId)}';
    return _configRepository.getConfig(configId);
  }

  String getStringConfig(
    String? pageId,
    String? componentId,
    String? elementId,
    String configName,
  ) {
    String configId = '${getId(pageId)}/${getId(componentId)}/${getId(elementId)}';
    try {
      return _configRepository.getConfig(configId)[configName] as String;
    } catch (e) {
      return "";
    }
  }

  AmityThemeColor getTheme(String? pageId, String? componentId) {
    // print("getTheme called with $configId");
    String configId = '${getId(pageId)}/${getId(componentId)}/*';
    final theme = _configRepository.getTheme(configId);
    return theme;
  }

  String getId(String? id) {
    if (id?.isNotEmpty == true) {
      return id!;
    } else {
      return "*";
    }
  }

  List<AmityReactionType> getAllMessageReactions() {
    return _configRepository.getAllMessageReactions();
  }

  AmityReactionType getReaction(String reaction) {
    return _configRepository.getReaction(reaction);
  }

  LinearGradient getShimmerGradient() {
    return _configRepository.getShimmerGradient();
  }

  void updateTheme(String configId) {
    notifyListeners();
  }
}
