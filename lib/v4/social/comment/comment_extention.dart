import 'package:amity_sdk/amity_sdk.dart';

extension AmityCommentExtension on AmityComment {
  bool hasReactions() {
    return reactions?.reactions?.entries
            .where((element) => element.value > 0)
            .isNotEmpty ??
        false;
  }

  bool hasMyReactions() {
    return myReactions?.isNotEmpty ?? false;
  }
}
