part of 'comment_creator_bloc.dart';

class CommentCreatorState extends Equatable {
  const CommentCreatorState({
    required this.text,
    required this.currentHeight,
    required this.replyTo,
  });

  final String text;
  final double currentHeight;
  final AmityComment? replyTo;

  @override
  List<Object?> get props => [text, currentHeight, replyTo];

  CommentCreatorState copyWith({
    String? text,
    double? currentHeight,
    AmityComment? replyTo,
  }) {
    return CommentCreatorState(
      text: text ?? this.text,
      currentHeight: currentHeight ?? this.currentHeight,
      replyTo: replyTo ?? this.replyTo, 
    );
  }
}