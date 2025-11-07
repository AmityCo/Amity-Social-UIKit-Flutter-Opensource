import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/chat/home/base_chat_list_component.dart';
import 'package:amity_uikit_beta_service/v4/chat/home/bloc/chat_list_bloc.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AmityAllChatListComponent extends BaseChatListComponent {
  AmityAllChatListComponent({Key? key})
      : super(
          key: key,
          componentId: "all_chat_list",
          chatListType: ChatListType.CONVERSATION,
          channelTypes: [AmityChannelType.CONVERSATION, AmityChannelType.COMMUNITY],
        );

  @override
  Widget buildComponent(BuildContext context) {
    return BlocProvider<ChatListBloc>(
      create: (context) => ChatListBloc(
          chatListType: ChatListType.CONVERSATION,
          channelTypes: [AmityChannelType.CONVERSATION, AmityChannelType.COMMUNITY],
          toastBloc: context.read<AmityToastBloc>()),
      child: super.buildComponent(context),
    );
  }
}
