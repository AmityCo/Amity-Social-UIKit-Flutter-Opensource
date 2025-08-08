import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/social/story/target/amity_story_tab_component.dart';
import 'package:amity_uikit_beta_service/v4/social/story/target/amity_story_tab_component_type.dart';

class AmityStoryTabComponentWidget {
  /* begin_sample_code
    gist_id: b5a5ea5a79dc5ea1278af7ce60eec968
    filename: AmityStoryTabComponentWidget.dart
    asc_page: https://docs.amity.co/social/flutter
    description: Flutter Show Story Tab Component
    */

  void viewInCommunityProfileStory(
    AmityCommunity community,
  ) {
    AmityStoryTabComponentType feedTypeCommunity = CommunityFeedStoryTab(
      communityId: community.communityId!,
    );
    
    AmityStoryTabComponentType feedTypeGlobal = GlobalFeedStoryTab();
    AmityStoryTabComponent(
      type: feedTypeCommunity,
    );
  }
  /* end_sample_code */
}
