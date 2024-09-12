part of 'community_profile_bloc.dart';

enum CommunityProfileTabIndex { feed, pin }

class CommunityProfileState extends Equatable {
  const CommunityProfileState({
    required this.communityId,
    this.community,
    required this.scrollController,
    this.isExpanded = true,
    this.pendingPostCount = 0,
    this.selectedIndex = CommunityProfileTabIndex.feed,
    this.isJoined = true,
    this.isModerator = false,
  });

  final String communityId;
  final AmityCommunity? community;
  final ScrollController scrollController;
  final bool isExpanded;
  final int pendingPostCount;
  final CommunityProfileTabIndex selectedIndex;
  final bool isJoined;
  final bool isModerator;

  @override
  List<Object?> get props => [communityId, community, scrollController, isExpanded, pendingPostCount, selectedIndex, isJoined, isModerator];

  CommunityProfileState copyWith({
    String? communityId,
    AmityCommunity? community,
    ScrollController? scrollController,
    bool? isExpanded,
    int? pendingPostCount,
    CommunityProfileTabIndex? selectedIndex,
    bool? isJoined,
    bool? isModerator,
  }) {
    return CommunityProfileState(
      communityId: communityId ?? this.communityId,
      community: community ?? this.community,
      scrollController: scrollController ?? this.scrollController,
      isExpanded: isExpanded ?? this.isExpanded,
      pendingPostCount: pendingPostCount ?? this.pendingPostCount,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      isJoined: isJoined ?? this.isJoined,
      isModerator: isModerator ?? this.isModerator,
    );
  }
}
