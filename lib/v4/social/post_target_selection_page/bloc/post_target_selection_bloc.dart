import 'dart:async';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'post_target_selection_events.dart';
part 'post_target_selection_state.dart';

class PostTargetSelectionBloc
    extends Bloc<PostTargetSelectionEvent, PostTargetSelectionState> {
  final int pageSize = 20;
  late CommunityLiveCollection communityLiveCollection;
  late StreamSubscription<List<AmityCommunity>> _subscription;

  PostTargetSelectionBloc() : super(const PostTargetSelectionState()) {
    communityLiveCollection = AmitySocialClient.newCommunityRepository()
        .getCommunities()
        .filter(AmityCommunityFilter.MEMBER)
        .sortBy(AmityCommunitySortOption.DISPLAY_NAME)
        .getLiveCollection(pageSize: 20);

    _subscription = communityLiveCollection
        .getStreamController()
        .stream
        .listen((communities) async {
      if (communityLiveCollection.isFetching == true && communities.isEmpty) {
        emit(PostTargetSelectionLoading());
      } else if (communities.isNotEmpty) {
        // var state = PostTargetSelectionLoaded(
        //   list: communities,
        //   hasMoreItems: communityLiveCollection.hasNextPage(),
        //   isFetching: communityLiveCollection.isFetching,
        // );
        // print("BlocLength ${state.list.length}");
        // add(PostTargetSelectionEventLoaded());
        add(CommunitiesLoadedEvent(
          communities: communities,
          hasMoreItems: communityLiveCollection.hasNextPage(),
          isFetching: communityLiveCollection.isFetching,
        ));
        // emit(state);
      }
    });

    on<CommunitiesLoadedEvent>((event, emit) async {
      emit(PostTargetSelectionLoaded(
        list: event.communities,
        hasMoreItems: event.hasMoreItems,
        isFetching: event.isFetching,
      ));
    });

    on<PostTargetSelectionEventInitial>((event, emit) async {
      communityLiveCollection.reset();
      communityLiveCollection.loadNext();
    });

    on<PostTargetSelectionEventLoadMore>((event, emit) async {
      if (communityLiveCollection.hasNextPage()) {
        communityLiveCollection.loadNext();
      }
    });
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
