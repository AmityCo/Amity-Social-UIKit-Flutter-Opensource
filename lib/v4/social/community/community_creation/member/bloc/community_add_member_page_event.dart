part of 'community_add_member_page_bloc.dart';

class CommunityAddMemberPageEvent extends Equatable {
  const CommunityAddMemberPageEvent();

  @override
  List<Object> get props => [];
}

class CommunityAddMemberPageUserLoadEvent extends CommunityAddMemberPageEvent {
  final List<AmityUser> users;

  const CommunityAddMemberPageUserLoadEvent(this.users);

  @override
  List<Object> get props => [users];
}

class CommunityAddMemberPageSearchUserEvent extends CommunityAddMemberPageEvent {
  final String keyword;

  const CommunityAddMemberPageSearchUserEvent(this.keyword);

  @override
  List<Object> get props => [keyword];
}

class CommunityAddMemberPageSelectUserEvent extends CommunityAddMemberPageEvent {
  final AmityUser user;

  const CommunityAddMemberPageSelectUserEvent(this.user);

  @override
  List<Object> get props => [user];
}
