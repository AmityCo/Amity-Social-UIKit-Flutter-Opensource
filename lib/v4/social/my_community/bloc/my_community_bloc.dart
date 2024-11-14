import 'dart:async';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'my_community_events.dart';
part 'my_community_state.dart';

class MyCommunityBloc extends Bloc<MyCommunityEvent, MyCommunityState> {
  final int pageSize = 20;
  late CommunityLiveCollection communityLiveCollection;
  late StreamSubscription<List<AmityCommunity>> _subscription;

  MyCommunityBloc() : super(const MyCommunityState()) {
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
        add(MyCommunityEventLoading());
      } else if (communities.isNotEmpty) {
        var state = MyCommunityLoaded(
          list: communities,
          hasMoreItems: communityLiveCollection.hasNextPage(),
          isFetching: communityLiveCollection.isFetching,
        );
        add(MyCommunityEventLoaded(state));
      }
    });

    on<MyCommunityEventLoaded>((event, emit) async {
      emit(event.loadedState);
    });

    on<MyCommunityEventLoading>((event, emit) async {
      emit(MyCommunityLoading());
    });

    on<MyCommunityEventInitial>((event, emit) async {
      communityLiveCollection.reset();
      communityLiveCollection.loadNext();
    });

    on<MyCommunityEventLoadMore>((event, emit) async {
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
