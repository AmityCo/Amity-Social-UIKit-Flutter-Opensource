part of 'community_membership_page_bloc.dart';

// ignore: must_be_immutable
class CommunityMembershipPageState extends Equatable {
  List<AmityCommunityMember> members = [];
  List<AmityCommunityMember> moderators = [];
  bool isCurrentUserModerator = false;
  CommunityMembershipPageState();

  CommunityMembershipPageState copyWith({
    List<AmityCommunityMember>? members,
    List<AmityCommunityMember>? moderators,
    bool? isCurrentUserModerator,
  }) {
    return CommunityMembershipPageState()
      ..members = members ?? this.members
      ..moderators = moderators ?? this.moderators
      ..isCurrentUserModerator = isCurrentUserModerator ?? this.isCurrentUserModerator;
  } 

  @override
  List<Object> get props => [members, moderators, isCurrentUserModerator];
}
