import 'package:amity_uikit_beta_service/v4/social/social_home_page/social_home_top_navigation_component.dart';
import 'package:flutter/material.dart';

class AmitySocialHomeTopNavigationComponentWidget {
  /* begin_sample_code
    gist_id: a63038e2cd1508252cdca01f50332585
    filename: AmitySocialHomeTopNavigationComponentWidget.dart
    asc_page: https://docs.amity.co/social/flutter
    description: Get social home page top navigation component.
    */

  Widget socialHomeTopNavigationComponent() {
    return AmitySocialHomeTopNavigationComponent(
      selectedTab: AmitySocialHomePageTab.newsFeed,
      searchButtonAction: () => {
        // Action when search button is clicked
      },
    );
  }

  /* end_sample_code */
}
