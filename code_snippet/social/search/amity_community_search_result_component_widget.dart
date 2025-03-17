import 'package:amity_uikit_beta_service/v4/social/community_search_result/community_search_result.dart';
import 'package:amity_uikit_beta_service/v4/social/global_search/view_model/global_search_view_model.dart';
import 'package:flutter/material.dart';

class AmityCommunitySearchResultComponentWidget {
  /* begin_sample_code
    gist_id: 54af818483558c55afe6ca3f3499bc18
    filename: AmityCommunitySearchResultComponentWidget.dart
    asc_page: https://docs.amity.co/social/flutter
    description: Get community search result component.
    */

  Widget communitySearchResultComponent({
    required ScrollController scrollController,
  }) {
    AmityGlobalSearchViewModel viewModel = AmityGlobalSearchViewModel(
      searchType: AmityGlobalSearchType.community,
      scrollController: scrollController,
    );

    return AmityCommunitySearchResultComponent(
      viewModel: viewModel,
    );
  }

  /* end_sample_code */
}
