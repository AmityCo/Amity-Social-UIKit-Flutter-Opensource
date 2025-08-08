import 'package:amity_uikit_beta_service/v4/core/config_repository.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:flutter/material.dart';

class ConfigProvider extends ChangeNotifier {
  final ConfigRepository _configRepository = ConfigRepository();
  bool _isConfigInitialized = false;

  Future<void> loadConfig() async {
    if (!_isConfigInitialized) {
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
    String configId =
        '${getId(pageId)}/${getId(componentId)}/${getId(elementId)}';
    return _configRepository.getConfig(configId);
  }

  String getStringConfig(
    String? pageId,
    String? componentId,
    String? elementId,
    String configName,
  ) {
    String configId =
        '${getId(pageId)}/${getId(componentId)}/${getId(elementId)}';
    try {
      return _configRepository.getConfig(configId)[configName] as String;
    } catch (e) {
      return "";
    }
  }

  AmityThemeColor getTheme(String? pageId, String? componentId) {
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

  bool isHidden(String? pageId, String? componentId, String? elementId) {
    String configId =
        '${getId(pageId)}/${getId(componentId)}/${getId(elementId)}';
    final excludeList = _configRepository.excludedList;
    if (excludeList.isEmpty) {
      return false;
    }

    var variations = [
      configId,
      '*/${getId(componentId)}/*',
      '*/${getId(componentId)}/${getId(elementId)}',
      '*/*/${getId(elementId)}',
    ];

    return variations.any((variation) => excludeList.contains(variation));
  }

  AmityUIConfig getUIConfig(
      String? pageId, String? componentId, String? elementId) {
    return AmityUIConfig(_configRepository, pageId, componentId, elementId);
  }

  AmityFeatureFlag getFeatureConfig() {
    return AmityFeatureFlag(_configRepository.getFeatureFlags());
  }
}

class AmityUIConfig {
  late final String? _pageId;
  late final String? _componentId;
  late final String? _elementId;
  late final ConfigRepository _repository;

  late final String? text;
  late final String? icon;

  AmityUIConfig(
    ConfigRepository repository,
    String? pageId,
    String? componentId,
    String? elementId,
  ) {
    _repository = repository;
    _pageId = pageId;
    _componentId = componentId;
    _elementId = elementId;

    final config = _repository.getConfig(_getConfigId());
    text = config['text'] as String?;
    icon = config['image'] as String? ?? config['icon'] as String?;
  }

// For those elements used inside component / page which are not standalone
// Ex. Text element inside a component (which is not a standalone widget extending from BaseElement)
  AmityUIConfig getConfig(String elementId) {
    return AmityUIConfig(_repository, _pageId, _componentId, elementId);
  }

  String _getConfigId() {
    String configId =
        '${_pageId ?? "*"}/${_componentId ?? "*"}/${_elementId ?? "*"}';
    return configId;
  }
}

class AmityFeatureFlag {
  final Map<String, dynamic> _featureFlags;

  late final StoryFeatureFlag story;
  late final PostFeatureFlag post;

  AmityFeatureFlag(this._featureFlags) {
    story = StoryFeatureFlag.fromJson(_featureFlags['story'] ?? {});
    post = PostFeatureFlag.fromJson(_featureFlags['post'] ?? {});
  }
}

class StoryFeatureFlag {
  final bool createEnabled;
  final bool viewStoryTabEnabled;

  StoryFeatureFlag({
    required this.createEnabled,
    required this.viewStoryTabEnabled,
  });

  factory StoryFeatureFlag.fromJson(Map<String, dynamic> json) {
    return StoryFeatureFlag(
      createEnabled: json['create_enabled'] ?? false,
      viewStoryTabEnabled: json['view_story_tab_enabled'] ?? false,
    );
  }
}

class PostFeatureFlag {
  final PostFeatureToggle text;
  final PostFeatureToggle image;
  final PostFeatureToggle video;
  final PostFeatureToggle poll;
  final PostFeatureToggle livestream;
  final PostFeatureToggle clip;

  PostFeatureFlag({
    required this.text,
    required this.image,
    required this.video,
    required this.poll,
    required this.livestream,
    required this.clip,
  });

  factory PostFeatureFlag.fromJson(Map<String, dynamic> json) {
    return PostFeatureFlag(
      text: PostFeatureToggle.fromJson(json['text'] ?? {}),
      image: PostFeatureToggle.fromJson(json['image'] ?? {}),
      video: PostFeatureToggle.fromJson(json['video'] ?? {}),
      poll: PostFeatureToggle.fromJson(json['poll'] ?? {}),
      livestream: PostFeatureToggle.fromJson(json['livestream'] ?? {}),
      clip: PostFeatureToggle.fromJson(json['clip'] ?? {}),
    );
  }

  bool isPostCreationEnabled() {
    return text.createEnabled || image.createEnabled || video.createEnabled;
  }
}

class PostFeatureToggle {
  final bool createEnabled;
  final bool viewImageTabEnabled;
  final bool viewVideoTabEnabled;

  PostFeatureToggle(
      {required this.viewImageTabEnabled,
      required this.viewVideoTabEnabled,
      required this.createEnabled});

  factory PostFeatureToggle.fromJson(Map<String, dynamic> json) {
    return PostFeatureToggle(
      createEnabled: json['create_enabled'] ?? false,
      viewImageTabEnabled: json['view_image_tab_enabled'] ?? false,
      viewVideoTabEnabled: json['view_video_tab_enabled'] ?? false,
    );
  }
}
