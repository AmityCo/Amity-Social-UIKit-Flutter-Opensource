// ignore_for_file: use_build_context_synchronously

import 'package:amity_uikit_beta_service/v4/social/comment/comment_tray_behavior.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_membership/community_membership_page_behavior.dart';
import 'package:amity_uikit_beta_service/v4/social/community/profile/community_profile_page_behavior.dart';
import 'package:amity_uikit_beta_service/v4/social/globalfeed/global_feed_component_behavior.dart';
import 'package:amity_uikit_beta_service/v4/social/post/pending/pending_post_content_component_behavior.dart';
import 'package:amity_uikit_beta_service/v4/social/post/post_detail/post_content_component_behavior.dart';
import 'package:amity_uikit_beta_service/v4/social/user/follow/pending_requests/user_pending_follow_request_page_behavior.dart';
import 'package:amity_uikit_beta_service/v4/social/user/follow/user_relationship_page_behavior.dart';
import 'package:amity_uikit_beta_service/v4/social/user_search_result/user_search_result_behavior.dart';

class UIKitBehavior {
  // Singleton instance
  static final UIKitBehavior _instance = UIKitBehavior._internal();

  // Factory constructor to return the singleton instance
  factory UIKitBehavior() => _instance;

  // Private constructor for singleton
  UIKitBehavior._internal();

  // Static getter to access the instance
  static UIKitBehavior get instance => _instance;

  AmityGlobalFeedComponentBehavior globalFeedComponentBehavior =
      AmityGlobalFeedComponentBehavior();

  AmityPostContentComponentBehavior postContentComponentBehavior =
      AmityPostContentComponentBehavior();

  AmityPendingPostContentComponentBehavior pendingPostContentComponentBehavior =
      AmityPendingPostContentComponentBehavior();

  AmityCommentTrayBehavior commentTrayBehavior = AmityCommentTrayBehavior();

  AmityCommunityMembershipPageBehavior communityMembershipPageBehavior =
      AmityCommunityMembershipPageBehavior();

  AmityCommunityProfilePageBehavior communityProfilePageBehavior =
      AmityCommunityProfilePageBehavior();

  AmityUserSearchResultBehavior userSearchResultBehavior =
      AmityUserSearchResultBehavior();

  AmityUserPendingFollowRequestsPageBehavior
      userPendingFollowRequestsPageBehavior =
      AmityUserPendingFollowRequestsPageBehavior();

  AmityUserRelationshipPageBehavior userRelationshipPageBehavior =
      AmityUserRelationshipPageBehavior();
}
