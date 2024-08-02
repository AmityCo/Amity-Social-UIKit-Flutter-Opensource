import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

part 'create_story_page_event.dart';
part 'create_story_page_state.dart';

class CreateStoryPageBloc extends Bloc<CreateStoryPageEvent, CreateStoryPageState> {
  CreateStoryPageBloc() : super(ImageSelectedState()) {

    on<SelectImageEvent>((event, emit) {
      emit(ImageSelectedState());
    });


    on<SelectVideoEvent>((event, emit) {
      emit(VideoSelectedState());
    });
  }
}
