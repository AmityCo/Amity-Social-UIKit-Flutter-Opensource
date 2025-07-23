import 'package:amity_sdk/amity_sdk.dart';
import 'package:equatable/equatable.dart';
import 'package:amity_uikit_beta_service/v4/social/community/pending_request/amity_pending_request_page.dart';

class AmityPendingRequestState extends Equatable {
  final AmityCommunity community;
  final int pendingPostCount;
  final int joinRequestCount;
  final AmityPendingRequestPageTab activeTab;
  final bool isLoading;

  const AmityPendingRequestState({
    required this.community,
    this.pendingPostCount = 0,
    this.joinRequestCount = 0,
    required this.activeTab,
    this.isLoading = false,
  });

  List<String> get availableTabs {
    final List<String> tabs = [];
    
    // Add pending posts tab if enabled
    if (community.isPostReviewEnabled ?? false) {
      tabs.add("Pending Posts");
    }
    
    // Add join requests tab if enabled
    if (community.isPublic == false) {
      tabs.add("Join Requests");
    }
    
    return tabs;
  }

  bool get hasAvailableTabs => availableTabs.isNotEmpty;

  int get initialTabIndex {
    if (availableTabs.isEmpty) {
      return 0;
    }
    return activeTab.rawValue < availableTabs.length ? activeTab.rawValue : 0;
  }

  @override
  List<Object?> get props => [
    community, 
    pendingPostCount, 
    joinRequestCount, 
    activeTab,
    isLoading,
    availableTabs
  ];

  AmityPendingRequestState copyWith({
    AmityCommunity? community,
    int? pendingPostCount,
    int? joinRequestCount,
    AmityPendingRequestPageTab? activeTab,
    bool? isLoading,
  }) {
    return AmityPendingRequestState(
      community: community ?? this.community,
      pendingPostCount: pendingPostCount ?? this.pendingPostCount,
      joinRequestCount: joinRequestCount ?? this.joinRequestCount,
      activeTab: activeTab ?? this.activeTab,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
