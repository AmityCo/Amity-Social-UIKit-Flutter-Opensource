import 'dart:async';
import 'dart:developer';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/amity_uikit_toast.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'community_membership_page_event.dart';
part 'community_membership_page_state.dart';

class CommunityMembershipPageBloc
    extends Bloc<CommunityMembershipPageEvent, CommunityMembershipPageState> {
  late CommunityMemberLiveCollection memberLiveCollection;
  late CommunityMemberLiveCollection moderatorLiveCollection;
  final AmityCommunity community;
  final ScrollController memberScrollController;
  final ScrollController moderatorScrollController;

  StreamSubscription<List<AmityCommunityMember>>? memberStreamSubscription;
  StreamSubscription<List<AmityCommunityMember>>? moderatorStreamSubscription;

  CommunityMembershipPageBloc(
      {required this.community,
      required this.memberScrollController,
      required this.moderatorScrollController})
      : super(CommunityMembershipPageState()) {
    on<CommunityMembershipPageMemberLoadedEvent>((event, emit) {
      emit(state.copyWith(
        members: event.members,
      ));
    });

    memberLiveCollection = AmitySocialClient.newCommunityRepository()
        .membership(community.communityId ?? '')
        .searchMembers('')
        .filter(AmityCommunityMembershipFilter.MEMBER)
        .includeDeleted(false)
        .getLiveCollection();

    memberStreamSubscription =
        memberLiveCollection.getStreamController().stream.listen((event) {
      add(CommunityMembershipPageMemberLoadedEvent(event));
    });

    memberLiveCollection.loadNext();

    memberScrollController.addListener(() {
      final maxScroll = memberScrollController.position.maxScrollExtent;
      final currentScroll = memberScrollController.position.pixels;
      const threshold = 200.0;

      if (maxScroll - currentScroll <= threshold) {
        memberLiveCollection.loadNext();
      }
    });

    on<CommunityMembershipPageCurrentUserRolesEvent>((event, emit) {
      emit(state.copyWith(
        isCurrentUserModerator: event.roles.contains('community-moderator'),
      ));
    });

    community.getCurentUserRoles().then((roles) {
      add(CommunityMembershipPageCurrentUserRolesEvent(roles));
    });

    on<CommunityMembershipPageModeratorLoadedEvent>((event, emit) {
      emit(state.copyWith(
        moderators: event.moderators,
      ));
    });

    moderatorLiveCollection = AmitySocialClient.newCommunityRepository()
        .membership(community.communityId ?? '')
        .getMembers()
        .filter(AmityCommunityMembershipFilter.MEMBER)
        .roles(['community-moderator'])
        .includeDeleted(false)
        .getLiveCollection();

    moderatorStreamSubscription =
        moderatorLiveCollection.getStreamController().stream.listen((event) {
      add(CommunityMembershipPageModeratorLoadedEvent(event));
    });

    moderatorLiveCollection.loadNext();

    moderatorScrollController.addListener(() {
      final maxScroll = moderatorScrollController.position.maxScrollExtent;
      final currentScroll = moderatorScrollController.position.pixels;
      const threshold = 200.0;

      if (maxScroll - currentScroll <= threshold) {
        moderatorLiveCollection.loadNext();
      }
    });

    on<CommunityMembershipPageAddMemberEvent>((event, emit) {
      AmitySocialClient.newCommunityRepository()
          .membership(community.communityId ?? '')
          .addMembers(event.userIds)
          .then((value) {
        event.toastBloc.add(AmityToastShort(
            message: event.successMessage, icon: AmityToastIcon.success));
      }).onError((error, stackTrace) {
        event.toastBloc.add(AmityToastShort(
            message: event.errorMessage, icon: AmityToastIcon.warning));
      });
    });

    on<CommunityMembershipPageSearchMemberEvent>((event, emit) {
      memberLiveCollection = AmitySocialClient.newCommunityRepository()
          .membership(community.communityId ?? '')
          .searchMembers(event.keyword)
          .filter(AmityCommunityMembershipFilter.MEMBER)
          .includeDeleted(false)
          .getLiveCollection();

      memberStreamSubscription?.cancel();
      memberStreamSubscription =
          memberLiveCollection.getStreamController().stream.listen((event) {
        var count = event.length;
        log("pageCount: $count");
        log("1st member: ${event[0].user?.displayName}");
        add(CommunityMembershipPageMemberLoadedEvent(event));
      });

      memberLiveCollection.loadNext();
    });

    on<CommunityMembershipPageBottomSheetEvent>((event, emit) {
      final repository = AmitySocialClient.newCommunityRepository();

      switch (event.action) {
        case CommunityMembershipPageBottomSheetAction.promote:
          repository.moderation(community.communityId ?? '').addRole(
              'community-moderator', [event.member.userId ?? '']).then((value) {
            event.toastBloc.add(AmityToastShort(
                message: event.successMessage, icon: AmityToastIcon.success));
          }).onError((error, stackTrace) {
            event.toastBloc.add(AmityToastShort(
                message: event.errorMessage, icon: AmityToastIcon.warning));
          });
          break;
        case CommunityMembershipPageBottomSheetAction.demote:
          repository.moderation(community.communityId ?? '').removeRole(
              'community-moderator', [event.member.userId ?? '']).then((value) {
            event.toastBloc.add(AmityToastShort(
                message: event.successMessage, icon: AmityToastIcon.success));
          }).onError((error, stackTrace) {
            event.toastBloc.add(AmityToastShort(
                message: event.errorMessage, icon: AmityToastIcon.warning));
          });
          break;
        case CommunityMembershipPageBottomSheetAction.remove:
          repository
              .membership(community.communityId ?? '')
              .removeMembers([event.member.userId ?? '']).then((value) {
            event.toastBloc.add(AmityToastShort(
                message: event.successMessage, icon: AmityToastIcon.success));
          }).onError((error, stackTrace) {
            event.toastBloc.add(AmityToastShort(
                message: event.errorMessage, icon: AmityToastIcon.warning));
          });
          break;
        case CommunityMembershipPageBottomSheetAction.report:
          event.member.user?.report().flag().then((value) {
            event.toastBloc.add(AmityToastShort(
                message: event.successMessage, icon: AmityToastIcon.success));
          }).onError((error, stackTrace) {
            event.toastBloc.add(AmityToastShort(
                message: event.errorMessage, icon: AmityToastIcon.warning));
          });
          break;
        case CommunityMembershipPageBottomSheetAction.unreport:
          event.member.user?.report().unflag().then((value) {
            event.toastBloc.add(AmityToastShort(
                message: event.successMessage, icon: AmityToastIcon.success));
          }).onError((error, stackTrace) {
            event.toastBloc.add(AmityToastShort(
                message: event.errorMessage, icon: AmityToastIcon.warning));
          });
          break;
      }
    });
  }

  @override
  Future<void> close() {
    memberStreamSubscription?.cancel();
    moderatorStreamSubscription?.cancel();
    memberScrollController.dispose();
    moderatorScrollController.dispose();
    return super.close();
  }
}
