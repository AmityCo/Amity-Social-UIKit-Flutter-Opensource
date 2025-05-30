part of 'select_group_user_cubit.dart';

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
