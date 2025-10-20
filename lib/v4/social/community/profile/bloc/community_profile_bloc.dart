import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/utils/bloc_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'community_profile_events.dart';
part 'community_profile_state.dart';

class CommunityProfileBloc
    extends Bloc<CommunityProfileEvent, CommunityProfileState> {
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
            isJoined: event.community.isJoined,
            isModerator: isModerator,
            canManageStory: canManageStory));
      }
    });

    on<CommunityProfileEventExpanded>((event, emit) async {
      emit(state.copyWith(isExpanded: true));
    });

    on<CommunityProfileEventCollapsed>((event, emit) async {
      emit(state.copyWith(isExpanded: false));
    });

    on<CommunityProfileEventGetPendingPosts>((event, emit) async {
      final community = state.community;
      if (community != null) {
        final pendingPostCount = await community.getPostCount(AmityFeedType.REVIEWING);
        emit(state.copyWith(pendingPostCount: pendingPostCount));
      }
    });

    on<CommunityProfileEventRefreshFromPendingPage>((event, emit) async {
      final community = state.community;
      if (community != null) {
        try {
          final updatedCommunity =
              await AmitySocialClient.newCommunityRepository()
                  .getCommunity(state.communityId);
          final pendingPostCount =
              await updatedCommunity.getPostCount(AmityFeedType.REVIEWING);
          emit(state.copyWith(pendingPostCount: pendingPostCount));
        } catch (e) {
          print("Error fetching pending post count: $e");
        }
      }
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

      scrollController.addListener(() {
        if (state.scrollController.hasClients &&
            state.scrollController.offset > 115) {
          addEvent(CommunityProfileEventCollapsed());
        } else {
          addEvent(CommunityProfileEventExpanded());
        }
      });
    } catch (e) {}
  }
}
