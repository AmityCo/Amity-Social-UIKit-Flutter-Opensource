import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/chat/message/components/amity_conversation_chat_user_action_component.dart';
import 'package:flutter/material.dart';

class ConversationChatUserActionComponentSample {
  /* begin_sample_code
    gist_id: 8ae3efed21dee620dfb5543fba1f3aab
    filename: ConversationChatUserActionComponentSample.dart
    asc_page: https://docs.social.plus/social-plus-uikit/uikit-v4/chat
    description: Display action options for a user in a conversation
    */
  Widget conversationChatUserActionComponent() {
    // Create a user for this example
    final AmityUser user = AmityUser();

    return AmityConversationChatUserActionComponent(
      user: user,
      isMute: false,
      isUserBlocked: false,
    );
  }
  /* end_sample_code */
}
