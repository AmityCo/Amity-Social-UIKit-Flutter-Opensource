import 'package:amity_uikit_beta_service/v4/chat/message_composer/message_composer.dart';
import 'package:amity_uikit_beta_service/v4/chat/message_composer/message_composer_action.dart';
import 'package:flutter/material.dart';

class MessageComposerSample {

  /* begin_sample_code
    gist_id: 1debdc954d6b73f6e1011635bf15fa94
    filename: MessageComposerSample.dart
    asc_page: https://docs.social.plus/social-plus-uikit/uikit-v4/chat
    description: Message Composer for sending messages
    */
  Widget messageComposer() {
    return AmityMessageComposer(
      subChannelId: 'channelId',
      avatarUrl: 'avatarUrl',
      action: MessageComposerAction(
        onMessageCreated: () {
          // Handle message created callback
          print('Message created');
        },
        onDissmiss: () {
          // Handle dismiss callback
          print('Composer dismissed');
        },
      ),
    );
  }
  /* end_sample_code */

}
