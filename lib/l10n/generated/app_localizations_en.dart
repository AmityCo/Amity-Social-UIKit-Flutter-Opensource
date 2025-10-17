// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get community_title => 'Community';

  @override
  String get tab_newsfeed => 'Newsfeed';

  @override
  String get tab_explore => 'Explore';

  @override
  String get tab_my_communities => 'My Communities';

  @override
  String get global_search_hint => 'Search community and user';

  @override
  String get search_my_community_hint => 'Search my community';

  @override
  String get search_no_results => 'No results found';

  @override
  String get title_communities => 'Communities';

  @override
  String get title_users => 'Users';

  @override
  String get general_cancel => 'Cancel';

  @override
  String get general_ok => 'OK';

  @override
  String get general_confirm => 'Confirm';

  @override
  String get general_featured => 'Featured';

  @override
  String get profile_followers => 'Followers';

  @override
  String get profile_following => 'Following';

  @override
  String get profile_posts => 'Posts';

  @override
  String get post_create => 'Create Post';

  @override
  String get post_edit => 'Edit Post';

  @override
  String get post_create_hint => 'What\'s going on...';

  @override
  String get post_delete => 'Delete Post';

  @override
  String get post_delete_description =>
      'This post will be permanently deleted.';

  @override
  String get post_delete_confirmation => 'Delete Post?';

  @override
  String get post_delete_confirmation_description =>
      'Do you want to Delete your post?';

  @override
  String get post_report => 'Report post';

  @override
  String get post_unreport => 'Unreport post';

  @override
  String get post_like => 'Like';

  @override
  String get post_comment => 'Comment';

  @override
  String get post_share => 'Share';

  @override
  String get post_discard => 'Discard this post?';

  @override
  String get post_discard_description =>
      'The post will be permanently deleted. It cannot be undone.';

  @override
  String get post_write_comment => 'Write a comment...';

  @override
  String get poll_duration => 'Poll duration';

  @override
  String get poll_duration_hint =>
      'You can always close the poll before the set duration.';

  @override
  String get poll_custom_edn_date => 'Custom end date';

  @override
  String get poll_close => 'Close poll';

  @override
  String get poll_close_description =>
      'This poll is closed. You can no longer vote.';

  @override
  String get poll_vote => 'Vote';

  @override
  String get poll_results => 'See results';

  @override
  String get poll_back_to_vote => 'Back to vote';

  @override
  String poll_vote_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count votes',
      one: '1 vote',
    );
    return '$_temp0';
  }

  @override
  String poll_total_votes(int count, String plusSign) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Voted by $count$plusSign participants',
      one: 'Voted by 1 participant',
      zero: 'No votes',
    );
    return '$_temp0';
  }

  @override
  String poll_see_more_options(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'See $count more options',
      one: 'See 1 more option',
    );
    return '$_temp0';
  }

  @override
  String get poll_see_full_results => 'See Full Results';

  @override
  String get poll_voted => 'Voted by you';

  @override
  String get poll_and_you => ' and you';

  @override
  String get poll_remaining_time => 'left';

  @override
  String get poll_vote_error => 'Failed to vote poll. Please try again.';

  @override
  String get poll_ended => 'Ended';

  @override
  String get poll_single_choice => 'Select one option';

  @override
  String get poll_multiple_choice => 'Select one or more options';

  @override
  String poll_options_description(int minOptions) {
    return 'Poll must contain at least $minOptions options.';
  }

  @override
  String get poll_question => 'Poll question';

  @override
  String get poll_question_hint => 'What\'s your poll question?';

  @override
  String get comment_create_hint => 'Say something nice...';

  @override
  String get comment_reply => 'Reply';

  @override
  String get comment_reply_to => 'Replying to ';

  @override
  String comment_view_reply_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'View $count reply',
      one: 'View 1 reply',
    );
    return '$_temp0';
  }

  @override
  String get comment_report => 'Report comment';

  @override
  String get comment_unreport => 'Unreport comment';

  @override
  String get comment_reply_report => 'Report reply';

  @override
  String get comment_reply_unreport => 'Unreport reply';

  @override
  String get comment_edit => 'Edit comment';

  @override
  String get comment_reply_edit => 'Edit reply';

  @override
  String get comment_delete => 'Delete comment';

  @override
  String get comment_reply_delete => 'Delete reply';

  @override
  String comment_delete_description(String content) {
    return 'This $content will be permanently deleted.';
  }

  @override
  String get comment_create_error_ban_word =>
      'Your comment contains inappropriate word. Please review and delete it.';

  @override
  String get comment_create_error_story_deleted =>
      'This story is no longer available';

  @override
  String get community_create_success_message =>
      'Successfully created community.';

  @override
  String get community_create_error_message =>
      'Failed to create community. Please try again.';

  @override
  String get community_update_success_message =>
      'Successfully updated community.';

  @override
  String get community_update_error_message =>
      'Failed to save your community profile. Please try again.';

  @override
  String get community_leave_success_message =>
      'Successfully left the community.';

  @override
  String get community_leave_error_message => 'Failed to leave the community.';

  @override
  String get community_close_success_message =>
      'Successfully closed the community.';

  @override
  String get community_close_error_message => 'Failed to close the community.';

  @override
  String get community_close => 'Close community?';

  @override
  String get community_close_description =>
      'All members will be removed from the community. All posts, messages, reactions, and media shared in community will be deleted. This cannot be undone.';

  @override
  String get community_join => 'Join';

  @override
  String get community_joined => 'Joined';

  @override
  String get community_recommended_for_you => 'Recommended for you';

  @override
  String get community_trending_now => 'Trending now';

  @override
  String get community_placeholder_members => '1.2K members';

  @override
  String get community_leave => 'Leave community';

  @override
  String get community_leave_description =>
      'Leave the community. You will no longer be able to post and interact in this community.';

  @override
  String get community_create => 'Create Community';

  @override
  String get community_name => 'Community name';

  @override
  String get community_name_hint => 'Name your community';

  @override
  String get community_description_hint => 'Enter description';

  @override
  String get community_edit => 'Edit Community';

  @override
  String get community_members => 'Members';

  @override
  String get community_private => 'Private';

  @override
  String get community_public => 'Public';

  @override
  String get community_public_description =>
      'Anyone can join, view and search the posts in this community.';

  @override
  String get community_private_description =>
      'Only members invited by the moderators can join, view, and search the posts in this community.';

  @override
  String get community_about => 'About';

  @override
  String get categories_title => 'Categories';

  @override
  String get category_hint => 'Select category';

  @override
  String get category_select_title => 'Select Category';

  @override
  String get category_add => 'Add Category';

  @override
  String get community_pending_posts => 'Pending Posts';

  @override
  String get commnuity_pending_post_reviewing =>
      'Your posts are pending for review';

  @override
  String commnuity_pending_post_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count posts need approval',
      one: '$count post need approval',
    );
    return '$_temp0';
  }

  @override
  String community_pending_request_title(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Pending requests',
      one: 'Pending request',
    );
    return '$_temp0';
  }

  @override
  String community_pending_request_message(String displayCount, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'posts require',
      one: 'post requires',
    );
    return '$displayCount $_temp0 approval';
  }

  @override
  String get community_basic_info => 'Basic Info';

  @override
  String get community_discard_confirmation => 'Leave without finishing?';

  @override
  String get community_discard_description =>
      'Your progress won’t be saved and your community won’t be created.';

  @override
  String get message_send => 'Send';

  @override
  String get message_typing => 'is typing...';

  @override
  String get message_placeholder => 'Type a message...';

  @override
  String get settings_title => 'Settings';

  @override
  String get settings_notifications => 'Notifications';

  @override
  String get settings_new_posts => 'New posts';

  @override
  String get settings_new_posts_description =>
      'Receive notifications when someone create new posts in this community.';

  @override
  String get settings_react_posts => 'React posts';

  @override
  String get settings_react_posts_description =>
      'Receive notifications when someone make a reaction to your posts in this community.';

  @override
  String get settings_react_comments => 'React comments';

  @override
  String get settings_react_comments_description =>
      'Receive notifications when someone like your comment in this community.';

  @override
  String get settings_new_comments => 'New comments';

  @override
  String get settings_new_comments_description =>
      'Receive notifications when someone comments on your post in this community.';

  @override
  String get settings_new_replies => 'Replies';

  @override
  String get settings_new_replies_description =>
      'Receive notifications when someone comment to your comments in this community.';

  @override
  String get settings_allow_stories_comments =>
      'Allow comments on community stories';

  @override
  String get settings_allow_stories_comments_description =>
      'Turn on to receive comments on stories in this community.';

  @override
  String get settings_new_stories => 'New stories';

  @override
  String get settings_new_stories_description =>
      'Receive notifications when someone creates a new story in this community.';

  @override
  String get settings_story_reactions => 'Story reactions';

  @override
  String get settings_story_reactions_description =>
      'Receive notifications when someone reacts to your story in this community.';

  @override
  String get settings_story_comments => 'Story comments';

  @override
  String get settings_story_comments_description =>
      'Receive notifications when someone comments on your story in this community.';

  @override
  String get settings_everyone => 'Everyone';

  @override
  String get settings_only_moderators => 'Only moderators';

  @override
  String get settings_only_admins => 'Only admins can post';

  @override
  String get settings_privacy => 'Privacy';

  @override
  String get settings_permissions => 'Community permissions';

  @override
  String get settings_language => 'Language';

  @override
  String get settings_leave_confirmation => 'Leave without finishing?';

  @override
  String get settings_leave_description =>
      'Your changes that you made may not be saved.';

  @override
  String get settings_privacy_confirmation =>
      'Change community privacy settings?';

  @override
  String get settings_privacy_description =>
      'This community has globally featured posts. Changing the community from public to private will remove these posts from being featured globally.';

  @override
  String get general_add => 'Add';

  @override
  String get general_loading => 'Loading...';

  @override
  String get general_leave => 'Leave';

  @override
  String get general_error => 'Oops, something went wrong';

  @override
  String get general_edited => 'Edited';

  @override
  String get general_edited_suffix => ' (edited)';

  @override
  String get general_keep_editing => 'Keep editing';

  @override
  String get general_discard => 'Discard';

  @override
  String get general_moderator => 'Moderator';

  @override
  String get general_save => 'Save';

  @override
  String get general_delete => 'Delete';

  @override
  String get general_edit => 'Edit';

  @override
  String get general_close => 'Close';

  @override
  String get general_done => 'Done';

  @override
  String get general_post => 'Post';

  @override
  String get general_comments => 'Comments';

  @override
  String get general_story => 'Story';

  @override
  String get general_stories => 'Stories';

  @override
  String get general_poll => 'Poll';

  @override
  String get general_optional => 'Optional';

  @override
  String get general_on => 'On';

  @override
  String get general_off => 'Off';

  @override
  String get settings_allow_notification => 'Allow Notification';

  @override
  String get settings_allow_notification_description =>
      'Turn on to receive push notifications from this community.';

  @override
  String get general_reported => 'reported';

  @override
  String get general_unreported => 'unreported';

  @override
  String get general_see_more => '...See more';

  @override
  String get general_camera => 'Camera';

  @override
  String get general_photo => 'Photo';

  @override
  String get general_video => 'Video';

  @override
  String get general_posting => 'Posting';

  @override
  String get general_my_timeline => 'My Timeline';

  @override
  String get general_options => 'Options';

  @override
  String get general_go_back => 'Go back';

  @override
  String get post_unavailable_title => 'Something went wrong';

  @override
  String get post_unavailable_description =>
      'The content you\'re looking for is unavailable.';

  @override
  String get comment_deleted_message => 'This comment has been deleted';

  @override
  String get comment_reply_deleted_message => 'This reply has been deleted';

  @override
  String get post_edit_globally_featured => 'Edit globally featured post?';

  @override
  String get post_edit_globally_featured_description =>
      'The post you\'re editing has been featured globally. If you edit your post, it would need to be re-approved, and will no longer be globally featured.';

  @override
  String post_like_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count likes',
      one: '1 like',
    );
    return '$_temp0';
  }

  @override
  String post_comment_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count comments',
      one: '1 comment',
    );
    return '$_temp0';
  }

  @override
  String get post_reported => 'Post reported.';

  @override
  String get post_unreported => 'Post unreported.';

  @override
  String profile_followers_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count followers',
      one: '1 follower',
      zero: 'No followers',
    );
    return '$_temp0';
  }

  @override
  String community_members_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count members',
      one: '1 member',
      zero: 'No members',
    );
    return '$_temp0';
  }

  @override
  String profile_posts_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'posts',
      one: 'post',
    );
    return '$_temp0';
  }

  @override
  String profile_members_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'members',
      one: 'member',
    );
    return '$_temp0';
  }

  @override
  String get user_block => 'Block user';

  @override
  String get user_unblock => 'Unblock user';

  @override
  String get error_delete_post => 'Failed to delete post. Please try again.';

  @override
  String get error_leave_community => 'Unable to leave community';

  @override
  String get error_leave_community_description =>
      'You’re the only moderator in this group. To leave community, nominate other members to moderator role';

  @override
  String get error_close_community => 'Unable to close community';

  @override
  String get error_close_community_description =>
      'Something went wrong. Please try again later.';

  @override
  String get error_max_upload_reached => 'Maximum upload limit reached';

  @override
  String error_max_upload_image_reached_description(int maxUploads) {
    return 'You’ve reached the upload limit of $maxUploads images. Any additional images will not be saved.';
  }

  @override
  String error_max_upload_videos_reached_description(int maxUploads) {
    return 'You’ve reached the upload limit of $maxUploads videos. Any additional videos will not be saved.';
  }

  @override
  String get error_edit_post => 'Failed to edit post. Please try again.';

  @override
  String get error_create_post => 'Failed to create post. Please try again.';

  @override
  String error_max_poll_characters(int maxQuestionLength) {
    return 'Poll question cannot exceed $maxQuestionLength characters.';
  }

  @override
  String error_max_poll_option_characters(int maxQuestionLength) {
    return 'Poll option cannot exceed $maxQuestionLength characters.';
  }

  @override
  String get error_create_poll => 'Failed to create poll. Please try again.';

  @override
  String get error_message_too_long_title => 'Unable to send message';

  @override
  String get error_message_too_long_description =>
      'Your message is too long. Please shorten your message and try again.';

  @override
  String get user_profile_unknown_name => 'Unknown';

  @override
  String get user_profile_deleted_name => 'Deleted user';

  @override
  String get community_all_members => 'All members';

  @override
  String get community_moderators => 'Moderators';

  @override
  String get community_search_member_hint => 'Search member';

  @override
  String get community_promote_moderator => 'Promote to moderator';

  @override
  String get community_demote_member => 'Demote to member';

  @override
  String get community_remove_member => 'Remove from community';

  @override
  String get user_report => 'Report user';

  @override
  String get user_unreport => 'Unreport user';

  @override
  String get feed_no_videos => 'No videos yet';

  @override
  String get feed_no_photos => 'No photos yet';

  @override
  String get feed_no_pinned_posts => 'No pinned post yet';

  @override
  String get feed_no_posts => 'No posts yet';

  @override
  String get member_add => 'Add member';

  @override
  String get search_user_hint => 'Search user';

  @override
  String get profile_edit => 'Edit profile';

  @override
  String get profile_update_success => 'Successfully updated your profile!';

  @override
  String get profile_update_failed =>
      'Failed to save your profile. Please try again.';

  @override
  String get community_post_permission => 'Post permission';

  @override
  String get community_story_comments => 'Story comments';

  @override
  String get community_setting_close_label => 'Close community';

  @override
  String get community_setting_close_description =>
      'Closing this community will remove the community  page and all its content and comments.';

  @override
  String get community_post_permission_title_label =>
      'Who can post on this community';

  @override
  String get community_post_permission_description_label =>
      'You can control who can create posts in your community.';

  @override
  String get post_item_bottom_nonmember_label =>
      'Join community to interact with all posts';

  @override
  String get notification_turn_on_success => 'Notification turned on';

  @override
  String get notification_turn_on_error =>
      'Failed to turn on notification. Please try again.';

  @override
  String get notification_turn_off_success => 'Notification turned off';

  @override
  String get notification_turn_off_error =>
      'Failed to turn off notification. Please try again.';

  @override
  String get user_report_success => 'User reported.';

  @override
  String get user_report_error => 'Failed to report user. Please try again.';

  @override
  String get user_unreport_success => 'User unreported.';

  @override
  String get user_unreport_error =>
      'Failed to unreport user. Please try again.';

  @override
  String get user_block_success => 'User blocked.';

  @override
  String get user_block_error => 'Failed to block user. Please try again.';

  @override
  String get user_unblock_success => 'User unblocked.';

  @override
  String get user_unblock_error => 'Failed to unblock user. Please try again.';

  @override
  String get search_no_members_found => 'No members found';

  @override
  String get moderator_promotion_title => 'Moderator promotion';

  @override
  String get moderator_promotion_description =>
      'Are you sure you want to promote this member to Moderator? They will gain access to all moderator features.';

  @override
  String get moderator_promote_button => 'Promote';

  @override
  String get moderator_demotion_title => 'Moderator demotion';

  @override
  String get moderator_demotion_description =>
      'Are you sure you want to demote this Moderator? They will lose access to all moderator features.';

  @override
  String get moderator_demote_button => 'Demote';

  @override
  String get member_removal_confirm_title => 'Confirm removal';

  @override
  String get member_removal_confirm_description =>
      'Are you sure you want to remove this member from the group? They will be aware of their removal.';

  @override
  String get member_remove_button => 'Remove';

  @override
  String get user_ban_confirm_title => 'Confirm ban';

  @override
  String get user_ban_confirm_description =>
      'Are you sure you want to ban this user? They will be removed from the group and won\'t be able to find it or rejoin unless they are unbanned.';

  @override
  String get user_ban_button => 'Ban';

  @override
  String get member_add_success =>
      'Successfully added member to this community.';

  @override
  String get member_add_error => 'Failed to add member. Please try again.';

  @override
  String get moderator_promote_success => 'Successfully promoted to moderator.';

  @override
  String get moderator_promote_error =>
      'Failed to promote member. Please try again.';

  @override
  String get moderator_demote_success => 'Successfully demoted to member.';

  @override
  String get moderator_demote_error =>
      'Failed to demote member. Please try again.';

  @override
  String get member_remove_success => 'Member removed from this community.';

  @override
  String get member_remove_error =>
      'Failed to remove member. Please try again.';

  @override
  String get user_follow_success => 'User followed.';

  @override
  String get user_follow_error => 'Oops, something went wrong.';

  @override
  String get user_unfollow_success => 'User unfollowed.';

  @override
  String get user_unfollow_error => 'Oops, something went wrong.';

  @override
  String get post_target_selection_title => 'Post to';

  @override
  String get user_feed_blocked_title => 'You\'ve blocked this user';

  @override
  String get user_feed_blocked_description => 'Unblock to see their posts.';

  @override
  String get user_feed_private_title => 'This account is private';

  @override
  String get user_feed_private_description =>
      'Follow this user to see their posts.';

  @override
  String get timestamp_just_now => 'Just now';

  @override
  String get timestamp_now => 'now';

  @override
  String get chat_notification_turn_on => 'Turn on notifications';

  @override
  String get chat_notification_turn_off => 'Turn off notifications';

  @override
  String get chat_block_user_title => 'Block user?';

  @override
  String chat_block_user_description(String displayName) {
    return '$displayName won\'t be able to send you the message. They won\'t be notified that you\'ve blocked them.';
  }

  @override
  String get chat_unblock_user_title => 'Unblock user?';

  @override
  String chat_unblock_user_description(String displayName) {
    return '$displayName will now be able to send you the message. They won\'t be notified that you\'ve unblocked them.';
  }

  @override
  String get chat_message_photo => 'Send a photo';

  @override
  String get chat_message_video => 'Send a video';

  @override
  String get user_follow_request_new => 'New follow requests';

  @override
  String user_follow_request_approval(String count) {
    return '$count requests need your approval';
  }

  @override
  String get user_unfollow => 'Unfollow';

  @override
  String get user_follow_unable_title => 'Unable to follow this user';

  @override
  String get user_follow_unable_description =>
      'Oops! something went wrong. Please try again later.';

  @override
  String get user_follow => 'Follow';

  @override
  String get user_follow_cancel => 'Cancel Request';

  @override
  String get user_following => 'Following';

  @override
  String get user_block_confirm_title => 'Block user?';

  @override
  String user_block_confirm_description(String displayName) {
    return '$displayName won\'t be able to see posts and comments that you\'ve created. They won\'t be notified that you\'ve blocked them.';
  }

  @override
  String get user_block_confirm_button => 'Block';

  @override
  String get user_unblock_confirm_title => 'Unblock user?';

  @override
  String user_unblock_confirm_description(String displayName) {
    return '$displayName will now be able to see posts and comments that you\'ve created. They won\'t be notified that you\'ve unblocked them.';
  }

  @override
  String get user_unblock_confirm_button => 'Unblock';

  @override
  String get user_unfollow_confirm_title => 'Unfollow this user?';

  @override
  String get user_unfollow_confirm_description =>
      'If you change your mind, you\'ll have to request to follow them again.';

  @override
  String get user_unfollow_confirm_button => 'Unfollow';

  @override
  String get category_default_title => 'Category';

  @override
  String get community_empty_state => 'No community yet';

  @override
  String get community_pending_requests_title => 'Pending Requests';

  @override
  String get community_pending_requests_empty_title =>
      'No pending requests available';

  @override
  String get community_pending_requests_empty_description =>
      'Enable post review or join approval in community settings to manage requests.';

  @override
  String get community_join_requests_coming_soon =>
      'Join requests feature coming soon';

  @override
  String get community_pending_posts_warning =>
      'Decline pending post will permanently delete the selected post from community.';

  @override
  String get community_pending_posts_empty => 'No pending posts';

  @override
  String get community_pending_post_accept => 'Accept';

  @override
  String get community_pending_post_decline => 'Decline';

  @override
  String get community_pending_post_delete_success => 'Post deleted.';

  @override
  String get community_pending_post_delete_error =>
      'Failed to delete post. Please try again.';

  @override
  String get community_pending_post_approve_success => 'Post accepted.';

  @override
  String get community_pending_post_approve_error =>
      'Failed to accept post. This post has been reviewed by another moderator.';

  @override
  String get community_pending_post_decline_success => 'Post declined.';

  @override
  String get community_pending_post_decline_error =>
      'Failed to decline post. This post has been reviewed by another moderator.';

  @override
  String poll_option_hint(int optionNumber) {
    return 'Option $optionNumber';
  }

  @override
  String get poll_add_option => 'Add option';

  @override
  String get poll_multiple_selection_title => 'Multiple selection';

  @override
  String get poll_multiple_selection_description =>
      'Let participants vote more than one option.';

  @override
  String poll_ends_on(String endDate) {
    return 'Ends on $endDate';
  }

  @override
  String get poll_ends_on_label => 'Ends on';

  @override
  String get poll_select_date => 'Select Date';

  @override
  String get poll_select_time => 'Select Time';

  @override
  String poll_duration_days(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get poll_time_hour => 'Hour';

  @override
  String get poll_time_minute => 'Minute';

  @override
  String get profile_edit_display_name => 'Display Name';

  @override
  String get profile_edit_about => 'About';

  @override
  String get profile_edit_unsupported_image_title => 'Unsupported image type';

  @override
  String get profile_edit_unsupported_image_description =>
      'Please upload a PNG or JPG image.';

  @override
  String get profile_edit_inappropriate_image_title => 'Inappropriate image';

  @override
  String get profile_edit_inappropriate_image_description =>
      'Please choose a different image to upload.';

  @override
  String get profile_edit_unsaved_changes_title => 'Unsaved changes';

  @override
  String get profile_edit_unsaved_changes_description =>
      'Are you sure you want to discard the changes? They will be lost when you leave this page.';

  @override
  String get chat_title => 'Chat';

  @override
  String get chat_tab_all => 'All';

  @override
  String get chat_tab_direct => 'Direct';

  @override
  String get chat_tab_groups => 'Groups';

  @override
  String get chat_waiting_for_network => 'Waiting for network...';

  @override
  String get chat_direct_chat => 'Direct chat';

  @override
  String get chat_group_chat => 'Group chat';

  @override
  String get chat_archived => 'Archived';

  @override
  String get message_editing_message => 'Editing message';

  @override
  String get message_replying_yourself => 'yourself';

  @override
  String get message_replied_message => 'Replied message';

  @override
  String message_replying_to(String displayName) {
    return 'Replying to $displayName';
  }

  @override
  String get message_media => 'Media';

  @override
  String get chat_loading => 'Loading chat...';

  @override
  String get chat_blocked_message => 'You can\'t send messages to this person.';

  @override
  String get chat_notifications_disabled =>
      'You have disabled notifications for chat';

  @override
  String get chat_archive => 'Archive';

  @override
  String get chat_unarchive => 'Unarchive';

  @override
  String get chat_message_deleted => 'This message was deleted';

  @override
  String get chat_message_no_preview =>
      'No preview supported for this message type';

  @override
  String get chat_no_message_yet => 'No message yet';

  @override
  String get permission_camera_title => 'Allow access to your camera';

  @override
  String get permission_camera_detail =>
      'This allows the app to take photos and record videos from your device camera.';

  @override
  String get permission_microphone_title => 'Allow access to your microphone';

  @override
  String get permission_microphone_detail =>
      'This allows the app to record audio for videos from your device microphone.';

  @override
  String get permission_open_settings => 'Open settings';
}
