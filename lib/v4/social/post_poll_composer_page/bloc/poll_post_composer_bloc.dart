import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'poll_post_composer_events.dart';
part 'poll_post_composer_state.dart';


class PollComposerBloc extends Bloc<PollComposerEvent, PollComposerState> {
  PollComposerBloc() : super(const PollComposerState()) {
    on<UpdateQuestionEvent>((event, emit) {
      emit(state.copyWith(question: event.question));
    });

    on<UpdateOptionsEvent>((event, emit) {
      emit(state.copyWith(options: event.options));
    });

    on<UpdateMultipleChoiceEvent>((event, emit) {
      emit(state.copyWith(isMultipleChoice: event.isMultipleChoice));
    });

    on<UpdateDurationEvent>((event, emit) {
      emit(state.copyWith(selectedPollDurationIndex: event.durationIndex));
    });

    on<UpdateCustomDateEvent>((event, emit) {
      emit(state.copyWith(customDate: event.customDate));
    });

    on<UpdatePostingStateEvent>((event, emit) {
      emit(state.copyWith(isPosting: event.isPosting));
    });

    on<PostPollEvent>((event, emit) async {
      emit(state.copyWith(isPosting: true));
      // Simulate API call to post the poll.
      await Future.delayed(const Duration(seconds: 2));
      emit(state.copyWith(isPosting: false));
    });
  }
}