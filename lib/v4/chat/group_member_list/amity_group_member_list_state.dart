part of 'amity_group_member_list_page.dart';

class AmityGroupMemberListState extends Equatable {
  final List<AmityUser> members;
  final bool isLoading;
  final bool hasMoreMembers;
  final Map<String, List<String>> memberRoles; // User ID -> list of roles
  final List<String> currentUserRoles;
  // final String? error;
  final String activeTab; // 'all' or 'moderators'

  const AmityGroupMemberListState({
    this.members = const [],
    this.isLoading = false,
    this.hasMoreMembers = false,
    this.memberRoles = const {},
    this.currentUserRoles = const [],
    // this.error,
    this.activeTab = 'all',
  });

  /// Computed property to check if current user is a moderator
  bool get isCurrentUserModerator =>
      currentUserRoles.contains('moderator') ||
      currentUserRoles.contains('channel-moderator');

  AmityGroupMemberListState copyWith({
    List<AmityUser>? members,
    bool? isLoading,
    bool? hasMoreMembers,
    Map<String, List<String>>? memberRoles,
    List<String>? currentUserRoles,
    // String? error,
    String? activeTab,
  }) {
    return AmityGroupMemberListState(
      members: members ?? this.members,
      isLoading: isLoading ?? this.isLoading,
      hasMoreMembers: hasMoreMembers ?? this.hasMoreMembers,
      memberRoles: memberRoles ?? this.memberRoles,
      currentUserRoles: currentUserRoles ?? this.currentUserRoles,
      // error: error ?? this.error,
      activeTab: activeTab ?? this.activeTab,
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
  ];
}
