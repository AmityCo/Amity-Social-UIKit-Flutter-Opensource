import 'package:amity_uikit_beta_service/view/UIKit/social/story_target_page.dart';
import 'package:flutter/material.dart';

class AmityStoryTargetPageWidget {
  /* begin_sample_code
    gist_id: 6e77af27da86bc11092aa2949d33572a
    filename: AmityStoryTargetPageWidget.dart
    asc_page: https://docs.amity.co/social/flutter
    description: Flutter Do to Story target Selection Page
    */

  void gotoStoryTargetPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AmityStoryTargetSelectionPage(
        ),
      ),
    );
  }
  /* end_sample_code */
}
