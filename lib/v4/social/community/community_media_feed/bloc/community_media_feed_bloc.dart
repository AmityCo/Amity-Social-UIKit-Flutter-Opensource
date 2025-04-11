import 'package:amity_sdk/amity_sdk.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:amity_uikit_beta_service/v4/utils/bloc_extension.dart';

part 'community_media_feed_event.dart';
part 'community_media_feed_state.dart';

enum CommunityMediaFeedType { image, video }

class CommunityMediaFeedBloc
    extends Bloc<CommunityMediaFeedEvent, CommunityMediaFeedState> {
  String communityId;
  CommunityMediaFeedType feedType;
  ScrollController scrollController;
  late final PostLiveCollection feedLiveCollection;

  CommunityMediaFeedBloc(
      {required this.communityId, required this.feedType, required this.scrollController})
      : super(const CommunityMediaFeedState()) {
    on<CommunityMediaFeedEvent>((event, emit) {});
    feedLiveCollection = AmitySocialClient.newPostRepository()
        .getPosts()
        .targetCommunity(communityId)
        .sortBy(AmityPostSortOption.LAST_CREATED)
        .types(feedType == CommunityMediaFeedType.image ? [AmityDataType.IMAGE] : [AmityDataType.VIDEO]).getLiveCollection();

    on<CommunityMediaFeedEventPostUpdated>((event, emit) async {
      emit(state.copyWith(posts: event.posts));
    });

    on<CommunityMediaFeedEventLoadingStateUpdated>((event, emit) async {
      emit(state.copyWith(isLoading: event.isLoading));
    });

    feedLiveCollection.loadNext();

    scrollController.addListener(() {
      final maxScroll = scrollController.position.maxScrollExtent;
      final currentScroll = scrollController.position.pixels;
      const threshold = 200.0;
      
      if (maxScroll - currentScroll <= threshold) {
        feedLiveCollection.loadNext();
      }
    });

    feedLiveCollection.getStreamController().stream.listen((posts) {
      addEvent(CommunityMediaFeedEventPostUpdated(posts: posts));
    });

    feedLiveCollection.observeLoadingState().listen((isLoading) {
      addEvent(
          CommunityMediaFeedEventLoadingStateUpdated(isLoading: isLoading));
    });
  }
}
