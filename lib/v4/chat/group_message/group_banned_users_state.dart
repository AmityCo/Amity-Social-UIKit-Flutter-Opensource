part of 'group_banned_users_page.dart';

class GroupBannedUsersState extends Equatable {
  final List<AmityUser> bannedUsers;
  final bool isLoading;
  final bool hasMoreBannedUsers;
  final List<String> currentUserRoles;
  final String? error;
  final String searchQuery;

  const GroupBannedUsersState({
    this.bannedUsers = const [],
    this.isLoading = false,
    this.hasMoreBannedUsers = false,
    this.currentUserRoles = const [],
    this.error,
    this.searchQuery = '',
  });

  GroupBannedUsersState copyWith({
    List<AmityUser>? bannedUsers,
    bool? isLoading,
    bool? hasMoreBannedUsers,
    List<String>? currentUserRoles,
    String? error,
    String? searchQuery,
  }) {
    return GroupBannedUsersState(
      bannedUsers: bannedUsers ?? this.bannedUsers,
      isLoading: isLoading ?? this.isLoading,
      hasMoreBannedUsers: hasMoreBannedUsers ?? this.hasMoreBannedUsers,
      currentUserRoles: currentUserRoles ?? this.currentUserRoles,
      error: error ?? this.error,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
    bannedUsers, 
    isLoading, 
    hasMoreBannedUsers, 
    currentUserRoles,
    error,
    searchQuery
  ];
}