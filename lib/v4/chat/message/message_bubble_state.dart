part of 'message_bubble_cubit.dart';

class MessageBubbleState {
  final AmityMessage? message;
  final AmityMessage? parentMessage;
  final bool isFetchingParentMessage;

  const MessageBubbleState(
      {required this.message,
      this.parentMessage,
      this.isFetchingParentMessage = false});

  MessageBubbleState copyWith(
      {AmityMessage? message,
      AmityMessage? parentMessage,
      bool isFetchignParentMessage = false}) {
    return MessageBubbleState(
        message: message ?? this.message,
        parentMessage: parentMessage,
        isFetchingParentMessage: isFetchignParentMessage);
  }
}
