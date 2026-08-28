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
  StreamSubscription<List<AmityPost>>? postSubscription;
  StreamSubscription<bool>? communityLoadingSubscription;
  StreamSubscription<bool>? postLoadingSubscription;

  CommunityLiveCollection? communityLiveCollection;
  late PagingController<AmityUser> _amityUsersController;
  SemanticSearchPostLiveCollection? postLiveCollection;

  // Bumped per search so a superseded query's listeners stop feeding results
  // into the current one.
  int _communityRequestId = 0;
  int _postRequestId = 0;
  int _userRequestId = 0;

  var isFetching = true;

  GlobalSearchBloc() : super(GlobalSearchInitial()) {
    on<SearchUsersEvent>((event, emit) async {
      emit(GlobalSearchTextChange(event.searchText));
      final requestId = ++_userRequestId;
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
            if (requestId != _userRequestId) return;
            if (_amityUsersController.error == null && !isClosed) {
              List<AmityUser> amityUsers = [];
              amityUsers.addAll(_amityUsersController.loadedItems);
              add(NotifyUsersEvent(
                  amityUsers, _amityUsersController.isFetching, searchText));
            }
          },
        );

      _amityUsersController.fetchNextPage();
    });

    on<SearchCommunitiesEvent>((event, emit) async {
      List<AmityCommunity> amityCommunities = [];
      final searchText = event.text;
      final requestId = ++_communityRequestId;

      // See the note in SearchPostsEvent: events run concurrently, so capture
      // the previous search's resources before awaiting and never re-read the
      // shared fields afterwards.
      final staleSubscription = subscription;
      final staleLoadingSubscription = communityLoadingSubscription;
      final staleCollection = communityLiveCollection;
      subscription = null;
      communityLoadingSubscription = null;
      communityLiveCollection = null;

      await staleSubscription?.cancel();
      await staleLoadingSubscription?.cancel();
      await staleCollection?.dispose();

      if (requestId != _communityRequestId) return;

      final collection = AmitySocialClient.newCommunityRepository()
          .getCommunities()
          .sortBy(AmityCommunitySortOption.DISPLAY_NAME)
          .includeDeleted(false)
          .withKeyword(event.text)
          .getLiveCollection(pageSize: 20);
      communityLiveCollection = collection;

      communityLoadingSubscription =
          collection.observeLoadingState().listen((event) {
        if (requestId != _communityRequestId) return;
        isFetching = event;
        addEvent(NotifyCommunitiesEvent(amityCommunities, isFetching, searchText));
      });

      subscription = collection.getStreamController().stream.listen((communities) async {
        if (requestId != _communityRequestId) return;
        // An empty result is a result: suppressing it left the previous
        // search's list on screen. The component already renders the skeleton
        // while isFetching and the no-results state once it settles.
        amityCommunities = communities;
        addEvent(NotifyCommunitiesEvent(amityCommunities, isFetching, searchText));
      });

      collection.reset();
      await collection.loadNext();
    });

    on<NotifyUsersEvent>((event, emit) async {
      emit(GlobalUserSearchLoaded(event.users, event.isFetching, event.searchText));
    });

    on<NotifyCommunitiesEvent>((event, emit) async {
      emit(GlobalSearchLoaded(event.communities, event.isFetching, event.searchText));
    });

    on<GlobalSearchLoadMoreEvent>((event, emit) async {
      await communityLiveCollection?.loadNext();
    });

    on<GlobalUserSearchLoadMoreEvent>((event, emit) async {
      await _amityUsersController.fetchNextPage();
    });

    on<SearchPostsEvent>((event, emit) async {
      List<AmityPost> amityPosts = [];
      var isPostFetching = true;
      final searchText = event.searchText;

      final requestId = ++_postRequestId;

      // Bloc processes events concurrently by default, so two searches can be
      // in flight at once. Take ownership of the previous search's resources
      // synchronously, before any await, and never touch the shared fields
      // again afterwards -- a superseded handler resuming later would otherwise
      // cancel the CURRENT search's subscriptions and freeze the results.
      final staleSubscription = postSubscription;
      final staleLoadingSubscription = postLoadingSubscription;
      final staleCollection = postLiveCollection;
      postSubscription = null;
      postLoadingSubscription = null;
      postLiveCollection = null;

      // Cancel before disposing: dispose() closes the collection's stream
      // controller, and that only completes once the controller has been
      // listened to and released.
      await staleSubscription?.cancel();
      await staleLoadingSubscription?.cancel();
      await staleCollection?.dispose();

      if (requestId != _postRequestId) return;

      final collection = AmitySocialClient.newPostRepository()
          .semanticSearchPosts(query: searchText)
          .getLiveCollection(pageSize: 20);
      postLiveCollection = collection;

      postLoadingSubscription =
          collection.observeLoadingState().listen((isFetching) {
        if (requestId != _postRequestId) return;
        isPostFetching = isFetching;
        addEvent(NotifyPostsEvent(amityPosts, isPostFetching, searchText));
      });

      postSubscription = collection.getStreamController().stream.listen((posts) async {
        if (requestId != _postRequestId) return;
        amityPosts = posts;
        addEvent(NotifyPostsEvent(amityPosts, isPostFetching, searchText));
      });

      collection.reset();
      await collection.loadNext();
    });

    on<NotifyPostsEvent>((event, emit) async {
      emit(GlobalPostSearchLoaded(
          event.posts, event.isFetching, event.searchText));
    });

    on<GlobalPostSearchLoadMoreEvent>((event, emit) async {
      await postLiveCollection?.loadNext();
    });
  }

  @override
  Future<void> close() async {
    // Nothing here was torn down before: the loading-state subscriptions were
    // never even stored, and the live collections kept their observers running.
    await subscription?.cancel();
    await postSubscription?.cancel();
    await communityLoadingSubscription?.cancel();
    await postLoadingSubscription?.cancel();
    await communityLiveCollection?.dispose();
    await postLiveCollection?.dispose();
    return super.close();
  }

}
