part of 'post_composer_bloc.dart';

class PostComposerState extends Equatable {
  const PostComposerState();

  @override
  List<Object?> get props => [];
}

class PostComposerTextChangeState extends PostComposerState {
  PostComposerTextChangeState({required this.text});

  final String text;

  @override
  List<Object> get props => [text];
}