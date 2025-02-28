import 'dart:async';

import 'package:amity_sdk/amity_sdk.dart';
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
      emit(state.copyWith(users: event.users));
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
