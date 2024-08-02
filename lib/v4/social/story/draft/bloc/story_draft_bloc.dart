import 'dart:io';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'story_draft_event.dart';
part 'story_draft_state.dart';

class StoryDraftBloc extends Bloc<StoryDraftEvent, StoryDraftState> {
  StoryDraftBloc() : super(StoryDraftInitial()) {
    on<ObserveStoryTargetEvent>((event, emit) {
      AmitySocialClient.newStoryRepository()
          .live
          .getStoryTaregt(
              targetType: event.targetType, targetId: event.communityId)
          .asBroadcastStream()
          .listen((event) {
        add(NewStoryTargetEvent(storyTarget: event));
      });
    });

    on<NewStoryTargetEvent>((event, emit) {
      emit(StoryDraftInitial()..storyTarget = event.storyTarget..imageDisplayMode = state.imageDisplayMode);
    });

    on<OnHyperlinkAddedEvent>((event, emit) {
      emit(HyperlinkAddedState()..hyperlink = event.hyperlink
        ..storyTarget = state.storyTarget);
    });

    on<OnHyperlinkRemovedEvent>((event, emit) {
      emit(StoryDraftInitial()..storyTarget = state.storyTarget);
    });


    on<DraftLoadingEvent>((event, emit) {
      emit(LoadingState()..storyTarget = state.storyTarget ..hyperlink = state.hyperlink);
    });

    on<OnPostImageStoryEvent>((event, emit) async {
      if (state.storyTarget == null) {
        return;
      }
      // print("imageDisplayMode ------> ${event.imageDisplayMode}");
      //  AmitySocialClient.newStoryRepository().createImageStory(
      //   targetType: state.storyTarget!.targetType,
      //   targetId: state.storyTarget!.targetId,
      //   imageFile: event.imageFile,
      //   storyItems:  event.hyperlink!=null ? [event.hyperlink!] : [],
      //   imageDisplayMode: event.imageDisplayMode,
      // ).then((value) => null).onError((error, stackTrace) => null);
      add(OnStoryPostedEvent());
    });

    on<OnPostVideoStoryEvent>((event, emit) async {
      if (state.storyTarget == null) {
        return;
      }
      //  AmitySocialClient.newStoryRepository().createVideoStory(
      //   targetType: state.storyTarget!.targetType,
      //   targetId: state.storyTarget!.targetId,
      //   storyItems:  event.hyperlink!=null ? [event.hyperlink!] : [],
      //   videoFile: event.videoFile,
      // ).then((value) => null).onError((error, stackTrace) => null);
      add(OnStoryPostedEvent());
    });

    on<OnStoryPostedEvent>((event, emit) {
      emit(StoryPostedState());
    });


    on<FillFitToggleEvent>((event, emit) {
      emit(FitFillToggleState()..hyperlink = state.hyperlink ..storyTarget = state.storyTarget ..imageDisplayMode = event.imageDisplayMode);
    });
  }
}
