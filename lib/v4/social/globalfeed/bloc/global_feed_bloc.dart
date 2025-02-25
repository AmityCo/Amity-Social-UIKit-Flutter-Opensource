import 'dart:async';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/utils/bloc_extension.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'global_feed_event.dart';
part 'global_feed_state.dart';

class GlobalFeedBloc extends Bloc<GlobalFeedEvent, GlobalFeedState> {
  late CustomRankingLiveCollection liveCollection;
  late GlobalPinnedPostLiveCollection pinnedPostCollection;
  final int pageSize = 20;

  GlobalFeedBloc()
      : super(const GlobalFeedState(
          list: [],
          localList: [],
          hasMoreItems: true,
          isFetching: false,
          pinnedPosts: [],
          pinnedPostIds: {},
        )) {
    List<StreamSubscription> subscriptions = [];

    liveCollection = AmitySocialClient.newFeedRepository()
        .getCustomRankingGlobalFeed()
        .getLiveCollection();

    pinnedPostCollection = AmitySocialClient.newPostRepository().getGlobalPinnedPosts();

    on<GlobalFeedListUpdated>((event, emit) async {
      updateFeed(event.posts, state.pinnedPosts, emit);
    });

    on<GlobalFeedLocalPostUpdated>((event, emit) async {
      final post = event.post;
      final localList = state.localList.toList();
      if (localList.isNotEmpty) {
        final index =
            localList.indexWhere((element) => element.postId == post.postId);
        if (index != -1) {
          localList[index] = post;
          emit(state.copyWith(localList: localList));
          addEvent(GlobalFeedListUpdated(posts: state.list));
        }
      }
    });

    on<GlobalFeedAddLocalPost>((event, emit) async {
      final post = event.post;
      final localList = state.localList.toList();
      localList.insert(0, post);
      final list = state.list.toList();
      list.insertAll(0, localList);
      emit(state.copyWith(localList: localList, list: list));
      await Future.delayed(const Duration(seconds: 1));
      final subscription = AmitySocialClient.newPostRepository()
          .live
          .getPost(post.postId!)
          .listen((event) {
        addEvent(GlobalFeedLocalPostUpdated(post: event));
      });
      subscriptions.add(subscription);
    });

    on<GlobalFeedRefresh>((event, emit) async {
      emit(const GlobalFeedState(
        list: [],
        localList: [],
        hasMoreItems: true,
        isFetching: false,
        pinnedPosts: [],
        pinnedPostIds: {},
      ));
      for (var subscription in subscriptions) {
        subscription.cancel();
      }
      liveCollection.reset();
      liveCollection.loadNext();
    });

    on<GlobalFeedLoadNext>((event, emit) async {
      if (liveCollection.hasNextPage()) {
        liveCollection.loadNext();
      }
    });

    on<GlobalFeedLoadingStateUpdated>((event, emit) async {
      emit(state.copyWith(isFetching: event.isLoading));
    });

    liveCollection.getStreamController().stream.listen((event) {
      addEvent(GlobalFeedListUpdated(posts: event));
    });

    liveCollection.observeLoadingState().listen((isLoading) {
      addEvent(GlobalFeedLoadingStateUpdated(isLoading: isLoading));
    });

    // Global Pinned Posts
    on<GlobalFeedPinPostUpdated>((event, emit) async {
      // First we collect pinned post ids
      final pinnedPosts = event.pinnedPosts;
      updateFeed(state.list, pinnedPosts, emit);
    });

    pinnedPostCollection.getStreamController().stream.listen((pinnedPosts) {
      addEvent(GlobalFeedPinPostUpdated(pinnedPosts: pinnedPosts));
    });

    // Load live collection
    pinnedPostCollection.loadNext();
    liveCollection.loadNext();
  }

  @override
  Future<void> close() {
    liveCollection.dispose();
    pinnedPostCollection.dispose();
    return super.close();
  }

  // We want to render the feed from here instead.
  void updateFeed(
    List<AmityPost> posts,
    List<AmityPinnedPost> pinnedPosts,
    Emitter<GlobalFeedState> emit,
  ) {
    final pinnedPostIds = pinnedPosts.map((e) => e.postId).toSet();
    final mappedPinnedPosts =
        pinnedPosts.map((e) => e.post).whereType<AmityPost>().toList();

    final localIds = state.localList.map((e) => e.postId).toList();

    // Remove duplicated local post
    var list = posts
        .where((element) =>
            !localIds.contains(element.postId))
            .toList(); // remove duplicates

    // Remove duplicated pinned post
    list = posts
        .where((element) =>
            !pinnedPostIds.contains(element.postId))
        .toList();

    // Local post would be below pinned post
    if (state.localList.isNotEmpty) {
      list.insertAll(0, state.localList);
    }

    // Pinned post will be at the top
    if (mappedPinnedPosts.isNotEmpty) {
      list.insertAll(0, mappedPinnedPosts);
    }
    
    emit(state.copyWith(
        list: list,
        hasMoreItems: liveCollection.hasNextPage(),
        pinnedPostIds: pinnedPostIds,
        pinnedPosts: pinnedPosts));
  }
}
