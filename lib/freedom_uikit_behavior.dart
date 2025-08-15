import 'package:amity_uikit_beta_service/v4/utils/freedom_behaviors/freedom_post_content_component_behavior.dart';
import 'package:amity_uikit_beta_service/v4/utils/freedom_behaviors/freedom_social_home_page_behavior.dart';

class FreedomUIKitBehavior {
  factory FreedomUIKitBehavior() => _instance;
  static FreedomUIKitBehavior get instance => _instance;

  static final FreedomUIKitBehavior _instance =
      FreedomUIKitBehavior._internal();
  FreedomUIKitBehavior._internal();

  FreedomPostContentComponentBehavior postContentComponentBehavior =
      FreedomPostContentComponentBehavior();

  FreedomSocialHomePageBehavior socialHomePageBehavior =
      FreedomSocialHomePageBehavior();
}
