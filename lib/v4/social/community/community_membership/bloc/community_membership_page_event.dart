part of 'community_membership_page_bloc.dart';

class CommunityMembershipPageEvent extends Equatable {
  const CommunityMembershipPageEvent();

  @override
  List<Object> get props => [];
}

class CommunityMembershipPageMemberLoadedEvent
    extends CommunityMembershipPageEvent {
  final List<AmityCommunityMember> members;
  const CommunityMembershipPageMemberLoadedEvent(this.members);

  @override
  List<Object> get props => [members];
}

class CommunityMembershipPageModeratorLoadedEvent
    extends CommunityMembershipPageEvent {
  final List<AmityCommunityMember> moderators;

  const CommunityMembershipPageModeratorLoadedEvent(this.moderators);

  @override
  List<Object> get props => [moderators];
}

class CommunityMembershipPageCurrentUserRolesEvent
    extends CommunityMembershipPageEvent {
  final List<String> roles;

  const CommunityMembershipPageCurrentUserRolesEvent(this.roles);

  @override
  List<Object> get props => [roles];
}

class CommunityMembershipPageAddMemberEvent
    extends CommunityMembershipPageEvent {
  final List<String> userIds;
  final AmityToastBloc toastBloc;
  final String successMessage;
  final String errorMessage;

  const CommunityMembershipPageAddMemberEvent(
    this.userIds,
    this.toastBloc, 
    this.successMessage,
    this.errorMessage,
  );

  @override
  List<Object> get props => [userIds, toastBloc];
}

class CommunityMembershipPageSearchMemberEvent
    extends CommunityMembershipPageEvent {
  final String keyword;

  const CommunityMembershipPageSearchMemberEvent(this.keyword);

  @override
  List<Object> get props => [keyword];
}

enum CommunityMembershipPageBottomSheetAction {
  promote,
  demote,
  remove,
  report,
  unreport
}

class CommunityMembershipPageBottomSheetEvent
    extends CommunityMembershipPageEvent {
  final AmityCommunityMember member;
  final CommunityMembershipPageBottomSheetAction action;
  final AmityToastBloc toastBloc;
  final String successMessage;
  final String errorMessage;

  const CommunityMembershipPageBottomSheetEvent(
    this.member,
    this.action,
    this.toastBloc, 
    this.successMessage,
    this.errorMessage,
  );

  @override
  List<Object> get props => [action, toastBloc];
}
