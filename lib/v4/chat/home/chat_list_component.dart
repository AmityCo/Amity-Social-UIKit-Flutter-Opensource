import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/chat/home/base_chat_list_component.dart';
import 'package:amity_uikit_beta_service/v4/chat/home/bloc/chat_list_bloc.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Deprecated: Use specific chat list components instead
/// Prefer using: ConversationChatListComponent, GroupChatListComponent, AllChatListComponent
@Deprecated('Use specific chat list components instead: ConversationChatListComponent, GroupChatListComponent, or AllChatListComponent')
enum ChannelFilterType {
  all,
  conversation,
  community
}

/// Deprecated: Use specific chat list components instead
/// For specific chat types, use:
/// - ConversationChatListComponent for direct messages only
/// - GroupChatListComponent for group chats only  
/// - AllChatListComponent for all chat types
@Deprecated('Use specific chat list components: ConversationChatListComponent, GroupChatListComponent, or AllChatListComponent')
class ChatListComponent extends BaseChatListComponent {
  final String channelType;

  ChatListComponent({Key? key, this.channelType = 'all'})
      : super(
          key: key,
          componentId: "chat_list",
          chatListType: ChatListType.CONVERSATION,
        );
  
  static List<AmityChannelType> _mapStringToChannelTypes(String channelType) {
    switch (channelType) {
      case 'Direct':
        return [AmityChannelType.CONVERSATION];
      case 'Groups':
        return [AmityChannelType.COMMUNITY];
      case 'All':
      default:
        return [AmityChannelType.CONVERSATION, AmityChannelType.COMMUNITY];
    }
  }

  @override
  Widget buildComponent(BuildContext context) {
    return BlocProvider<ChatListBloc>(
      create: (context) => ChatListBloc(
          chatListType: ChatListType.CONVERSATION,
          channelTypes: _mapStringToChannelTypes(channelType),
          toastBloc: context.read<AmityToastBloc>()),
      child: super.buildComponent(context),
    );
  }
}
