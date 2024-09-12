import 'package:amity_sdk/amity_sdk.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'community_profile_events.dart';
part 'community_profile_state.dart';

class CommunityProfileBloc extends Bloc<CommunityProfileEvent, CommunityProfileState> {

  CommunityProfileBloc(
    AmityCommunity community,
    ScrollController scrollController,
  ) : super(CommunityProfileState(
    communityId: community.communityId!,
    community: community,
    scrollController: scrollController, 
  )) {
        on<CommunityProfileEventUpdated>((event, emit) async {
          if (event.community != null) {
            final isModerator = AmityCoreClient.hasPermission(AmityPermission.EDIT_COMMUNITY)
            .atCommunity(community.communityId!)
            .check() ?? false;
            emit(state.copyWith(community: event.community, isJoined: event.community.isJoined, isModerator: isModerator));
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
            final pendingPostCount = await state.community?.getPostCount(AmityFeedType.REVIEWING) ?? 0;
            emit(state.copyWith(pendingPostCount: pendingPostCount));
          }
        });

        on<CommunityProfileEventTabSelected>((event, emit) async {
          emit(state.copyWith(selectedIndex: event.tab, isExpanded: true));
        });

        on<CommunityProfileEventJoining>((event, emit) async {
          try {
            emit(state.copyWith(isJoined: true));
            await AmitySocialClient.newCommunityRepository().joinCommunity(event.communityId);
          } catch (e) { 
            emit(state.copyWith(isJoined: false));
          }
        });

        on<CommunityProfileEventRefresh>((event, emit) async {
          
          final community = await AmitySocialClient.newCommunityRepository().getCommunity(event.communityId);
          if(!isClosed){
            add(CommunityProfileEventUpdated(community: community));
            add(CommunityProfileEventGetPendingPosts());
          }
        });
    
    try {
        final communityStream = AmitySocialClient.newCommunityRepository().live.getCommunity(community.communityId!);
        communityStream.listen((community) {
          if(!isClosed){
            add(CommunityProfileEventUpdated(community: community));
            add(CommunityProfileEventGetPendingPosts());
          }
        });

        community.listen.stream.listen((community) {
          if(!isClosed){
            add(CommunityProfileEventUpdated(community: community));
            add(CommunityProfileEventGetPendingPosts());
          }
        });

        scrollController.addListener(() {
          if (state.scrollController.hasClients &&
              state.scrollController.offset > 115) {
            if (!isClosed) {
              add(CommunityProfileEventCollapsed());
            }
          } else {
            if (!isClosed) {
              add(CommunityProfileEventExpanded());
            }
          }
        });

      } catch (e) {
        
      }
  }
}