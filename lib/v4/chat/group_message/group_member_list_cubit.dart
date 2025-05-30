part of 'group_member_list_page.dart';

class GroupMemberListCubit extends Cubit<GroupMemberListState> {
  final AmityChannel channel;
  final AmityToastBloc? toastBloc;
  late ChannelMemberSearchLiveCollection memberLiveCollection;
  StreamSubscription<List<AmityChannelMember>>? _membersSubscription;
  StreamSubscription<bool>? _loadingSubscription;
  String _searchQuery = '';

  GroupMemberListCubit({required this.channel, this.toastBloc})
      : super(const GroupMemberListState()) {
    loadChannelMembers();
    _loadCurrentUserRoles();
  }

  Future<void> loadChannelMembers() async {
    emit(state.copyWith(isLoading: true, isLoadingMoreMember: false));
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
      if (state.members.isEmpty) {
        emit(state.copyWith(isLoading: isLoading));
      }
    });

    _membersSubscription =
        memberLiveCollection.getStreamController().stream.listen((members) async {
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
          users.removeWhere((user) => user.userId == currentUser.userId);
          users.insert(0, currentUser);
          
          // Add current user's roles to memberRolesMap
          if (myMembership.userId != null && myMembership.roles != null) {
            memberRolesMap[myMembership.userId!] = myMembership.roles!.roles ?? [];
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
            users.insert(0, currentUser);
          }
        }
      }
      emit(state.copyWith(
        members: users,
        hasMoreMembers: memberLiveCollection.hasNextPage(),
        memberRoles: memberRolesMap,
        isLoading: false,
        isLoadingMoreMember: false,
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
      emit(state.copyWith(isLoading: true, isLoadingMoreMember: false));

      emit(state.copyWith(activeTab: tabName));
      // Reset search query when changing tabs
      _searchQuery = '';
      // Reload members with new tab filter
      loadChannelMembers();
    }
  }

  void loadMoreMembers() {
    if (!state.isLoading && !state.isLoadingMoreMember) {
      emit(state.copyWith(isLoadingMoreMember: true));
      memberLiveCollection.loadNext();
    }
  }

  void searchMembers(String query) {
    _searchQuery = query;
    // Reset loading state when searching
    emit(state.copyWith(isLoadingMoreMember: false));
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

  @override
  Future<void> close() {
    _membersSubscription?.cancel();
    _loadingSubscription?.cancel();
    return super.close();
  }
}
