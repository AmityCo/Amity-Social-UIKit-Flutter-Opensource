part of 'amity_banned_group_member_list_page.dart';

class AmityBannedGroupMemberListCubit extends Cubit<AmityBannedGroupMemberListState> {
  final AmityChannel channel;
  final AmityToastBloc? toastBloc;
  late ChannelMemberSearchLiveCollection memberLiveCollection;
  StreamSubscription<List<AmityChannelMember>>? _membersSubscription;
  StreamSubscription<bool>? _loadingSubscription;
  String _searchQuery = '';

  AmityBannedGroupMemberListCubit({required this.channel, this.toastBloc})
      : super(const AmityBannedGroupMemberListState()) {
    loadBannedUsers();
    _getCurrentUserRoles();
  }

  Future<void> _getCurrentUserRoles() async {
    try {
      final roles = await channel.getCurentUserRoles();
      emit(state.copyWith(currentUserRoles: roles));
    } catch (e) {
      // If there's an error, leave currentUserRoles as empty list
    }
  }

  Future<void> loadBannedUsers() async {
    emit(state.copyWith(isLoading: true));

    // Create live collection to get banned members
    memberLiveCollection = AmityChatClient.newChannelRepository()
        .membership(channel.channelId ?? "")
        .searchMembers(_searchQuery)
        .membershipFilter([
      AmityChannelMembership.BANNED
    ]) // Filter to get only banned members
        .getLiveCollection();

    _loadingSubscription?.cancel();
    _membersSubscription?.cancel();

    _loadingSubscription =
        memberLiveCollection.observeLoadingState().listen((isLoading) {
      emit(state.copyWith(isLoading: isLoading));
    });

    _membersSubscription =
        memberLiveCollection.getStreamController().stream.listen((members) {
      final users =
          members.map((member) => member.user).whereType<AmityUser>().toList();

      emit(state.copyWith(
        bannedUsers: users,
        hasMoreBannedUsers: memberLiveCollection.hasNextPage(),
        isLoading: false,
        searchQuery: _searchQuery,
      ));
    });

    memberLiveCollection.reset();
    memberLiveCollection.loadNext();
  }

  void loadMoreBannedUsers() {
    if (state.hasMoreBannedUsers && !state.isLoading) {
      memberLiveCollection.loadNext();
    }
  }

  void searchBannedUsers(String query) {
    _searchQuery = query;
    loadBannedUsers();
  }

  Future<void> unbanUser(String userId, {
    required String successMessage,
    required String errorMessage,
  }) async {
    try {
      await AmityChatClient.newChannelRepository()
          .moderation(channel.channelId ?? "")
          .unbanMembers([userId]);

      // Refresh the banned users list
      loadBannedUsers();

      // Add delay before showing success toast
      await Future.delayed(const Duration(milliseconds: 300));

      // Show success toast
      toastBloc?.add(AmityToastShort(
        message: successMessage,
        icon: AmityToastIcon.success,
      ));

      emit(state.copyWith(
        error: null,
      ));
    } catch (e) {
      // Show failure toast
      toastBloc?.add(AmityToastShort(
        message: errorMessage,
        icon: AmityToastIcon.warning,
      ));
      
      emit(state.copyWith(error: 'Failed to unban user: ${e.toString()}'));
    }
  }

  @override
  Future<void> close() {
    _membersSubscription?.cancel();
    _loadingSubscription?.cancel();
    return super.close();
  }
}
