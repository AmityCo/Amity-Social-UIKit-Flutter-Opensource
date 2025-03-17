import 'dart:io';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/social/story/draft/amity_story_media_type.dart';
import 'package:amity_uikit_beta_service/v4/social/story/draft/story_draft_page.dart';
import 'package:flutter/material.dart';

class AmityStoryDarftWidget {
  /* begin_sample_code
    gist_id: 6f90e4cfca8b1171ce2d997b77677c70
    filename: AmityStoryDarftWidget.dart
    asc_page: https://docs.amity.co/social/flutter
    description: Flutter Go To Story Draft Page
    */

  void gotoStoryDarftPage(
    BuildContext context,
    String targetId,
    File image,
    AmityStoryTargetType targetType,
  ) {
    AmityStoryMediaType mediaType = AmityStoryMediaTypeImage(file: image);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StoryDraftPage(
          mediaType: mediaType,
          targetId: targetId,
          targetType: targetType,
        ),
      ),
    );
  }
  /* end_sample_code */
}
