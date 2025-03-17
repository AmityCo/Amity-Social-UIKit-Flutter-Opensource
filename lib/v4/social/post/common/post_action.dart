import 'package:amity_sdk/amity_sdk.dart';

class AmityPostAction {
  final Function(String) onAddReaction;
  final Function(String) onRemoveReaction;
  final Function(AmityPost) onPostDeleted;
  final Function(AmityPost) onPostUpdated;

  const AmityPostAction({
    required this.onAddReaction,
    required this.onRemoveReaction,
    required this.onPostDeleted,
    required this.onPostUpdated,
  });

  AmityPostAction copyWith({
    Function(String)? onAddReaction,
    Function(String)? onRemoveReaction,
    Function(AmityPost)? onPostDeleted,
    Function(AmityPost)? onPostUpdated,
  }) {
    return AmityPostAction(
      onAddReaction: onAddReaction ?? this.onAddReaction,
      onRemoveReaction: onRemoveReaction ?? this.onRemoveReaction,
      onPostDeleted: onPostDeleted ?? this.onPostDeleted,
      onPostUpdated: onPostUpdated ?? this.onPostUpdated,
    );
  }
}
