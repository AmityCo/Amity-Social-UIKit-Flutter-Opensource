import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

part 'info_text_field_event.dart';
part 'info_text_field_state.dart';

class InfoTextFieldBloc extends Bloc<InfoTextFieldEvent, InfoTextFieldState> {
  InfoTextFieldBloc({required String text}) : super(InfoTextFieldState(text)) {
    on<InfoTextFieldEvent>((event, emit) {
      // Handle the text change event
      emit(state.copyWith(text: event.text));
    });
  }
}
