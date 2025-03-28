import 'package:amity_uikit_beta_service/v4/chat/message/parent_message_cache.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:amity_sdk/amity_sdk.dart';

part 'message_bubble_state.dart';

class MessageBubbleCubit extends Cubit<MessageBubbleState> {
  MessageBubbleCubit({required AmityMessage message})
      : super(MessageBubbleState(message: message));

  void fetchParentMessage() {
    final parentMessageId = state.message?.parentId;
    if (parentMessageId != null &&
        state.parentMessage == null &&
        !state.isFetchingParentMessage) {
      emit(state.copyWith(isFetchignParentMessage: true));
      AmityChatClient.newMessageRepository()
          .getMessage(parentMessageId)
          .then((value) => {
                if (value.messageId != null)
                  {
                    ParentMessageCache().addMessage(value.messageId!, value),
                  },
                emit(state.copyWith(
                    message: state.message,
                    parentMessage: value,
                    isFetchignParentMessage: false))
              })
          .onError((error, stackTrace) => {
                //handle error
              });
    }
  }
}
