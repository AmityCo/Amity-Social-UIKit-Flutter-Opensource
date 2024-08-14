import 'package:amity_sdk/amity_sdk.dart';

class CommentAction {
  void Function(AmityComment? commentId) onReply;

  CommentAction({
    required this.onReply,
  });

  CommentAction copyWith({
    void Function(AmityComment? comment)? onReply,
  }) {
    return CommentAction(
      onReply: onReply ?? this.onReply,
    );
  }
}