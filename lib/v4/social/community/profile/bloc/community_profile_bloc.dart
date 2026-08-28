import 'dart:async';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/utils/bloc_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/story/utils/story_creation_rule.dart';

part 'community_profile_events.dart';
part 'community_profile_state.dart';

class CommunityProfileBloc
    extends Bloc<CommunityProfileEvent, CommunityProfileState> {
  PostLiveCollection? _pendingPostsLiveCollection;
  StreamSubscription<List<AmityPost>>? _pendingPostsSubscription;

  CommunityProfileBloc(
    String communityId,
    ScrollController scrollController,
  ) : super(CommunityProfileState(
          communityId: communityId,
          scrollController: scrollController,
        )) {
    on<CommunityProfileEventUpdated>((event, emit) async {
      if (event.community != null) {
        final isModerator =
            AmityCoreClient.hasPermission(AmityPermission.EDIT_COMMUNITY)
                    .atCommunity(communityId)
                    .check() ??
                false;
        final canManageStory = AmityCoreClient.hasPermission(
                    AmityPermission.MANAGE_COMMUNITY_STORY)
                .atCommunity(event.community.communityId!)
                .check() ??
            false;
        emit(state.copyWith(
            community: event.community,
            isJoined: isModerator ? true : (event.community.isJoined ?? state.isJoined),
            isModerator: isModerator,
            canManageStory: canManageStory));
      }
    });

    // Only emit on an actual change. The scroll listener below fires on every
    // scroll notification, and re-emitting the same isExpanded value swaps the
    // header slivers, which changes the scroll extent, which fires the listener
    // again — the flashing loop.
    on<CommunityProfileEventExpanded>((event, emit) async {
      if (!state.isExpanded) emit(state.copyWith(isExpanded: true));
    });

    on<CommunityProfileEventCollapsed>((event, emit) async {
      if (state.isExpanded) emit(state.copyWith(isExpanded: false));
    });

    on<CommunityProfileEventGetPendingPosts>((event, emit) async {
      _refreshPendingPosts();
    });

    on<CommunityProfileEventPendingPostsObserved>((event, emit) async {
      emit(state.copyWith(pendingPostCount: event.count));
    });

    on<CommunityProfileEventRefreshFromPendingPage>((event, emit) async {
      _refreshPendingPosts();
    });

    on<CommunityProfileEventTabSelected>((event, emit) async {
      emit(state.copyWith(selectedIndex: event.tab, isExpanded: true));
    });

    on<CommunityProfileEventJoining>((event, emit) async {
      try {
        emit(state.copyWith(isJoined: true));
        await AmitySocialClient.newCommunityRepository()
            .joinCommunity(event.communityId);
      } catch (e) {
        emit(state.copyWith(isJoined: false));
      }
    });

    on<CommunityProfileEventRefresh>((event, emit) async {
      final community = await AmitySocialClient.newCommunityRepository()
          .getCommunity(event.communityId);
      addEvent(CommunityProfileEventUpdated(community: community));
      addEvent(CommunityProfileEventGetPendingPosts());
    });

    on<CommunityProfileEventExpandDetail>((event, emit) async {
      emit(state.copyWith(isDetailExpanded: true));
    });

    try {
      final communityStream = AmitySocialClient.newCommunityRepository()
          .live
          .getCommunity(communityId);
      communityStream.listen((community) {
        addEvent(CommunityProfileEventUpdated(community: community));
        addEvent(CommunityProfileEventGetPendingPosts());
      });

      // Real-time observer for pending (REVIEWING) posts in this community.
      // We derive the banner count directly from the live collection's local
      // page count. Using community.getPostCount() would read from the
      // community-feed cache, which lags behind local create/delete actions
      // until the server pushes the new count.
      //
      // The banner UI caps the displayed value at "10+", so first-page items
      // (default page size) are sufficient.
      _pendingPostsLiveCollection = AmitySocialClient.newPostRepository()
          .getPosts()
          .targetCommunity(communityId)
          .feedType(AmityFeedType.REVIEWING)
          .includeDeleted(false)
          .getLiveCollection();

      _pendingPostsSubscription = _pendingPostsLiveCollection!
          .getStreamController()
          .stream
          .listen((posts) {
        addEvent(CommunityProfileEventPendingPostsObserved(count: posts.length));
      });

      _pendingPostsLiveCollection!.loadNext();

      // Sole owner of the collapse threshold. The page used to register a second
      // listener with a different threshold (330) on every rebuild; between the
      // two thresholds they emitted contradictory events on every notification.
      scrollController.addListener(() {
        if (state.scrollController.hasClients &&
            state.scrollController.offset > 330) {
          addEvent(CommunityProfileEventCollapsed());
        } else {
          addEvent(CommunityProfileEventExpanded());
        }
      });
    } catch (e) {}
  }

  void _refreshPendingPosts() {
    final collection = _pendingPostsLiveCollection;
    if (collection == null) return;
    collection.reset();
    collection.loadNext();
  }

  @override
  Future<void> close() {
    _pendingPostsSubscription?.cancel();
    return super.close();
  }
}
