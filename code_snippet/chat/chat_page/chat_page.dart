import 'package:amity_uikit_beta_service/v4/chat/message/chat_page.dart';
import 'package:flutter/material.dart';

class ChatPageSample {

  /* begin_sample_code
    gist_id: f45062abadfffceff06ddef40a915125
    filename: ChatPageSample.dart
    asc_page: https://docs.social.plus/social-plus-uikit/uikit-v4/chat
    description: Chat Page for conversation view
    */
  Widget chatPage() {
    return AmityChatPage(
      channelId: 'channelId',
      userId: 'userId',
      userDisplayName: 'displayName',
      avatarUrl: 'avatarUrl',
    );
  }
  /* end_sample_code */

}
