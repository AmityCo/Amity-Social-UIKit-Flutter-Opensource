import 'dart:async';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/utils/bloc_extension.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'global_search_event.dart';
part 'global_search_state.dart';

class GlobalSearchBloc extends Bloc<GlobalSearchEvent, GlobalSearchState> {
  final int pageSize = 20;
  StreamSubscription<List<AmityCommunity>>? subscription;

  late CommunityLiveCollection communityLiveCollection;
  late PagingController<AmityUser> _amityUsersController;

  var isFetching = true;

  GlobalSearchBloc() : super(GlobalSearchInitial()) {
    on<SearchUsersEvent>((event, emit) async {
      emit(GlobalSearchTextChange(event.searchText));
      var searchText = '';
      searchText = event.searchText;

      _amityUsersController = PagingController(
        pageFuture: (token) => AmityCoreClient.newUserRepository()
            .searchUserByDisplayName(searchText)
            .matchType(AmityUserSearchMatchType.PARTIAL)
            .sortBy(AmityUserSortOption.DISPLAY)
            .getPagingData(token: token, limit: 20),
        pageSize: 20,
      )..addListener(
          () {
            if (_amityUsersController.error == null && !isClosed) {
              List<AmityUser> amityUsers = [];
              amityUsers.addAll(_amityUsersController.loadedItems);
              add(NotifyUsersEvent(amityUsers, _amityUsersController.isFetching));
            }
          },
        );

      _amityUsersController.fetchNextPage();
    });

    on<SearchCommunitiesEvent>((event, emit) async {
      List<AmityCommunity> amityCommunities = [];

      communityLiveCollection = AmitySocialClient.newCommunityRepository()
          .getCommunities()
          .sortBy(AmityCommunitySortOption.DISPLAY_NAME)
          .includeDeleted(false)
          .withKeyword(event.text)
          .getLiveCollection(pageSize: 20);

      if (subscription != null) {
        subscription!.cancel();
      }
      communityLiveCollection.observeLoadingState().listen((event) {
        isFetching = event;
        addEvent(NotifyCommunitiesEvent(amityCommunities, isFetching));
      });

      subscription = communityLiveCollection
          .getStreamController()
          .stream
          .listen((communities) async {
        if (communities.isNotEmpty) {
          amityCommunities = communities;
          addEvent(NotifyCommunitiesEvent(amityCommunities, isFetching));
        } else {
          amityCommunities.clear();
        }
      });

      communityLiveCollection.reset();
      await communityLiveCollection.loadNext();
    });

    on<NotifyUsersEvent>((event, emit) async {
      emit(GlobalUserSearchLoaded(event.users, event.isFetching));
    });

    on<NotifyCommunitiesEvent>((event, emit) async {
      emit(GlobalSearchLoaded(event.communities, event.isFetching));
    });

    on<GlobalSearchLoadMoreEvent>((event, emit) async {
      await communityLiveCollection.loadNext();
    });

    on<GlobalUserSearchLoadMoreEvent>((event, emit) async {
      await _amityUsersController.fetchNextPage();
    });
  }
}
