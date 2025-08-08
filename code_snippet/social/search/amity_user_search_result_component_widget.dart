import 'package:amity_uikit_beta_service/v4/social/global_search/view_model/global_search_view_model.dart';
import 'package:amity_uikit_beta_service/v4/social/user_search_result/user_search_result.dart';
import 'package:flutter/material.dart';

class AmityUserSearchResultComponentWidget {
  /* begin_sample_code
    gist_id: 9a2e23d103120ff5c6344aeaefa0de0e
    filename: AmityUserSearchResultComponentWidget.dart
    asc_page: https://docs.amity.co/social/flutter
    description: Get user search result component.
    */

  Widget userSearchResultComponent() {
    ScrollController scrollController = ScrollController();

    AmityGlobalSearchViewModel viewModel = AmityGlobalSearchViewModel(
      searchType: AmityGlobalSearchType.community,
      scrollController: scrollController,
    );

    return AmityUserSearchResultComponent(
      viewModel: viewModel,
    );
  }

  /* end_sample_code */
}
