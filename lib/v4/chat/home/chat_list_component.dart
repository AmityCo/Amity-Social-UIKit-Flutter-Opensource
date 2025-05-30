import 'package:amity_uikit_beta_service/v4/chat/home/base_chat_list_component.dart';
import 'package:amity_uikit_beta_service/v4/chat/home/bloc/chat_list_bloc.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum ChannelFilterType {
  all,
  conversation,
  community
}

class ChatListComponent extends StatelessWidget {
  final ChannelFilterType channelFilterType;
  final String channelType;

  ChatListComponent({Key? key, this.channelType = 'all'})
      : channelFilterType = _mapStringToChannelType(channelType),
        super(key: key);
  
  static ChannelFilterType _mapStringToChannelType(String channelType) {
    switch (channelType) {
      case 'Direct':
        return ChannelFilterType.conversation;
      case 'Groups':
        return ChannelFilterType.community;
      case 'All':
      default:
        return ChannelFilterType.all;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ChatListBloc>(
      create: (context) => ChatListBloc(
          chatListType: ChatListType.CONVERSATION,
          channelFilterType: channelFilterType,
          toastBloc: context.read<AmityToastBloc>()),
      child: BaseChatListComponent(
        componentId: "chat_list",
        chatListType: ChatListType.CONVERSATION,
      ),
    );
  }
}
