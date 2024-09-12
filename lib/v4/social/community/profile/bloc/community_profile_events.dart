part of 'community_profile_bloc.dart';

abstract class CommunityProfileEvent extends Equatable {
  const CommunityProfileEvent();

  @override
  List<Object> get props => [];
}

class CommunityProfileEventRefresh extends CommunityProfileEvent {
  final String communityId;

  const CommunityProfileEventRefresh({required this.communityId});

  @override
  List<Object> get props => [communityId];
}

class CommunityProfileEventUpdated extends CommunityProfileEvent {
  final AmityCommunity community;

  const CommunityProfileEventUpdated({required this.community});

  @override
  List<Object> get props => [community];
}

class CommunityProfileEventExpanded extends CommunityProfileEvent { }

class CommunityProfileEventCollapsed extends CommunityProfileEvent { }

class CommunityProfileEventJoining extends CommunityProfileEvent {
  final String communityId;

  const CommunityProfileEventJoining({required this.communityId});

  @override
  List<Object> get props => [communityId];
 }

class CommunityProfileEventGetPendingPosts extends CommunityProfileEvent { }

class CommunityProfileEventTabSelected extends CommunityProfileEvent {
  final CommunityProfileTabIndex tab;

  const CommunityProfileEventTabSelected({required this.tab});

  @override
  List<Object> get props => [tab];
 }