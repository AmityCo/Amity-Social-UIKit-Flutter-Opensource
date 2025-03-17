import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:amity_sdk/amity_sdk.dart';
import 'package:flutter/material.dart';
part 'communities_by_category_page_event.dart';
part 'communities_by_category_page_state.dart';

class CommunitiesByCategoriesPageBloc extends Bloc<
    CommunitiesByCategoriesPageEvent, CommunitiesByCategoriesPageState> {
  final AmityCommunityCategory category;
  final ScrollController scrollController;
  late CommunityLiveCollection communityLiveCollection;
  late StreamSubscription<List<AmityCommunity>> _subscription;

  CommunitiesByCategoriesPageBloc(this.category, this.scrollController)
      : super(CommunitiesByCategoriesPageState()) {
    on<CommunitiesByCategoriesPageLoadedEvent>((event, emit) {
      emit(state.copyWith(communities: event.communities));
    });

    communityLiveCollection = AmitySocialClient.newCommunityRepository()
        .getCommunities()
        .categoryId(category.categoryId ?? '')
        .sortBy(AmityCommunitySortOption.DISPLAY_NAME)
        .getLiveCollection(pageSize: 20);

    _subscription = communityLiveCollection
        .getStreamController()
        .stream
        .listen((communities) async {
      add(CommunitiesByCategoriesPageLoadedEvent(communities));
    });

    communityLiveCollection.reset();
    communityLiveCollection.loadNext();

    scrollController.removeListener(() {});
    scrollController.addListener(() {
      final maxScroll = scrollController.position.maxScrollExtent;
      final currentScroll = scrollController.position.pixels;
      const threshold = 200.0; // Load more when within 200 pixels of the bottom

      if (maxScroll - currentScroll <= threshold) {
        communityLiveCollection.loadNext();
      }
    });
  }
}
