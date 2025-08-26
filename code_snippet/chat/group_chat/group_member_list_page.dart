import 'package:amity_uikit_beta_service/v4/chat/group_member_list/amity_group_member_list_page.dart';
import 'package:amity_sdk/amity_sdk.dart';
import 'package:flutter/material.dart';

class GroupMemberListPageSample {

  /* begin_sample_code
    gist_id: 83674e23fac07b127855a2fda4bba823
    filename: GroupMemberListPageSample.dart
    asc_page: https://docs.social.plus/social-plus-uikit/uikit-v4/chat
    description: Display and manage members in a group chat
    */
  Widget groupMemberListPage() {
    // Create a channel for this example
    final AmityChannel channel = AmityChannel();
    channel.channelId = 'your-channel-id';

    return AmityGroupMemberListPage(
      channel: channel,
    );
  }
  /* end_sample_code */

}
