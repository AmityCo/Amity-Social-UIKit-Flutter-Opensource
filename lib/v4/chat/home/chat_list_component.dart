import 'package:amity_uikit_beta_service/v4/chat/home/base_chat_list_component.dart';

class ChatListComponent extends BaseChatListComponent {
  ChatListComponent({key, pageId})
      : super(
            key: key,
            pageId: pageId,
            componentId: "chat_list",
            chatListType: ChatListType.CONVERSATION);
}
