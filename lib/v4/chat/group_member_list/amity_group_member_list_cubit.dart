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
                        .membershipFilter([
            AmityChannelMembership.MEMBER,
            AmityChannelMembership.MUTED
          ])

            .getLiveCollection()
        : AmityChatClient.newChannelRepository()
            .membership(channel.channelId ?? "")
            .searchMembers(_searchQuery)
            .membershipFilter([AmityChannelMembership.MEMBER, AmityChannelMembership.MUTED])
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
      final mutedUsersMap = <String, bool>{};

      // Populate member roles map with each member's roles and muted status
      for (var member in members) {
        if (member.userId != null) {
          // Add roles
          if (member.roles != null) {
            memberRolesMap[member.userId!] = member.roles!.roles ?? [];
          }
          
          // Check if member is muted using the isMuted property directly
          mutedUsersMap[member.userId!] = member.isMuted ?? false;
        }
      }

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
        mutedUsers: mutedUsersMap,
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

  Future<void> toggleMuteUser(String userId) async {
    final isMuted = state.mutedUsers[userId] ?? false;
    
    if (isMuted) {
      await unmuteUser(userId);
    } else {
      await muteUser(userId);
    }
  }
  
  // Public method for muting a user
  Future<void> muteUser(String userId) async {
    try {
      // Mute user using the channel repository
      await AmityChatClient.newChannelRepository()
          .moderation(channel.channelId ?? "")
          .muteMembers([userId], millis: -1);
      
      // Update local state
      final updatedMutedUsers = Map<String, bool>.from(state.mutedUsers);
      updatedMutedUsers[userId] = true;
      emit(state.copyWith(mutedUsers: updatedMutedUsers));
      
      toastBloc?.add(const AmityToastShort(
        message: 'User muted.',
        icon: AmityToastIcon.success,
      ));
    } catch (e) {
      toastBloc?.add(const AmityToastShort(
        message: 'Failed to mute user. Please try again.',
        icon: AmityToastIcon.warning,
      ));
    }
  }
  
  // Public method for unmuting a user
  Future<void> unmuteUser(String userId) async {
    try {
      // Unmute user using the channel repository
      await AmityChatClient.newChannelRepository()
          .moderation(channel.channelId ?? "")
          .unmuteMembers([userId]);
      
      // Update local state
      final updatedMutedUsers = Map<String, bool>.from(state.mutedUsers);
      updatedMutedUsers[userId] = false;
      emit(state.copyWith(mutedUsers: updatedMutedUsers));
      
      toastBloc?.add(const AmityToastShort(
        message: 'User unmuted.',
        icon: AmityToastIcon.success,
      ));
  
    } catch (e) {
      toastBloc?.add(const AmityToastShort(
        message: 'Failed to unmute user. Please try again.',
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
