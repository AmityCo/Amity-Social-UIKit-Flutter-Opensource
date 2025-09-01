import 'package:amity_uikit_beta_service/v4/chat/add_group_member/amity_add_group_member_page.dart';
import 'package:amity_sdk/amity_sdk.dart';
import 'package:flutter/material.dart';

class AddGroupMemberPageSample {

  /* begin_sample_code
    gist_id: 01ac94c7373d564ae0d48c2a910dc564
    filename: AddGroupMemberPageSample.dart
    asc_page: https://docs.social.plus/social-plus-uikit/uikit-v4/chat
    description: Add member to a group chat
    */
  Widget addGroupMemberPage() {
    // Create a channel for this example
    final AmityChannel channel = AmityChannel();
    channel.channelId = 'your-channel-id';

    return AmityAddGroupMemberPage(
      channel: channel,
    );
  }
  /* end_sample_code */

}
