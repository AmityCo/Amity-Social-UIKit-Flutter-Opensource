import 'dart:async';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/utils/bloc_extension.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'global_feed_event.dart';
part 'global_feed_state.dart';

class GlobalFeedBloc extends Bloc<GlobalFeedEvent, GlobalFeedState> {
  late CustomRankingLiveCollection liveCollection;

  final int pageSize = 20;
  GlobalFeedBloc()
      : super(const GlobalFeedState(
          list: [],
          localList: [],
          hasMoreItems: true,
          isFetching: false,
        )) {
    List<StreamSubscription> subscriptions = [];

    liveCollection = AmitySocialClient.newFeedRepository()
        .getCustomRankingGlobalFeed()
        .getLiveCollection();

    liveCollection.loadNext();

    on<GlobalFeedListUpdated>((event, emit) async {
      final localIds = state.localList.map((e) => e.postId).toList();
      final list = event.posts
          .where((element) => !localIds.contains(element.postId))
          .toList(); // remove duplicates
      list.insertAll(0, state.localList);
      emit(state.copyWith(
          list: list, hasMoreItems: liveCollection.hasNextPage()));
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
  }

  @override
  Future<void> close() {
    liveCollection.dispose();
    return super.close();
  }
}
