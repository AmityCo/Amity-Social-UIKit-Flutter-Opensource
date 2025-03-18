import 'package:amity_uikit_beta_service/v4/social/story/view/amity_view_story_page.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/amity_view_story_page_type.dart';
import 'package:amity_uikit_beta_service/v4/utils/amity_story_helper.dart';
import 'package:flutter/material.dart';

class AmityViewStoryPageWidget {
  /* begin_sample_code
    gist_id: 7fcccb7791f56fa5e31ee4724a7226b4
    filename: AmityViewStoryPageWidget.dart
    asc_page: https://docs.amity.co/social/flutter
    description: Flutter Go to View Story Page
    */

  void viewInCommunityProfileStory(
    BuildContext context,
    String communityId,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return AmityViewStoryPage(
            type: AmityViewStoryCommunityFeed(communityId: communityId),
          );
        },
      ),
    );
  }
  /* end_sample_code */
}
