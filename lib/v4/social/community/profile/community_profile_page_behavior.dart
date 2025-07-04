import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/social/community/pending_request/amity_pending_request_page.dart';
import 'package:flutter/material.dart';

class AmityCommunityProfilePageBehavior {
  void goToPendingRequestsPage(
    BuildContext context,
    AmityCommunity community, {
    Function? onReturnCallback,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AmityPendingRequestPage(
          community: community,
        ),
      ),
    ).then((_) {
      // Execute callback when returning from pending request page
      onReturnCallback?.call();
    });
  }
}
