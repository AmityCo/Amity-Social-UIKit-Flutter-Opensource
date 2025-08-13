import 'package:amity_uikit_beta_service/v4/core/amity_config_behavior.dart';
import 'package:amity_uikit_beta_service/v4/social/social_home_page/amity_social_home_page_behavior.dart';

class FreedomUIKitBehavior {
  factory FreedomUIKitBehavior() => _instance;
  static FreedomUIKitBehavior get instance => _instance;

  static final FreedomUIKitBehavior _instance = FreedomUIKitBehavior._internal();
  FreedomUIKitBehavior._internal();

  AmityConfigBehavior configBehavior =
      AmityConfigBehavior();
  
  AmitySocialHomePageBehavior socialHomePageBehavior =
      AmitySocialHomePageBehavior();
}
