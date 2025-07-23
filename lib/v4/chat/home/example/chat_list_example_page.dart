import 'package:flutter/material.dart';
import 'package:amity_uikit_beta_service/v4/chat/home/amity_all_chat_list_component.dart';
import 'package:amity_uikit_beta_service/v4/chat/home/amity_conversation_chat_list_component.dart';
import 'package:amity_uikit_beta_service/v4/chat/home/amity_group_chat_list_component.dart';
import 'package:amity_uikit_beta_service/v4/chat/home/archived_chat_list_component.dart';

/// Example page showing how to use the separate chat list components
class ChatListExamplePage extends StatelessWidget {
  const ChatListExamplePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chat Lists'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'All Chats'),
              Tab(text: 'Direct Messages'),
              Tab(text: 'Group Chats'),
              Tab(text: 'Archived'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // All chat types (conversations + groups)
            AmityAllChatListComponent(),
            
            // Only direct/private conversations
            AmityConversationChatListComponent(),
            
            // Only group/community chats
            AmityGroupChatListComponent(),
            
            // Archived chats
            ArchivedChatListComponent(),
          ],
        ),
      ),
    );
  }
}

/// Alternative example using ChatListComponent with channelType parameter (legacy approach)
class LegacyChatListExamplePage extends StatelessWidget {
  const LegacyChatListExamplePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chat Lists (Legacy)'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Direct'),
              Tab(text: 'Groups'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            // Using the legacy ChatListComponent with channelType parameter
            // ChatListComponent(channelType: 'All'),
            // ChatListComponent(channelType: 'Direct'),
            // ChatListComponent(channelType: 'Groups'),
          ],
        ),
      ),
    );
  }
}
