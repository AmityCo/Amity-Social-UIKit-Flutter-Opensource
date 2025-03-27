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
  String get search_no_results => 'No results found';

  @override
  String get title_communities => 'Communities';

  @override
  String get title_users => 'Users';

  @override
  String get general_cancel => 'Cancel';

  @override
  String get general_featured => 'Featured';

  @override
  String get profile_edit => 'Edit Profile';

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
  String get post_delete => 'Delete Post';

  @override
  String get post_delete_description => 'This post will be permanently deleted.';

  @override
  String get post_delete_confirmation => 'Delete Post?';

  @override
  String get post_delete_confirmation_description => 'Do you want to Delete your post?';

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
  String get post_discard_description => 'The post will be permanently deleted. It cannot be undone.';

  @override
  String get post_write_comment => 'Write a comment...';

  @override
  String get poll_duration => 'Poll duration';

  @override
  String get poll_duration_hint => 'You can always close the poll before the set duration.';

  @override
  String get poll_custom_edn_date => 'Custom end date';

  @override
  String get poll_close => 'Close poll';

  @override
  String get poll_close_description => 'This poll is closed. You can no longer vote.';

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
  String get community_close => 'Close community?';

  @override
  String get community_close_description => 'All members will be removed from  the community. All posts, messages, reactions, and media shared in community will be deleted. This cannot be undone.';

  @override
  String get community_join => 'Join';

  @override
  String get community_leave => 'Leave community';

  @override
  String get community_leave_description => 'Leave the community. You will no longer be able to post and interact in this community.';

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
  String get community_public_description => 'Anyone can join, view and search the posts in this community.';

  @override
  String get community_private_description => 'Only members invited by the moderators can join, view, and search the posts in this community.';

  @override
  String get community_about => 'About';

  @override
  String get categories_title => 'Categories';

  @override
  String get category_hint => 'Select category';

  @override
  String get community_pending_posts => 'Pending Posts';

  @override
  String get commnuity_pending_post_reviewing => 'Your posts are pending for review';

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
  String get community_basic_info => 'Basic Info';

  @override
  String get community_discard_confirmation => 'Leave without finishing?';

  @override
  String get community_discard_description => 'Your progress won’t be saved and your community won’t be created.';

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
  String get settings_new_posts_description => 'Receive notifications when someone create new posts in this community.';

  @override
  String get settings_react_posts => 'React posts';

  @override
  String get settings_react_posts_description => 'Receive notifications when someone make a reaction to your posts in this community.';

  @override
  String get settings_react_comments => 'React comments';

  @override
  String get settings_react_comments_description => 'Receive notifications when someone like your comment in this community.';

  @override
  String get settings_new_comments => 'New comments';

  @override
  String get settings_new_comments_description => 'Receive notifications when someone comments on your post in this community.';

  @override
  String get settings_new_replies => 'Replies';

  @override
  String get settings_new_replies_description => 'Receive notifications when someone comment to your comments in this community.';

  @override
  String get settings_allow_stories_comments => 'Allow comments on community stories';

  @override
  String get settings_allow_stories_comments_description => 'Turn on to receive comments on stories in this community.';

  @override
  String get settings_new_stories => 'New stories';

  @override
  String get settings_new_stories_description => 'Receive notifications when someone creates a new story in this community.';

  @override
  String get settings_story_reactions => 'Story reactions';

  @override
  String get settings_story_reactions_description => 'Receive notifications when someone reacts to your story in this community.';

  @override
  String get settings_story_comments => 'Story comments';

  @override
  String get settings_story_comments_description => 'Receive notifications when someone comments on your story in this community.';

  @override
  String get settings_everyone => 'Everyone';

  @override
  String get settings_only_moderators => 'Only moderators';

  @override
  String get settings_privacy => 'Privacy';

  @override
  String get settings_permissions => 'Community permissions';

  @override
  String get settings_language => 'Language';

  @override
  String get settings_leave_confirmation => 'Leave without finishing?';

  @override
  String get settings_leave_description => 'Your changes that you made may not be saved.';

  @override
  String get settings_privacy_confirmation => 'Change community privacy settings?';

  @override
  String get settings_privacy_description => 'This community has globally featured posts. Changing the community from public to private will remove these posts from being featured globally.';

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
  String get general_reported => 'reported';

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
  String get post_edit_globally_featured => 'Edit globally featured post?';

  @override
  String get post_edit_globally_featured_description => 'The post you\'re editing has been featured globally. If you edit your post, it would need to be re-approved, and will no longer be globally featured.';

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
  String get error_leave_community_description => 'You’re the only moderator in this group. To leave community, nominate other members to moderator role';

  @override
  String get error_close_community => 'Unable to close community';

  @override
  String get error_close_community_description => 'Something went wrong. Please try again later.';

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
}
