import 'dart:async';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'my_community_search_event.dart';
part 'my_community_search_state.dart';

class MyCommunitySearchBloc
    extends Bloc<MyCommunitySearchEvent, MyCommunitySearchState> {
  final int pageSize = 20;
  late CommunityLiveCollection communityLiveCollection;
  StreamSubscription<List<AmityCommunity>>? subscription;

  List<AmityCommunity> amityCommunities = [];

  bool isFetching = true;

  MyCommunitySearchBloc() : super(GlobalSearchInitial()) {
    on<MyCommunitySearchTextChanged>((event, emit) async {
      emit(MyCommunitySearchTextChange(event.searchText));
      var searchText = '';
      searchText = event.searchText;
      communityLiveCollection = AmitySocialClient.newCommunityRepository()
          .getCommunities()
          .filter(AmityCommunityFilter.MEMBER)
          .sortBy(AmityCommunitySortOption.DISPLAY_NAME)
          .includeDeleted(false)
          .withKeyword(searchText)
          .getLiveCollection(pageSize: 20);

      if (subscription != null) {
        subscription!.cancel();
      }

      subscription = communityLiveCollection
          .getStreamController()
          .stream
          .listen((communities) async {
        if (communities.isNotEmpty) {
          amityCommunities = communities;
          if (!isClosed) {
            add(NotifyEvent(amityCommunities, isFetching));
          }
        } else {
          amityCommunities.clear();
        }
      });

      communityLiveCollection.observeLoadingState().listen((event) {
        if (!isClosed) {
          add(NotifyEvent(amityCommunities, event));
        }
      });

      communityLiveCollection.reset();
      await communityLiveCollection.loadNext();
    });

    on<NotifyEvent>((event, emit) async {
      emit(MyCommunitySearchLoaded(event.communities, event.isFetching));
    });

    on<MyCommunitySearchLoadMoreEvent>((event, emit) async {
      await communityLiveCollection.loadNext();
    });
  }
}
