import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/social/comment/comment_tray.dart';
import 'package:flutter/material.dart';

class AmityCommentTrayWidget {
  /* begin_sample_code
    gist_id: cdb423e8726992d26f011f0420a3645f
    filename: AmityCommentTrayWidget.dart
    asc_page: https://docs.amity.co/social/flutter
    description: Get Comment Tray 
    */

  void viewInCommunityProfileStory({
    required String referenceId,
    AmityCommentReferenceType referenceType = AmityCommentReferenceType.STORY,
    required ScrollController parentScrollController,
  }) {
    AmityCommentTrayComponent(
      referenceId: referenceId,
      referenceType: referenceType,
      shouldAllowComments: true,
      scrollController: parentScrollController,
      shouldAllowInteraction: true,
    );
  }
  /* end_sample_code */
}
