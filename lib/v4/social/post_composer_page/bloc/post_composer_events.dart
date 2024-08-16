part of 'post_composer_bloc.dart';

abstract class PostComposerEvent extends Equatable {
  const PostComposerEvent();

  @override
  List<Object> get props => [];
}

class PostComposerTextChangeEvent extends PostComposerEvent {
  final String text;

  const PostComposerTextChangeEvent({
    required this.text,
  });
}
