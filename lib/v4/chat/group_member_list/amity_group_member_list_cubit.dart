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

  Future<void> addMembersToChannel(
    List<AmityUser> users, {
    required String successMessageSingle,
    required String successMessageMultiple,
    required String errorMessageSingle,
    required String errorMessageMultiple,
  }) async {
    if (users.isEmpty) return;
    List<String> userIds = users.map((user) => user.userId!).toList();

    try {
      await AmityChatClient.newChannelRepository().addMembers(
        channel.channelId ?? "",
        userIds,
      );

      toastBloc?.add(AmityToastShort(
          message: userIds.length > 1 ? successMessageMultiple : successMessageSingle,
          icon: AmityToastIcon.success));
      // Refresh the member list
      loadChannelMembers();
      // Refresh current user roles in case they were affected
      _loadCurrentUserRoles();
    } catch (e) {
      toastBloc?.add(AmityToastShort(
          message: userIds.length > 1
              ? errorMessageMultiple
              : errorMessageSingle,
          icon: AmityToastIcon.warning));
    }
  }

  Future<void> removeMember(String userId, {
    required String successMessage,
    required String errorMessage,
  }) async {
    try {
      await AmityChatClient.newChannelRepository()
          .removeMembers(channel.channelId ?? "", [userId]);

      // Refresh the member list

      toastBloc?.add(AmityToastShort(
          message: successMessage, icon: AmityToastIcon.success));
      loadChannelMembers();
      // Refresh current user roles in case they were affected
      _loadCurrentUserRoles();
    } catch (e) {
      toastBloc?.add(AmityToastShort(
          message: errorMessage,
          icon: AmityToastIcon.warning));
    }
  }

  Future<void> addModerator(String userId, {
    required String successMessage,
    required String errorMessage,
  }) async {
    try {
      await AmityChatClient.newChannelRepository()
          .moderation(channel.channelId ?? "")
          .addRole("channel-moderator", [userId]);

      // Show success toast
      toastBloc?.add(AmityToastShort(
          message: successMessage, icon: AmityToastIcon.success));

      // Refresh the member list
      loadChannelMembers();
      // Refresh current user roles in case they were affected
      _loadCurrentUserRoles();
    } catch (e) {
      // Show failure toast
      toastBloc?.add(AmityToastShort(
          message: errorMessage,
          icon: AmityToastIcon.warning));
    }
  }

  Future<void> removeModerator(String userId, {
    required String successMessage,
    required String errorMessage,
  }) async {
    try {
      await AmityChatClient.newChannelRepository()
          .moderation(channel.channelId ?? "")
          .removeRole("channel-moderator", [userId]);

      // Show success toast
      toastBloc?.add(AmityToastShort(
          message: successMessage, icon: AmityToastIcon.success));

      // Refresh the member list
      loadChannelMembers();
      // Refresh current user roles in case they were affected
      _loadCurrentUserRoles();
    } catch (e) {
      // Show failure toast
      toastBloc?.add(AmityToastShort(
          message: errorMessage,
          icon: AmityToastIcon.warning));
    }
  }

  Future<void> banUser(String userId, {
    required String successMessage,
    required String errorMessage,
  }) async {
    try {
      await AmityChatClient.newChannelRepository()
          .moderation(channel.channelId ?? "")
          .banMembers([userId]);

      // Refresh the member list
      loadChannelMembers();

      await Future.delayed(const Duration(milliseconds: 300));

      toastBloc?.add(AmityToastShort(
          message: successMessage, icon: AmityToastIcon.success));

      // Refresh current user roles in case they were affected
      _loadCurrentUserRoles();
    } catch (e) {
      toastBloc?.add(AmityToastShort(
          message: errorMessage,
          icon: AmityToastIcon.warning));
    }
  }

  Future<void> reportUser(AmityUser user, {
    required String unreportSuccessMessage,
    required String reportSuccessMessage,
    required String errorMessage,
  }) async {
    try {
      if (user.isFlaggedByMe) {
        // Unreport user
        await user.report().unflag();

        toastBloc?.add(AmityToastShort(
          message: unreportSuccessMessage,
          icon: AmityToastIcon.success,
        ));
      } else {
        // Report user
        await user.report().flag();

        toastBloc?.add(AmityToastShort(
          message: reportSuccessMessage,
          icon: AmityToastIcon.success,
        ));
      }

      // Add a small delay to ensure the operation completes
      await Future.delayed(const Duration(milliseconds: 300));

      // Refresh the member list to update the report status
      loadChannelMembers();
    } catch (e) {
      // Show failure toast
      toastBloc?.add(AmityToastShort(
        message: errorMessage,
        icon: AmityToastIcon.warning,
      ));
    }
  }

  Future<void> toggleMuteUser(
    String userId, {
    required String muteSuccessMessage,
    required String muteErrorMessage,
    required String unmuteSuccessMessage,
    required String unmuteErrorMessage,
  }) async {
    final isMuted = state.mutedUsers[userId] ?? false;
    
    if (isMuted) {
      await unmuteUser(
        userId,
        successMessage: unmuteSuccessMessage,
        errorMessage: unmuteErrorMessage,
      );
    } else {
      await muteUser(
        userId,
        successMessage: muteSuccessMessage,
        errorMessage: muteErrorMessage,
      );
    }
  }
  
  // Public method for muting a user
  Future<void> muteUser(String userId, {
    required String successMessage,
    required String errorMessage,
  }) async {
    try {
      // Mute user using the channel repository
      await AmityChatClient.newChannelRepository()
          .moderation(channel.channelId ?? "")
          .muteMembers([userId], millis: -1);
      
      // Update local state
      final updatedMutedUsers = Map<String, bool>.from(state.mutedUsers);
      updatedMutedUsers[userId] = true;
      emit(state.copyWith(mutedUsers: updatedMutedUsers));
      
      toastBloc?.add(AmityToastShort(
        message: successMessage,
        icon: AmityToastIcon.success,
      ));
    } catch (e) {
      toastBloc?.add(AmityToastShort(
        message: errorMessage,
        icon: AmityToastIcon.warning,
      ));
    }
  }
  
  // Public method for unmuting a user
  Future<void> unmuteUser(String userId, {
    required String successMessage,
    required String errorMessage,
  }) async {
    try {
      // Unmute user using the channel repository
      await AmityChatClient.newChannelRepository()
          .moderation(channel.channelId ?? "")
          .unmuteMembers([userId]);
      
      // Update local state
      final updatedMutedUsers = Map<String, bool>.from(state.mutedUsers);
      updatedMutedUsers[userId] = false;
      emit(state.copyWith(mutedUsers: updatedMutedUsers));
      
      toastBloc?.add(AmityToastShort(
        message: successMessage,
        icon: AmityToastIcon.success,
      ));
  
    } catch (e) {
      toastBloc?.add(AmityToastShort(
        message: errorMessage,
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
