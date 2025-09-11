import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/utils/bloc_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'community_feed_events.dart';
part 'community_feed_state.dart';

class CommunityFeedBloc extends Bloc<CommunityFeedEvent, CommunityFeedState> {
  final String communityId;
  final ScrollController scrollController;
  late final PostLiveCollection feedLiveCollection;
  late final PinnedPostLiveCollection announcementLiveCollection;
  late final PinnedPostLiveCollection pinLiveCollection;

  CommunityFeedBloc({required this.communityId, required this.scrollController})
      : super(CommunityFeedState()) {
    feedLiveCollection = AmitySocialClient.newPostRepository()
        .getPosts()
        .targetCommunity(communityId)
        .feedType(AmityFeedType.PUBLISHED)
        .sortBy(AmityPostSortOption.LAST_CREATED)
        .includeDeleted(false)
        .getLiveCollection();

    announcementLiveCollection =
        AmitySocialClient.newPostRepository().getPinnedPosts(
      communityId: communityId,
      placement: "announcement",
    );

    pinLiveCollection = AmitySocialClient.newPostRepository().getPinnedPosts(
      communityId: communityId,
      placement: "default",
    );

    on<CommunityFeedEventPostUpdated>((event, emit) async {
      emit(state.copyWith(posts: event.posts));
    });

    on<CommunityFeedEventAnnouncementUpdated>((event, emit) async {
      emit(state.copyWith(announcements: event.announcements));
    });

    on<CommunityFeedEventPinUpdated>((event, emit) async {
      emit(state.copyWith(pins: event.pins));
    });

    on<CommunityFeedEventLoadingStateUpdated>((event, emit) async {
      emit(state.copyWith(isLoading: event.isLoading));
    });

    on<CommunityFeedEventJoinedStateUpdated>((event, emit) async {
      emit(state.copyWith(isJoined: event.isJoined));
    });

    final communityStream = AmitySocialClient.newCommunityRepository()
        .live
        .getCommunity(communityId);
    communityStream.listen((community) {
      addEvent(CommunityFeedEventJoinedStateUpdated(
          isJoined: community.isJoined ?? true));
    });

    feedLiveCollection.loadNext();
    announcementLiveCollection.loadNext();
    pinLiveCollection.loadNext();

    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        feedLiveCollection.loadNext();
      }
    });

    feedLiveCollection.getStreamController().stream.listen((posts) {
      addEvent(CommunityFeedEventPostUpdated(posts: posts));
    });

    feedLiveCollection.observeLoadingState().listen((isLoading) {
      addEvent(CommunityFeedEventLoadingStateUpdated(isLoading: isLoading));
    });

    announcementLiveCollection
        .getStreamController()
        .stream
        .listen((announcements) {
      addEvent(
          CommunityFeedEventAnnouncementUpdated(announcements: announcements));
    });

    pinLiveCollection.getStreamController().stream.listen((pins) {
      addEvent(CommunityFeedEventPinUpdated(pins: pins));
    });
  }

  @override
  Future<void> close() {
    feedLiveCollection.dispose();
    announcementLiveCollection.dispose();
    pinLiveCollection.dispose();
    return super.close();
  }
}
