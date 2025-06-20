part of 'amity_group_member_list_page.dart';

class AmityGroupMemberListCubit extends Cubit<AmityGroupMemberListState> {
  final AmityChannel channel;
  final AmityToastBloc? toastBloc;
  late ChannelMemberSearchLiveCollection memberLiveCollection;
  StreamSubscription<List<AmityChannelMember>>? _membersSubscription;
  StreamSubscription<bool>? _loadingSubscription;
  String _searchQuery = '';

  AmityGroupMemberListCubit({required this.channel, this.toastBloc})
      : super(const AmityGroupMemberListState()) {
    loadChannelMembers();
    _loadCurrentUserRoles();
  }

  Future<void> loadChannelMembers() async {
    emit(state.copyWith(isLoading: true));
    // If activeTab is 'moderators', filter by role
    memberLiveCollection = state.activeTab == 'moderators'
        ? AmityChatClient.newChannelRepository()
            .membership(channel.channelId ?? "")
            .searchMembers(_searchQuery)
            .role("channel-moderator")
            .getLiveCollection()
        : AmityChatClient.newChannelRepository()
            .membership(channel.channelId ?? "")
            .searchMembers(_searchQuery)
            .getLiveCollection();

    _loadingSubscription?.cancel();
    _membersSubscription?.cancel();

    _loadingSubscription =
        memberLiveCollection.observeLoadingState().listen((isLoading) {
      emit(state.copyWith(isLoading: isLoading));
    });

    _membersSubscription = memberLiveCollection
        .getStreamController()
        .stream
        .listen((members) async {
      final users =
          members.map((member) => member.user).whereType<AmityUser>().toList();

      final memberRolesMap = <String, List<String>>{};

      // Populate member roles map with each member's roles
      for (var member in members) {
        if (member.userId != null && member.roles != null) {
          memberRolesMap[member.userId!] = member.roles!.roles ?? [];
        }
      }

      // Sort users to place current user first using getMyMembership
      try {
        final myMembership = await AmityChatClient.newChannelRepository()
            .membership(channel.channelId ?? "")
            .getMyMembership();

        final currentUser = myMembership.user;
        if (currentUser != null) {
          // Add current user's roles to memberRolesMap
          if (myMembership.userId != null && myMembership.roles != null) {
            memberRolesMap[myMembership.userId!] =
                myMembership.roles!.roles ?? [];
          }

          // Check if we should put current user first
          final shouldPutCurrentUserFirst = state.activeTab != 'moderators' ||
              (myMembership.roles?.roles?.contains("channel-moderator") ??
                  false);

          if (shouldPutCurrentUserFirst) {
            users.removeWhere((user) => user.userId == currentUser.userId);
            users.insert(0, currentUser);
          }
        }
      } catch (e) {
        // Fallback to previous method if getMyMembership fails
        final currentUserId = AmityCoreClient.getUserId();
        if (currentUserId.isNotEmpty) {
          final currentUserIndex =
              users.indexWhere((user) => user.userId == currentUserId);
          if (currentUserIndex != -1) {
            final currentUser = users.removeAt(currentUserIndex);

            // Check if we should put current user first
            final currentUserRoles = memberRolesMap[currentUserId] ?? [];
            final shouldPutCurrentUserFirst = state.activeTab != 'moderators' ||
                currentUserRoles.contains("channel-moderator");

            if (shouldPutCurrentUserFirst) {
              users.insert(0, currentUser);
            } else {
              // Put the user back in their original position if they shouldn't be first
              users.insert(currentUserIndex, currentUser);
            }
          }
        }
      }
      emit(state.copyWith(
        members: users,
        hasMoreMembers: memberLiveCollection.hasNextPage(),
        memberRoles: memberRolesMap,
        isLoading: false,
      ));
    });

    memberLiveCollection.reset();
    memberLiveCollection.loadNext();
  }

  Future<void> _loadCurrentUserRoles() async {
    try {
      final currentUserRoles = await channel.getCurentUserRoles();
      emit(state.copyWith(currentUserRoles: currentUserRoles));
    } catch (e) {
      // If there's an error fetching roles, emit empty list (non-moderator)
      emit(state.copyWith(currentUserRoles: []));
    }
  }

  void changeTab(String tabName) {
    if (tabName != state.activeTab) {
      emit(state.copyWith(isLoading: true));

      emit(state.copyWith(activeTab: tabName));
      // Reset search query when changing tabs
      _searchQuery = '';
      // Reload members with new tab filter
      loadChannelMembers();
    }
  }

  void loadMoreMembers() {
    if (!state.isLoading) {
      emit(state.copyWith(isLoading: true));
      memberLiveCollection.loadNext();
    }
  }

  void searchMembers(String query) {
    _searchQuery = query;
    // Reset loading state when searching
    emit(state.copyWith(isLoading: false));
    loadChannelMembers();
  }

  Future<void> addMembersToChannel(List<AmityUser> users) async {
    if (users.isEmpty) return;
    List<String> userIds = users.map((user) => user.userId!).toList();

    try {
      await AmityChatClient.newChannelRepository().addMembers(
        channel.channelId ?? "",
        userIds,
      );

      toastBloc?.add(AmityToastShort(
          message: userIds.length > 1 ? 'Members added' : 'Member added.',
          icon: AmityToastIcon.success));
      // Refresh the member list
      loadChannelMembers();
      // Refresh current user roles in case they were affected
      _loadCurrentUserRoles();
    } catch (e) {
      toastBloc?.add(AmityToastShort(
          message: userIds.length > 1
              ? 'Failed to add members. Please try again.'
              : 'Failed to add member. Please try again.',
          icon: AmityToastIcon.warning));
    }
  }

  Future<void> removeMember(String userId) async {
    try {
      await AmityChatClient.newChannelRepository()
          .removeMembers(channel.channelId ?? "", [userId]);

      // Refresh the member list

      toastBloc?.add(const AmityToastShort(
          message: 'Member removed.', icon: AmityToastIcon.success));
      loadChannelMembers();
      // Refresh current user roles in case they were affected
      _loadCurrentUserRoles();
    } catch (e) {
      toastBloc?.add(const AmityToastShort(
          message: 'Failed to remove member. Please try again.',
          icon: AmityToastIcon.warning));
    }
  }

  Future<void> addModerator(String userId) async {
    try {
      await AmityChatClient.newChannelRepository()
          .moderation(channel.channelId ?? "")
          .addRole("channel-moderator", [userId]);

      // Show success toast
      toastBloc?.add(const AmityToastShort(
          message: 'Member promoted.', icon: AmityToastIcon.success));

      // Refresh the member list
      loadChannelMembers();
      // Refresh current user roles in case they were affected
      _loadCurrentUserRoles();
    } catch (e) {
      // Show failure toast
      toastBloc?.add(const AmityToastShort(
          message: 'Failed to promote member. Please try again.',
          icon: AmityToastIcon.warning));
    }
  }

  Future<void> removeModerator(String userId) async {
    try {
      await AmityChatClient.newChannelRepository()
          .moderation(channel.channelId ?? "")
          .removeRole("channel-moderator", [userId]);

      // Show success toast
      toastBloc?.add(const AmityToastShort(
          message: 'Member demoted.', icon: AmityToastIcon.success));

      // Refresh the member list
      loadChannelMembers();
      // Refresh current user roles in case they were affected
      _loadCurrentUserRoles();
    } catch (e) {
      // Show failure toast
      toastBloc?.add(const AmityToastShort(
          message: 'Failed to demote member. Please try again.',
          icon: AmityToastIcon.warning));
    }
  }

  Future<void> banUser(String userId) async {
    try {
      await AmityChatClient.newChannelRepository()
          .moderation(channel.channelId ?? "")
          .banMembers([userId]);

      // Refresh the member list
      loadChannelMembers();

      await Future.delayed(const Duration(milliseconds: 300));

      toastBloc?.add(const AmityToastShort(
          message: 'User banned.', icon: AmityToastIcon.success));

      // Refresh current user roles in case they were affected
      _loadCurrentUserRoles();
    } catch (e) {
      toastBloc?.add(const AmityToastShort(
          message: 'Failed to ban user. Please try again.',
          icon: AmityToastIcon.warning));
    }
  }

  Future<void> reportUser(AmityUser user) async {
    try {
      if (user.isFlaggedByMe) {
        // Unreport user
        await user.report().unflag();

        toastBloc?.add(const AmityToastShort(
          message: 'User unreported.',
          icon: AmityToastIcon.success,
        ));
      } else {
        // Report user
        await user.report().flag();

        toastBloc?.add(const AmityToastShort(
          message: 'User reported.',
          icon: AmityToastIcon.success,
        ));
      }

      // Add a small delay to ensure the operation completes
      await Future.delayed(const Duration(milliseconds: 300));

      // Refresh the member list to update the report status
      loadChannelMembers();
    } catch (e) {
      // Show failure toast
      final action = user.isFlaggedByMe ? 'unreport' : 'report';
      toastBloc?.add(AmityToastShort(
        message: 'Failed to $action user. Please try again.',
        icon: AmityToastIcon.warning,
      ));
    }
  }

  @override
  Future<void> close() {
    _membersSubscription?.cancel();
    _loadingSubscription?.cancel();
    return super.close();
  }
}
