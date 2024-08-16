import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'post_composer_events.dart';
part 'post_composer_state.dart';


class PostComposerBloc extends Bloc<PostComposerEvent, PostComposerState> {

  PostComposerBloc() : super(const PostComposerState()) {
    
    on<PostComposerTextChangeEvent>((event, emit) {
      emit(PostComposerTextChangeState(text: event.text));
    });
  }
}
