part of 'community_add_member_page_bloc.dart';

// ignore: must_be_immutable
class CommunityAddMemberPageState extends Equatable {
  List<AmityUser> users = [];
  List<AmityUser> selectedUsers = [];

  CommunityAddMemberPageState();

  CommunityAddMemberPageState copyWith({
    List<AmityUser>? users,
    List<AmityUser>? selectedUsers,
  }) {
    return CommunityAddMemberPageState()
      ..users = users ?? this.users
      ..selectedUsers = selectedUsers ?? this.selectedUsers;
  }

  @override
  List<Object> get props => [users, selectedUsers];
}
