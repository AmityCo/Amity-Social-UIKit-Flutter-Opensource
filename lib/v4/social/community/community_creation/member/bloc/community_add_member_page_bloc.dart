import 'dart:async';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/freedom_uikit_behavior.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_membership/freedom_community_membership_behavior.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'community_add_member_page_event.dart';
part 'community_add_member_page_state.dart';

class CommunityAddMemberPageBloc
    extends Bloc<CommunityAddMemberPageEvent, CommunityAddMemberPageState> {
  final ScrollController scrollController;
  UserLiveCollection? _userLiveCollection;
  StreamSubscription<List<AmityUser>>? _userStreamSubscription;

  FreedomCommunityMembershipBehavior get _behavior => FreedomUIKitBehavior.instance.communityMembershipBehavior;

  CommunityAddMemberPageBloc({required this.scrollController, required List<AmityUser> selectedUsers})
      : super(CommunityAddMemberPageState().copyWith(selectedUsers: selectedUsers)) {

    on<CommunityAddMemberPageSearchUserEvent>((event, emit) {
      _userLiveCollection = AmityCoreClient.newUserRepository()
          .searchUserByDisplayName(event.keyword)
          .getLiveCollection();

      _userStreamSubscription?.cancel();
      _userStreamSubscription =
          _userLiveCollection?.getStreamController().stream.listen((users) {
        add(CommunityAddMemberPageUserLoadEvent(users));
      });

      _userLiveCollection?.getFirstPageRequest();
    });

    // initial loading the first page on page startup...
    add(const CommunityAddMemberPageSearchUserEvent(''));

    scrollController.addListener(() {
      final maxScroll = scrollController.position.maxScrollExtent;
      final currentScroll = scrollController.position.pixels;
      const threshold = 200.0;

      if (maxScroll - currentScroll <= threshold) {
        _userLiveCollection?.loadNext();
      }
    });

    on<CommunityAddMemberPageUserLoadEvent>((event, emit) {
      emit(state.copyWith(users: event.users.where(_behavior.noFreedomAdminUser).toList()));
    });

    on<CommunityAddMemberPageSelectUserEvent>((event, emit) {
      final selectedUsers = List<AmityUser>.from(state.selectedUsers);
      if (selectedUsers.map((e) => e.userId).contains(event.user.userId)) {
        selectedUsers
            .removeWhere((element) => element.userId == event.user.userId);
      } else {
        selectedUsers.add(event.user);
      }

      emit(state.copyWith(selectedUsers: selectedUsers));
    });
  }

  @override
  Future<void> close() {
    _userStreamSubscription?.cancel();
    _userLiveCollection?.dispose();
    scrollController.dispose();
    return super.close();
  }
}
