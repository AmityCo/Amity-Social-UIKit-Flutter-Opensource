part of 'community_membership_page_bloc.dart';

// ignore: must_be_immutable
class CommunityMembershipPageState extends Equatable {
  List<AmityCommunityMember> members = [];
  List<AmityCommunityMember> moderators = [];
  bool isCurrentUserModerator = false;
  bool isPrivateCommunity = false;
  CommunityMembershipPageState();

  CommunityMembershipPageState copyWith({
    List<AmityCommunityMember>? members,
    List<AmityCommunityMember>? moderators,
    bool? isCurrentUserModerator,
    bool? isPrivateCommunity,
  }) {
    return CommunityMembershipPageState()
      ..members = members ?? this.members
      ..moderators = moderators ?? this.moderators
      ..isCurrentUserModerator = isCurrentUserModerator ?? this.isCurrentUserModerator
      ..isPrivateCommunity = isPrivateCommunity ?? this.isPrivateCommunity;
  }

  @override
  List<Object> get props => [members, moderators, isCurrentUserModerator, isPrivateCommunity];
}
