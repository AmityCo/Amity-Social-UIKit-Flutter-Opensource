import 'package:amity_uikit_beta_service/v4/chat/edit_group_profile/amity_edit_group_profile_page.dart';
import 'package:amity_sdk/amity_sdk.dart';
import 'package:flutter/material.dart';

class EditGroupProfilePageSample {

  /* begin_sample_code
    gist_id: 3139bd67b7dd7fae2ce9d97c4d6e4846
    filename: EditGroupProfilePageSample.dart
    asc_page: https://docs.social.plus/social-plus-uikit/uikit-v4/chat
    description: Edit a group chat's profile including name and avatar
    */
  Widget editGroupProfilePage() {
    // Create a channel for this example
    final AmityChannel channel = AmityChannel();
    channel.channelId = 'your-channel-id';

    return AmityEditGroupProfilePage(
      channel: channel,
    );
  }
  /* end_sample_code */

}
