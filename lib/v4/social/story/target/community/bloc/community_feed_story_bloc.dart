import 'dart:async';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:bloc/bloc.dart';

part 'community_feed_story_event.dart';
part 'community_feed_story_state.dart';

class CommunityFeedStoryBloc extends Bloc<CommunityFeedStoryEvent, CommunityFeedStoryState> {
  late StoryLiveCollection storyLiveCollection;
  final AmityStorySortingOrder _sortOption = AmityStorySortingOrder.LAST_CREATED;
  late StreamSubscription<List<AmityStory>> _subscriptionStories;
  late StreamSubscription<AmityStoryTarget> _subscriptionTarget;
  CommunityFeedStoryBloc() : super(CommunityFeedStoryState()) {
    on<CheckMangeStoryPermissionEvent>((event, emit) {
      var canManageStories = AmityCoreClient.hasPermission(AmityPermission.MANAGE_COMMUNITY_STORY).atCommunity(event.communityId).check();
      emit(state.copywith(haveStoryPermission: canManageStories));
    });

    on<ObserveStoryTargetEvent>((event, emit) async {
      _subscriptionTarget = AmitySocialClient.newStoryRepository().live.getStoryTaregt(targetType: AmityStoryTargetType.COMMUNITY, targetId: event.communityId).asBroadcastStream().listen((eventStoryTrget) {
        if (!isClosed) {
          add(NewStoryTargetEvent(storyTarget: eventStoryTrget));
        }
      });
    });

    on<StoriesFetchedEvent>((event, emit) {
      emit(state.copywith(stories: event.stories));
    });

    on<SubscribeToCommunityEvent>((event, emit) {
      event.community.subscription(AmityCommunityEvents.STORIES_AND_COMMENTS).subscribeTopic().then((value) {
        add(OnEventSubscribedEvent());
      }).onError((error, stackTrace) {
        emit(state.copywith(isEventSubscribed: false));
      });
    });

    on<OnEventSubscribedEvent>((event, emit) {
      emit(state.copywith(isEventSubscribed: true));
    });

    on<NewStoryTargetEvent>((event, emit) {
      // if(state.storyTarget!.syncingStoriesCount>0 && state.storyTarget!.syncingStoriesCount >= event.storyTarget.syncingStoriesCount){
      //   // Show the SnackBar
      // }

      if (event.storyTarget is AmityStoryTargetCommunity) {
        var storyTarget = event.storyTarget as AmityStoryTargetCommunity;
        if (state.isEventSubscribed == false) {
          add(SubscribeToCommunityEvent(community: storyTarget.community!));
          emit(state.copywith(isEventSubscribed: true, isLoading: false));
        }
        emit(state.copywith(storyTarget: event.storyTarget, community: storyTarget.community, isLoading: false));
      } else {
        emit(state.copywith(storyTarget: event.storyTarget, isLoading: false));
      }
    });

    on<FetchStories>((event, emit) async {
      storyLiveCollection = StoryLiveCollection(request: () => AmitySocialClient.newStoryRepository().getActiveStories(targetId: event.communityId, targetType: AmityStoryTargetType.COMMUNITY, orderBy: _sortOption).build());
      _subscriptionStories = storyLiveCollection.getStreamController().stream.asBroadcastStream().listen((event) {
        if (!isClosed) {
          add(StoriesFetchedEvent(stories: event));
        }
      });
      storyLiveCollection.getData();
    });
  }

  @override
  Future<void> close() {
    _subscriptionStories.cancel();
    _subscriptionTarget.cancel();
    return super.close();
  }
}
