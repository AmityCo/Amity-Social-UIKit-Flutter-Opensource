import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/chat/message/message_bubble_view.dart';
import 'package:flutter/material.dart';

class MessageBubbleViewSample {
  /* begin_sample_code
    gist_id: 069b2fc62b801b165928719c7a117527
    filename: MessageBubbleViewSample.dart
    asc_page: https://docs.social.plus/social-plus-uikit/uikit-v4/chat
    description: Message Bubble View for displaying chat messages
    */
  Widget messageBubbleView(AmityMessage message) {
    return MessageBubbleView(
      message: message,
    );
  }
  /* end_sample_code */
}
