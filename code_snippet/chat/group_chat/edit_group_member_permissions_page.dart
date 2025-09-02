import 'package:amity_uikit_beta_service/v4/chat/edit_group_member_permission/amity_edit_group_member_permissions_page.dart';
import 'package:amity_sdk/amity_sdk.dart';
import 'package:flutter/material.dart';

class EditGroupMemberPermissionsPageSample {

  /* begin_sample_code
    gist_id: dd4b583ea890bde7365bd4a5d9fde3b8
    filename: EditGroupMemberPermissionsPageSample.dart
    asc_page: https://docs.social.plus/social-plus-uikit/uikit-v4/chat
    description: Edit member permissions in a group chat
    */
  Widget editGroupMemberPermissionsPage() {
    // Create a channel for this example
    final AmityChannel channel = AmityChannel();
    channel.channelId = 'your-channel-id';

    return AmityEditGroupMemberPermissionsPage(
      channel: channel,
    );
  }
  /* end_sample_code */

}
