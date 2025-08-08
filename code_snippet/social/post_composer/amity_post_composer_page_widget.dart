import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/social/post_composer_page/post_composer_model.dart';
import 'package:amity_uikit_beta_service/v4/social/post_composer_page/post_composer_page.dart';
import 'package:flutter/material.dart';

class AmityPostComposerPageWidget {
  late AmityPost post;
  late AmityCommunity community;
  /* begin_sample_code
    gist_id: 69181da436dc63192ba0ea9bc888ca17
    filename: AmityPostComposerPageWidget.dart
    asc_page: https://docs.amity.co/social/flutter
    description: Get post composer page.
    */

  Widget postComposerPageWidget() {
    // Create post composer options
    AmityPostComposerOptions createOptions =
        AmityPostComposerOptions.createOptions(
            targetType: AmityPostTargetType.COMMUNITY,
            targetId: 'targetId',
            community: community);

    // Edit post composer options
    AmityPostComposerOptions editOptions = AmityPostComposerOptions.editOptions(
      post: post,
    );

    return AmityPostComposerPage(options: createOptions);
  }

  /* end_sample_code */
}
