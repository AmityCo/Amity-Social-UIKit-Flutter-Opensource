import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/social/post/amity_post_content_component.dart';
import 'package:flutter/material.dart';

class AmityPostContentComponentWidget {
  late AmityPost post;
  /* begin_sample_code
    gist_id: 31f09b1d3ba8c82c390070e4364c4e82
    filename: AmityPostContentComponentWidget.dart
    asc_page: https://docs.amity.co/social/flutter
    description: Get post content component.
    */

  Widget postContentComponentWidget() {
    return AmityPostContentComponent(
      post: post,
      style: AmityPostContentComponentStyle.feed,
    );
  }

  /* end_sample_code */
}
