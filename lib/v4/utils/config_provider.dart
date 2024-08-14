import 'package:amity_uikit_beta_service/v4/core/config_repository.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:flutter/material.dart';

class ConfigProvider extends ChangeNotifier {
  final ConfigRepository _configRepository = ConfigRepository();

  Future<void> loadConfig() async {
    await _configRepository.loadConfig();
    notifyListeners();
  }

  Map<String, dynamic> getConfig(String configId) {
    return _configRepository.getConfig(configId);
  }

  AmityThemeColor getTheme(String? pageId, String? componentId) {
    // print("getTheme called with $configId");
    String configId = '${pageId ?? "*"}/${componentId ?? "*"}/*';
    return _configRepository.getTheme(configId);
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
