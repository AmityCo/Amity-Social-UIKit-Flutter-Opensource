import 'package:amity_uikit_beta_service/v4/chat/home/base_chat_list_component.dart';
import 'package:amity_uikit_beta_service/v4/chat/home/bloc/chat_list_bloc.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ArchivedChatListComponent extends BaseChatListComponent {
  ArchivedChatListComponent({key, pageId}) : super(key: key, pageId: pageId, componentId: "archived_chat_list", chatListType: ChatListType.ARCHIVED);

  @override
  Widget buildComponent(BuildContext context) {
    return BlocProvider<ChatListBloc>(
      create: (context) => ChatListBloc(
          chatListType: ChatListType.ARCHIVED,
          channelTypes: [],
          toastBloc: context.read<AmityToastBloc>()),
      child: super.buildComponent(context),
    );
  }
}
