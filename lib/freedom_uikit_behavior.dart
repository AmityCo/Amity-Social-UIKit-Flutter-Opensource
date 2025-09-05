import 'package:amity_uikit_beta_service/v4/core/freedom_theme_behavior.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_membership/freedom_community_membership_behavior.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_setting/community_setting_page_behavior.dart';
import 'package:amity_uikit_beta_service/v4/social/community/pending_request/amity_pending_request_page_behavior.dart';
import 'package:amity_uikit_beta_service/v4/social/post/pending/freedom_amity_pending_post_content_component_behavior.dart';
import 'package:amity_uikit_beta_service/v4/utils/freedom_behaviors/freedom_create_post_menu_component_behavior.dart';
import 'package:amity_uikit_beta_service/v4/utils/freedom_behaviors/freedom_dm_page_behavior.dart';
import 'package:amity_uikit_beta_service/v4/utils/freedom_behaviors/freedom_post_composer_page_behavior.dart';
import 'package:amity_uikit_beta_service/v4/utils/freedom_behaviors/freedom_post_content_component_behavior.dart';
import 'package:amity_uikit_beta_service/v4/utils/freedom_behaviors/freedom_social_home_page_behavior.dart';
import 'package:amity_uikit_beta_service/v4/utils/freedom_behaviors/freedom_view_story_page_behavior.dart';

import 'l10n/localization_behavior.dart';
import 'shared/social/user/profile/freedom_user_profile_behavior.dart';

class FreedomUIKitBehavior {
  factory FreedomUIKitBehavior() => _instance;

  static FreedomUIKitBehavior get instance => _instance;

  static final FreedomUIKitBehavior _instance =
      FreedomUIKitBehavior._internal();

  FreedomUIKitBehavior._internal();

  FreedomCreatePostMenuComponentBehavior createPostMenuComponentBehavior =
      FreedomCreatePostMenuComponentBehavior();

  FreedomPostComposerPageBehavior postComposerPageBehavior =
      FreedomPostComposerPageBehavior();

  FreedomPostContentComponentBehavior postContentComponentBehavior =
      FreedomPostContentComponentBehavior();

  FreedomSocialHomePageBehavior socialHomePageBehavior =
      FreedomSocialHomePageBehavior();

  FreedomViewStoryPageBehavior viewStoryPageBehavior =
      FreedomViewStoryPageBehavior();

  LocalizationBehavior localizationBehavior = LocalizationBehavior();

  AmityCommunitySettingPageBehavior communitySettingPageBehavior =
      AmityCommunitySettingPageBehavior();

  AmityPendingRequestPageBehavior pendingRequestPageBehavior =
      AmityPendingRequestPageBehavior();

  FreedomAmityPendingPostContentComponentBehavior
      pendingPostContentComponentBehavior =
      FreedomAmityPendingPostContentComponentBehavior();

  FreedomCommunityMembershipBehavior communityMembershipBehavior =
      FreedomCommunityMembershipBehavior();

  FreedomDmPageBehavior dmPageBehavior = FreedomDmPageBehavior();

  FreedomThemeBehavior themeBehavior = FreedomThemeBehavior();

  FreedomUserProfileBehavior userProfileBehavior = FreedomUserProfileBehavior();
}
