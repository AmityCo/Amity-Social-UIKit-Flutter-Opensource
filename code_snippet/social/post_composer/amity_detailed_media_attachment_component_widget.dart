import 'package:amity_uikit_beta_service/v4/social/post_composer_page/detailed_media_attachment_component.dart';
import 'package:flutter/material.dart';

class AmityDetailedMediaAttachmentComponentWidget {
  /* begin_sample_code
    gist_id: 2a5181ff0e3c6bc70c95be2a1ff9f069
    filename: AmityDetailedMediaAttachmentComponentWidget.dart
    asc_page: https://docs.amity.co/social/flutter
    description: Get detailed media attachment component.
    */

  Widget detailedMediaAttachmentComponentWidget() {
    return AmityDetailedMediaAttachmentComponent(
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
