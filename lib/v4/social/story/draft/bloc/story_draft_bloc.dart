import 'dart:async';
import 'dart:io';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'story_draft_event.dart';
part 'story_draft_state.dart';

class StoryDraftBloc extends Bloc<StoryDraftEvent, StoryDraftState> {
  StreamSubscription<AmityStoryTarget>? _storyTargetSubscription;
  
  StoryDraftBloc() : super(StoryDraftInitial()) {
    on<ObserveStoryTargetEvent>((event, emit) {
      // Cancel any existing subscription before creating a new one
      _storyTargetSubscription?.cancel();
      
      _storyTargetSubscription = AmitySocialClient.newStoryRepository()
          .live
          .getStoryTaregt(targetType: event.targetType, targetId: event.communityId)
          .asBroadcastStream()
          .listen((storyTarget) {
        add(NewStoryTargetEvent(storyTarget: storyTarget));
      });
    });

    on<NewStoryTargetEvent>((event, emit) {
      emit(StoryDraftInitial()
        ..storyTarget = event.storyTarget
        ..imageDisplayMode = state.imageDisplayMode);
    });

    on<OnHyperlinkAddedEvent>((event, emit) {
      emit(HyperlinkAddedState()
        ..hyperlink = event.hyperlink
        ..imageDisplayMode = state.imageDisplayMode
        ..storyTarget = state.storyTarget);
    });

    on<OnHyperlinkRemovedEvent>((event, emit) {
      emit(StoryDraftInitial()..storyTarget = state.storyTarget);
    });

    on<DraftLoadingEvent>((event, emit) {
      emit(LoadingState()
        ..storyTarget = state.storyTarget
        ..hyperlink = state.hyperlink);
    });

    on<OnPostImageStoryEvent>((event, emit) async {
      if (state.storyTarget == null) {
        return;
      }
      add(OnStoryPostedEvent());
    });

    on<OnPostVideoStoryEvent>((event, emit) async {
      if (state.storyTarget == null) {
        return;
      }
      add(OnStoryPostedEvent());
    });

    on<OnStoryPostedEvent>((event, emit) {
      emit(StoryPostedState());
    });

    on<FillFitToggleEvent>((event, emit) {
      emit(FitFillToggleState()
        ..hyperlink = state.hyperlink
        ..storyTarget = state.storyTarget
        ..imageDisplayMode = event.imageDisplayMode);
    });
  }

  @override
  Future<void> close() async {
    await _storyTargetSubscription?.cancel();
    return super.close();
  }
}
