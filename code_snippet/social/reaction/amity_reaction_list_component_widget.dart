import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/social/reaction/reaction_list.dart';
import 'package:flutter/material.dart';

class AmityReactionListComponentWidget {
  /* begin_sample_code
    gist_id: 987bad25e718a10263f1cde3e2e62353
    filename: AmityReactionListComponentWidget.dart
    asc_page: https://docs.amity.co/social/flutter
    description: Get reaction list component.
    */

  Widget postReactionList() {
    return AmityReactionList(
        referenceId: 'referenceId',
        referenceType: AmityReactionReferenceType.POST);
  }

  /* end_sample_code */
}
