part of 'add_group_member_cubit.dart';

class AddGroupMemberState extends Equatable {
  final List<AmityUser> users;
  final bool? hasMoreItems;
  final bool? isFetching;
  final List<AmityUser> selectedUsers;

  const AddGroupMemberState({
    this.users = const [],
    this.hasMoreItems,
    this.isFetching,
    this.selectedUsers = const [],
  });

  AddGroupMemberState copyWith({
    List<AmityUser>? users,
    bool? hasMoreItems,
    bool? isFetching,
    List<AmityUser>? selectedUsers,
  }) {
    return AddGroupMemberState(
      users: users ?? this.users,
      hasMoreItems: hasMoreItems ?? this.hasMoreItems,
      isFetching: isFetching ?? this.isFetching,
      selectedUsers: selectedUsers ?? this.selectedUsers,
    );
  }

  @override
  List<Object?> get props => [users, hasMoreItems, isFetching, selectedUsers];
}