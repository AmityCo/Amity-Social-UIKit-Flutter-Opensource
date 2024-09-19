import 'dart:async';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'global_story_target_event.dart';
part 'global_story_target_state.dart';

class GlobalStoryTargetBloc extends Bloc<GlobalStoryTargetEvent, GlobalStoryTargetState> {
  late GlobalStoryTargetLiveCollection liveCollection;
  var selectedType = AmityGlobalStoryTargetsQueryOption.SMART;
  late StreamSubscription<List<AmityStoryTarget>> _subscription;

  GlobalStoryTargetBloc() : super(GlobalStoryTargetInitial()) {
    on<GlobalStoryTargetEvent>((event, emit) {});

    on<ObserverGlobalStoryTarget>((event, emit) {
      emit(GlobalStoryTargetFetchingState());
      liveCollection = GlobalStoryTargetLiveCollection(queryOption: selectedType);
      _subscription =  liveCollection.getStreamController().stream.listen((targets) {
        if(!isClosed){
          add(GlobalStoryTargetsFetched(targets));
        }
        
      });
      liveCollection.getFirstPageRequest();
    });

    on<GlobalStoryTargetsFetched>((event, emit) {
      emit(GlobalStoryTargetFetchedState(storyTargets: event.storyTargets));
    });

    on<LoadNextTargetStoriesEvent>((event, emit) {
      if (liveCollection.hasNextPage()) {
        liveCollection.loadNext();
      }
    });
    
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
