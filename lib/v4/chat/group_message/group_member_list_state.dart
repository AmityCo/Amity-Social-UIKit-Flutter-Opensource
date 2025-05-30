part of 'group_member_list_page.dart';

class GroupMemberListState extends Equatable {
  final List<AmityUser> members;
  final bool isLoading;
  final bool hasMoreMembers;
  final Map<String, List<String>> memberRoles; // User ID -> list of roles
  final List<String> currentUserRoles;
  // final String? error;
  final String activeTab; // 'all' or 'moderators'
  final bool isLoadingMore; // Track if we're loading more items
  final bool isLoadingMoreMember; // Track if we're loading more members specifically

  const GroupMemberListState({
    this.members = const [],
    this.isLoading = false,
    this.hasMoreMembers = false,
    this.memberRoles = const {},
    this.currentUserRoles = const [],
    // this.error,
    this.activeTab = 'all',
    this.isLoadingMore = false,
    this.isLoadingMoreMember = false,
  });

  GroupMemberListState copyWith({
    List<AmityUser>? members,
    bool? isLoading,
    bool? hasMoreMembers,
    Map<String, List<String>>? memberRoles,
    List<String>? currentUserRoles,
    // String? error,
    String? activeTab,
    bool? isLoadingMore,
    bool? isLoadingMoreMember,
  }) {
    return GroupMemberListState(
      members: members ?? this.members,
      isLoading: isLoading ?? this.isLoading,
      hasMoreMembers: hasMoreMembers ?? this.hasMoreMembers,
      memberRoles: memberRoles ?? this.memberRoles,
      currentUserRoles: currentUserRoles ?? this.currentUserRoles,
      // error: error ?? this.error,
      activeTab: activeTab ?? this.activeTab,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isLoadingMoreMember: isLoadingMoreMember ?? this.isLoadingMoreMember,
    );
  }

  @override
  List<Object?> get props => [
    members, 
    isLoading, 
    hasMoreMembers, 
    memberRoles,
    currentUserRoles,
    // error,
    activeTab,
    isLoadingMore,
    isLoadingMoreMember,
  ];
}
class SelectGroupUserState extends Equatable {
  final List<AmityUser> users;
  final bool? hasMoreItems;
  final bool? isFetching;
  final List<AmityUser> selectedUsers;

  const SelectGroupUserState({
    this.users = const [],
    this.hasMoreItems,
    this.isFetching,
    this.selectedUsers = const [],
  });

  SelectGroupUserState copyWith({
    List<AmityUser>? users,
    bool? hasMoreItems,
    bool? isFetching,
    List<AmityUser>? selectedUsers,
  }) {
    return SelectGroupUserState(
      users: users ?? this.users,
      hasMoreItems: hasMoreItems ?? this.hasMoreItems,
      isFetching: isFetching ?? this.isFetching,
      selectedUsers: selectedUsers ?? this.selectedUsers,
    );
  }

  @override
  List<Object?> get props => [users, hasMoreItems, isFetching, selectedUsers];
}
