part of 'comment_item_bloc.dart';

class CommentItemState {
  const CommentItemState({
    required this.comment,
    required this.isReacting,
    required this.isExpanded,
    required this.isEditing,
    required this.editedText, // Added editedText field
  });

  final AmityComment comment;
  final bool isReacting;
  final bool isExpanded;
  final bool isEditing;
  final String editedText; // Added editedText field

  @override
  List<Object?> get props => [comment, isReacting, isExpanded, isEditing, editedText];

  CommentItemState copyWith({
    AmityComment? comment,
    bool? isReacting,
    bool? isExpanded,
    bool? isEditing,
    String? editedText, // Added editedText parameter
  }) {
    return CommentItemState(
      comment: comment ?? this.comment,
      isReacting: isReacting ?? this.isReacting,
      isExpanded: isExpanded ?? this.isExpanded,
      isEditing: isEditing ?? this.isEditing,
      editedText: editedText ?? this.editedText, // Added editedText assignment
    );
  }
}
