import 'package:amity_uikit_beta_service/v4/social/post_composer_page/media_attachment_component.dart';
import 'package:flutter/material.dart';

class AmityMediaAttachmentComponentWidget {
  /* begin_sample_code
    gist_id: 55e7c72e274b93e3680320013e0ad4ef
    filename: AmityMediaAttachmentComponentWidget.dart
    asc_page: https://docs.amity.co/social/flutter
    description: Get media attachment component.
    */

  Widget mediaAttachmentComponentWidget() {
    return AmityMediaAttachmentComponent(
      onCameraTap: () {
        // Handle camera action
      },
      onImageTap: () {
        // Handle image action
      },
      onVideoTap: () {
        // Handle video action
      },
    );
  }

  /* end_sample_code */
}
