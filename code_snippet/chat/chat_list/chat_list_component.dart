import 'package:amity_uikit_beta_service/v4/chat/home/archived_chat_list_component.dart';
import 'package:amity_uikit_beta_service/v4/chat/home/chat_list_component.dart';
import 'package:amity_uikit_beta_service/v4/chat/home/amity_conversation_chat_list_component.dart';
import 'package:amity_uikit_beta_service/v4/chat/home/amity_group_chat_list_component.dart';
import 'package:amity_uikit_beta_service/v4/chat/home/amity_all_chat_list_component.dart';
import 'package:flutter/material.dart';

class ChatListComponentSample {

  /* begin_sample_code
    gist_id: f67e3191d947c3a614c38c0512e79d2b
    filename: ChatListComponentSample.dart
    asc_page: https://docs.social.plus/social-plus-uikit/uikit-v4/chat
    description: Component for chat list
    */
  Widget chatListComponent() {
    return ChatListComponent();
  }
  /* end_sample_code */

  /* begin_sample_code
    gist_id: e9ce40fa2d338bb8debf562cee5c3336
    filename: ConversationChatListComponentSample.dart
    asc_page: https://docs.social.plus/social-plus-uikit/uikit-v4/chat
    description: Component for conversation messages only
    */
  Widget conversationChatListComponent() {
    return AmityConversationChatListComponent();
  }
  /* end_sample_code */

  /* begin_sample_code
    gist_id: 2c13ceea053f0f7ce65ab3c5c90322fe
    filename: GroupChatListComponentSample.dart
    asc_page: https://docs.social.plus/social-plus-uikit/uikit-v4/chat
    description: Component for group chats only
    */
  Widget groupChatListComponent() {
    return AmityGroupChatListComponent();
  }
  /* end_sample_code */

  /* begin_sample_code
    gist_id: e268b183bb614de9e09a046cf2baa8db
    filename: AllChatListComponentSample.dart
    asc_page: https://docs.social.plus/social-plus-uikit/uikit-v4/chat
    description: Component for all chat types (conversations + groups)
    */
  Widget allChatListComponent() {
    return AmityAllChatListComponent();
  }
  /* end_sample_code */

  /* begin_sample_code
    gist_id: c41509675b5d2126e6e7f24307175364
    filename: ChatListComponentSample.dart
    asc_page: https://docs.social.plus/social-plus-uikit/uikit-v4/chat
    description: Component for archived chat list
    */
  Widget archivedChatListComponent() {
    return ArchivedChatListComponent();
  }
  /* end_sample_code */

}