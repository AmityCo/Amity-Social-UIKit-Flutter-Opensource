import 'package:amity_uikit_beta_service/v4/chat/banned_group_member_list/amity_banned_group_member_list_page.dart';
import 'package:amity_sdk/amity_sdk.dart';
import 'package:flutter/material.dart';

class BannedGroupMemberListPageSample {

  /* begin_sample_code
    gist_id: f550cec5c0a2dd6edd4b3af54ae3794f
    filename: BannedGroupMemberListPageSample.dart
    asc_page: https://docs.social.plus/social-plus-uikit/uikit-v4/chat
    description: View and manage banned users in a group chat
    */
  Widget bannedGroupMemberListPage() {
    // Create a channel for this example
    final AmityChannel channel = AmityChannel();
    channel.channelId = 'your-channel-id';

    return AmityBannedGroupMemberListPage(
      channel: channel,
    );
  }
  /* end_sample_code */

}
