import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/social/community/profile/component/community_header_component.dart';
import 'package:flutter/widgets.dart';

class AmityCommunityProfileHeaderComponentWidget {
  /* begin_sample_code
    gist_id: 88bf8ffa22cc9de75fcff70486246078
    filename: AmityCommunityProfileHeaderComponentWidget.dart
    asc_page: https://docs.amity.co/social/flutter
    description: Get community profile header component.
    */

  Widget communityHeaderComponent(AmityCommunity? community) {
    return AmityCommunityHeaderComponent(community: community);
  }

  /* end_sample_code */
}
