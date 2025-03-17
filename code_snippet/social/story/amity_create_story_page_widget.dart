import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/social/story/create/amity_create_story_page.dart';
import 'package:flutter/material.dart';

class AmityCreateStoryPageWidget {
  /* begin_sample_code
    gist_id: 359cb90a2477ceb1e65fdaea0dda0959
    filename: AmityCreateStoryPageWidget.dart
    asc_page: https://docs.amity.co/social/flutter
    description: Flutter Go to Create story page
    */

  void gotoCreateStoryPage(
    BuildContext context,
    String targetId,
    AmityStoryTargetType targetType,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AmityCreateStoryPage(
          targetType: targetType,
          targetId: targetId,
        ),
      ),
    );
  }
  /* end_sample_code */
}
