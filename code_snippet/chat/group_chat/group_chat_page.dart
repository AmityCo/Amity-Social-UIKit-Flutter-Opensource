import 'package:amity_uikit_beta_service/v4/chat/group_message/amity_group_chat_page.dart';
import 'package:flutter/material.dart';

class GroupChatPageSample {

  /* begin_sample_code
    gist_id: ee9f5fb6ced6bafc2e0e0659d824615c
    filename: GroupChatPageSample.dart
    asc_page: https://docs.social.plus/social-plus-uikit/uikit-v4/chat
    description: Display a group chat conversation view
    */
  Widget groupChatPage() {
    return AmityGroupChatPage(
      channelId: 'your-channel-id',
    );
  }
  /* end_sample_code */

}
