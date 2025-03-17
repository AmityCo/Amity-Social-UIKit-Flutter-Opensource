import 'package:amity_uikit_beta_service/v4/social/top_search_bar/top_search_bar.dart';
import 'package:flutter/material.dart';

class AmityTopSearchBarComponentWidget {
  /* begin_sample_code
    gist_id: 048fe9ddba9d4d7d663d5edc42ea795e
    filename: AmityTopSearchBarComponentWidget.dart
    asc_page: https://docs.amity.co/social/flutter
    description: Get top search bar component.
    */

  Widget topSearchBarComponent() {
    TextEditingController textController = TextEditingController();
    return AmityTopSearchBarComponent(
      textcontroller: textController,
    );
  }

  /* end_sample_code */
}
