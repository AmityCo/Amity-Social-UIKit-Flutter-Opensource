import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('es', 'CL'),
    Locale('es', 'CO'),
    Locale('es', 'MX'),
    Locale('es', 'PE'),
    Locale('pt'),
    Locale('pt', 'BR')
  ];

  /// Title for the homepage
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get community_title;

  /// Label for the newsfeed tab in the main navigation
  ///
  /// In en, this message translates to:
  /// **'Newsfeed'**
  String get tab_newsfeed;

  /// Label for the explore tab in the main navigation
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get tab_explore;

  /// Label for the my communities tab in the main navigation
  ///
  /// In en, this message translates to:
  /// **'My Communities'**
  String get tab_my_communities;

  /// Hint text for the search communities and users field on the homepage
  ///
  /// In en, this message translates to:
  /// **'Search community and user'**
  String get global_search_hint;

  /// Hint text for searching my communities
  ///
  /// In en, this message translates to:
  /// **'Search my community'**
  String get search_my_community_hint;

  /// Message displayed when no search results are found
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get search_no_results;

  /// Title for the communities section
  ///
  /// In en, this message translates to:
  /// **'Communities'**
  String get title_communities;

  /// Title for the users section
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get title_users;

  /// Label for the cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get general_cancel;

  /// Label for the OK button
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get general_ok;

  /// Label for the confirm button
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get general_confirm;

  /// Label for the featured posts
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get general_featured;

  /// Label for followers count
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get profile_followers;

  /// Label for following count
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get profile_following;

  /// Label for user posts
  ///
  /// In en, this message translates to:
  /// **'Posts'**
  String get profile_posts;

  /// Label for create post button
  ///
  /// In en, this message translates to:
  /// **'Create Post'**
  String get post_create;

  /// Label for edit post button
  ///
  /// In en, this message translates to:
  /// **'Edit Post'**
  String get post_edit;

  /// Hint text for post creation input field
  ///
  /// In en, this message translates to:
  /// **'What\'s going on...'**
  String get post_create_hint;

  /// Label for delete post button
  ///
  /// In en, this message translates to:
  /// **'Delete Post'**
  String get post_delete;

  /// Confirmation message for deleting a post
  ///
  /// In en, this message translates to:
  /// **'This post will be permanently deleted.'**
  String get post_delete_description;

  /// Confirmation title for deleting a post
  ///
  /// In en, this message translates to:
  /// **'Delete Post?'**
  String get post_delete_confirmation;

  /// Confirmation description for deleting a post
  ///
  /// In en, this message translates to:
  /// **'Do you want to Delete your post?'**
  String get post_delete_confirmation_description;

  /// Label for report post button
  ///
  /// In en, this message translates to:
  /// **'Report post'**
  String get post_report;

  /// Label for unreport post button
  ///
  /// In en, this message translates to:
  /// **'Unreport post'**
  String get post_unreport;

  /// Label for like action
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get post_like;

  /// Label for comment action
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get post_comment;

  /// Label for share action
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get post_share;

  /// Label for discard button
  ///
  /// In en, this message translates to:
  /// **'Discard this post?'**
  String get post_discard;

  /// Description for discard button
  ///
  /// In en, this message translates to:
  /// **'The post will be permanently deleted. It cannot be undone.'**
  String get post_discard_description;

  /// Placeholder for comment input
  ///
  /// In en, this message translates to:
  /// **'Write a comment...'**
  String get post_write_comment;

  /// Label for poll duration
  ///
  /// In en, this message translates to:
  /// **'Poll duration'**
  String get poll_duration;

  /// Hint text for poll duration select field
  ///
  /// In en, this message translates to:
  /// **'You can always close the poll before the set duration.'**
  String get poll_duration_hint;

  /// Label for custom end date
  ///
  /// In en, this message translates to:
  /// **'Custom end date'**
  String get poll_custom_edn_date;

  /// Label for close poll button
  ///
  /// In en, this message translates to:
  /// **'Close poll'**
  String get poll_close;

  /// Description for closed poll
  ///
  /// In en, this message translates to:
  /// **'This poll is closed. You can no longer vote.'**
  String get poll_close_description;

  /// Label for vote button
  ///
  /// In en, this message translates to:
  /// **'Vote'**
  String get poll_vote;

  /// Label for poll results
  ///
  /// In en, this message translates to:
  /// **'See results'**
  String get poll_results;

  /// Label for back to vote button
  ///
  /// In en, this message translates to:
  /// **'Back to vote'**
  String get poll_back_to_vote;

  /// Plural form for poll vote count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 vote} other{{count} votes}}'**
  String poll_vote_count(int count);

  /// Plural form for poll total votes
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No votes} =1{Voted by 1 participant} other{Voted by {count}{plusSign} participants}}'**
  String poll_total_votes(int count, String plusSign);

  /// Plural form for poll see more options
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{See 1 more option} other{See {count} more options}}'**
  String poll_see_more_options(int count);

  /// Label for see full results button
  ///
  /// In en, this message translates to:
  /// **'See Full Results'**
  String get poll_see_full_results;

  /// Label for voted poll
  ///
  /// In en, this message translates to:
  /// **'Voted by you'**
  String get poll_voted;

  /// Suffix for voted poll and you
  ///
  /// In en, this message translates to:
  /// **' and you'**
  String get poll_and_you;

  /// Label for remaining time in poll
  ///
  /// In en, this message translates to:
  /// **'left'**
  String get poll_remaining_time;

  /// Error message when voting fails
  ///
  /// In en, this message translates to:
  /// **'Failed to vote poll. Please try again.'**
  String get poll_vote_error;

  /// Label for ended poll
  ///
  /// In en, this message translates to:
  /// **'Ended'**
  String get poll_ended;

  /// Label for single choice poll
  ///
  /// In en, this message translates to:
  /// **'Select one option'**
  String get poll_single_choice;

  /// Label for multiple choice poll
  ///
  /// In en, this message translates to:
  /// **'Select one or more options'**
  String get poll_multiple_choice;

  /// Description for poll options
  ///
  /// In en, this message translates to:
  /// **'Poll must contain at least {minOptions} options.'**
  String poll_options_description(int minOptions);

  /// Label for poll question
  ///
  /// In en, this message translates to:
  /// **'Poll question'**
  String get poll_question;

  /// Hint text for poll question input
  ///
  /// In en, this message translates to:
  /// **'What\'s your poll question?'**
  String get poll_question_hint;

  /// Hint text for comment input
  ///
  /// In en, this message translates to:
  /// **'Say something nice...'**
  String get comment_create_hint;

  /// Label for reply button
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get comment_reply;

  /// Label for reply to comment
  ///
  /// In en, this message translates to:
  /// **'Replying to '**
  String get comment_reply_to;

  /// Plural form for post comment count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{View 1 reply} other{View {count} reply}}'**
  String comment_view_reply_count(int count);

  /// Label for report comment button
  ///
  /// In en, this message translates to:
  /// **'Report comment'**
  String get comment_report;

  /// Label for unreport comment button
  ///
  /// In en, this message translates to:
  /// **'Unreport comment'**
  String get comment_unreport;

  /// Label for report reply button
  ///
  /// In en, this message translates to:
  /// **'Report reply'**
  String get comment_reply_report;

  /// Label for unreport reply button
  ///
  /// In en, this message translates to:
  /// **'Unreport reply'**
  String get comment_reply_unreport;

  /// Label for edit comment button
  ///
  /// In en, this message translates to:
  /// **'Edit comment'**
  String get comment_edit;

  /// Label for edit reply button
  ///
  /// In en, this message translates to:
  /// **'Edit reply'**
  String get comment_reply_edit;

  /// Label for delete comment button
  ///
  /// In en, this message translates to:
  /// **'Delete comment'**
  String get comment_delete;

  /// Label for delete reply button
  ///
  /// In en, this message translates to:
  /// **'Delete reply'**
  String get comment_reply_delete;

  /// Confirmation message for deleting a comment
  ///
  /// In en, this message translates to:
  /// **'This {content} will be permanently deleted.'**
  String comment_delete_description(String content);

  /// Toast message for comment creation with banned word
  ///
  /// In en, this message translates to:
  /// **'Your comment contains inappropriate word. Please review and delete it.'**
  String get comment_create_error_ban_word;

  /// Toast message for comment creation
  ///
  /// In en, this message translates to:
  /// **'This story is no longer available'**
  String get comment_create_error_story_deleted;

  /// Toast message for community creation success
  ///
  /// In en, this message translates to:
  /// **'Successfully created community.'**
  String get community_create_success_message;

  /// Toast message for community creation failure
  ///
  /// In en, this message translates to:
  /// **'Failed to create community. Please try again.'**
  String get community_create_error_message;

  /// Toast message for community update success
  ///
  /// In en, this message translates to:
  /// **'Successfully updated community.'**
  String get community_update_success_message;

  /// Toast message for community update failure
  ///
  /// In en, this message translates to:
  /// **'Failed to save your community profile. Please try again.'**
  String get community_update_error_message;

  /// Toast message for community leave success
  ///
  /// In en, this message translates to:
  /// **'Successfully left the community.'**
  String get community_leave_success_message;

  /// Toast message for community leave error
  ///
  /// In en, this message translates to:
  /// **'Failed to leave the community.'**
  String get community_leave_error_message;

  /// Toast message for community close success
  ///
  /// In en, this message translates to:
  /// **'Successfully closed the community.'**
  String get community_close_success_message;

  /// Toast message for community close error
  ///
  /// In en, this message translates to:
  /// **'Failed to close the community.'**
  String get community_close_error_message;

  /// Label for close button
  ///
  /// In en, this message translates to:
  /// **'Close community?'**
  String get community_close;

  /// Confirmation message for closing a community
  ///
  /// In en, this message translates to:
  /// **'All members will be removed from the community. All posts, messages, reactions, and media shared in community will be deleted. This cannot be undone.'**
  String get community_close_description;

  /// Label for join community button
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get community_join;

  /// Label for joined community status
  ///
  /// In en, this message translates to:
  /// **'Joined'**
  String get community_joined;

  /// Section title for recommended communities
  ///
  /// In en, this message translates to:
  /// **'Recommended for you'**
  String get community_recommended_for_you;

  /// Section title for trending communities
  ///
  /// In en, this message translates to:
  /// **'Trending now'**
  String get community_trending_now;

  /// Placeholder text for community members count in recommended communities
  ///
  /// In en, this message translates to:
  /// **'1.2K members'**
  String get community_placeholder_members;

  /// Label for leave community button
  ///
  /// In en, this message translates to:
  /// **'Leave community'**
  String get community_leave;

  /// Confirmation message for leaving a community
  ///
  /// In en, this message translates to:
  /// **'Leave the community. You will no longer be able to post and interact in this community.'**
  String get community_leave_description;

  /// Label for create community button
  ///
  /// In en, this message translates to:
  /// **'Create Community'**
  String get community_create;

  /// Label for community name
  ///
  /// In en, this message translates to:
  /// **'Community name'**
  String get community_name;

  /// Hint text for community name input
  ///
  /// In en, this message translates to:
  /// **'Name your community'**
  String get community_name_hint;

  /// Hint text for community description input
  ///
  /// In en, this message translates to:
  /// **'Enter description'**
  String get community_description_hint;

  /// Label for edit community button
  ///
  /// In en, this message translates to:
  /// **'Edit Community'**
  String get community_edit;

  /// Label for community members
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get community_members;

  /// Label for private community type
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get community_private;

  /// Label for public community type
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get community_public;

  /// Description for public community type
  ///
  /// In en, this message translates to:
  /// **'Anyone can join, view and search the posts in this community.'**
  String get community_public_description;

  /// Description for private community type
  ///
  /// In en, this message translates to:
  /// **'Only members invited by the moderators can join, view, and search the posts in this community.'**
  String get community_private_description;

  /// Label for community about section
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get community_about;

  /// Title for categories section
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories_title;

  /// Hint text for category select field
  ///
  /// In en, this message translates to:
  /// **'Select category'**
  String get category_hint;

  /// Title for category selection page
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get category_select_title;

  /// Label for add category button
  ///
  /// In en, this message translates to:
  /// **'Add Category'**
  String get category_add;

  /// Label for pending posts section
  ///
  /// In en, this message translates to:
  /// **'Pending Posts'**
  String get community_pending_posts;

  /// Label for reviewing pending post
  ///
  /// In en, this message translates to:
  /// **'Your posts are pending for review'**
  String get commnuity_pending_post_reviewing;

  /// Plural form for pending post count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} post need approval} other{{count} posts need approval}}'**
  String commnuity_pending_post_count(int count);

  /// Title for pending request/requests
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Pending request} other{Pending requests}}'**
  String community_pending_request_title(int count);

  /// Message for pending request showing count and plural forms
  ///
  /// In en, this message translates to:
  /// **'{displayCount} {count, plural, =1{post requires} other{posts require}} approval'**
  String community_pending_request_message(String displayCount, int count);

  /// Label for basic info section
  ///
  /// In en, this message translates to:
  /// **'Basic Info'**
  String get community_basic_info;

  /// Label for discard changes confirmation
  ///
  /// In en, this message translates to:
  /// **'Leave without finishing?'**
  String get community_discard_confirmation;

  /// Description for discard changes confirmation
  ///
  /// In en, this message translates to:
  /// **'Your progress won’t be saved and your community won’t be created.'**
  String get community_discard_description;

  /// Label for send message button
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get message_send;

  /// Label for typing indicator
  ///
  /// In en, this message translates to:
  /// **'is typing...'**
  String get message_typing;

  /// Placeholder for message input
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get message_placeholder;

  /// Text shown for deleted messages
  ///
  /// In en, this message translates to:
  /// **'This message was deleted'**
  String get message_deleted;

  /// Error message when message fails to send
  ///
  /// In en, this message translates to:
  /// **'Failed to send message.'**
  String get message_failed_to_send;

  /// Reply text when user replies to their own message
  ///
  /// In en, this message translates to:
  /// **'You replied to yourself'**
  String get message_reply_you_to_yourself;

  /// Reply text when someone replies to your message
  ///
  /// In en, this message translates to:
  /// **'Replied to you'**
  String get message_reply_to_you;

  /// Reply text when you reply to someone else
  ///
  /// In en, this message translates to:
  /// **'You replied'**
  String get message_reply_you;

  /// Reply text when someone replies to their own message
  ///
  /// In en, this message translates to:
  /// **'Replied to themself'**
  String get message_reply_to_themself;

  /// Reply text when you replied to a now-deleted message
  ///
  /// In en, this message translates to:
  /// **'You replied to deleted message'**
  String get message_reply_you_to_deleted;

  /// Reply text when someone replied to a deleted message
  ///
  /// In en, this message translates to:
  /// **'Replied to deleted message'**
  String get message_reply_to_deleted;

  /// Fallback text for unknown user display name
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get message_unknown_user;

  /// Title for settings screen
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_title;

  /// Label for notifications settings
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settings_notifications;

  /// Label for new posts settings
  ///
  /// In en, this message translates to:
  /// **'New posts'**
  String get settings_new_posts;

  /// Description for new posts settings
  ///
  /// In en, this message translates to:
  /// **'Receive notifications when someone create new posts in this community.'**
  String get settings_new_posts_description;

  /// Label for react to posts settings
  ///
  /// In en, this message translates to:
  /// **'React posts'**
  String get settings_react_posts;

  /// Description for react to posts settings
  ///
  /// In en, this message translates to:
  /// **'Receive notifications when someone make a reaction to your posts in this community.'**
  String get settings_react_posts_description;

  /// Label for react to comments settings
  ///
  /// In en, this message translates to:
  /// **'React comments'**
  String get settings_react_comments;

  /// Description for react to comments settings
  ///
  /// In en, this message translates to:
  /// **'Receive notifications when someone like your comment in this community.'**
  String get settings_react_comments_description;

  /// Label for new comments settings
  ///
  /// In en, this message translates to:
  /// **'New comments'**
  String get settings_new_comments;

  /// Description for new comments settings
  ///
  /// In en, this message translates to:
  /// **'Receive notifications when someone comments on your post in this community.'**
  String get settings_new_comments_description;

  /// Label for new replies settings
  ///
  /// In en, this message translates to:
  /// **'Replies'**
  String get settings_new_replies;

  /// Description for new replies settings
  ///
  /// In en, this message translates to:
  /// **'Receive notifications when someone comment to your comments in this community.'**
  String get settings_new_replies_description;

  /// Label for allow comments on stories settings
  ///
  /// In en, this message translates to:
  /// **'Allow comments on community stories'**
  String get settings_allow_stories_comments;

  /// Description for allow comments on stories settings
  ///
  /// In en, this message translates to:
  /// **'Turn on to receive comments on stories in this community.'**
  String get settings_allow_stories_comments_description;

  /// Label for new stories settings
  ///
  /// In en, this message translates to:
  /// **'New stories'**
  String get settings_new_stories;

  /// Description for new stories settings
  ///
  /// In en, this message translates to:
  /// **'Receive notifications when someone creates a new story in this community.'**
  String get settings_new_stories_description;

  /// Label for story reactions settings
  ///
  /// In en, this message translates to:
  /// **'Story reactions'**
  String get settings_story_reactions;

  /// Description for story reactions settings
  ///
  /// In en, this message translates to:
  /// **'Receive notifications when someone reacts to your story in this community.'**
  String get settings_story_reactions_description;

  /// Label for story comments settings
  ///
  /// In en, this message translates to:
  /// **'Story comments'**
  String get settings_story_comments;

  /// Description for story comments settings
  ///
  /// In en, this message translates to:
  /// **'Receive notifications when someone comments on your story in this community.'**
  String get settings_story_comments_description;

  /// Label for everyone permission option
  ///
  /// In en, this message translates to:
  /// **'Everyone'**
  String get settings_everyone;

  /// Label for moderators-only permission option
  ///
  /// In en, this message translates to:
  /// **'Only moderators'**
  String get settings_only_moderators;

  /// Label for only admins can post setting
  ///
  /// In en, this message translates to:
  /// **'Only admins can post'**
  String get settings_only_admins;

  /// Label for privacy settings
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get settings_privacy;

  /// Label for permissions settings
  ///
  /// In en, this message translates to:
  /// **'Community permissions'**
  String get settings_permissions;

  /// Label for language settings
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settings_language;

  /// Label for confirmation settings
  ///
  /// In en, this message translates to:
  /// **'Leave without finishing?'**
  String get settings_leave_confirmation;

  /// Description for confirmation settings
  ///
  /// In en, this message translates to:
  /// **'Your changes that you made may not be saved.'**
  String get settings_leave_description;

  /// Label for privacy confirmation settings
  ///
  /// In en, this message translates to:
  /// **'Change community privacy settings?'**
  String get settings_privacy_confirmation;

  /// Description for privacy confirmation settings
  ///
  /// In en, this message translates to:
  /// **'This community has globally featured posts. Changing the community from public to private will remove these posts from being featured globally.'**
  String get settings_privacy_description;

  /// Label for add button
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get general_add;

  /// Label for loading states
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get general_loading;

  /// Label for leave button
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get general_leave;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'Oops, something went wrong'**
  String get general_error;

  /// Label for edited content
  ///
  /// In en, this message translates to:
  /// **'Edited'**
  String get general_edited;

  /// Suffix for edited post
  ///
  /// In en, this message translates to:
  /// **' (edited)'**
  String get general_edited_suffix;

  /// Label for keep editing button
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get general_keep_editing;

  /// Label for discard button
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get general_discard;

  /// Label for moderator role
  ///
  /// In en, this message translates to:
  /// **'Moderator'**
  String get general_moderator;

  /// Button text to save changes
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get general_save;

  /// Label for delete button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get general_delete;

  /// Label for edit button
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get general_edit;

  /// Label for close button
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get general_close;

  /// Label for done button
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get general_done;

  /// Label for post button
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get general_post;

  /// Label for comments button
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get general_comments;

  /// Label for story button
  ///
  /// In en, this message translates to:
  /// **'Story'**
  String get general_story;

  /// Label for stories button
  ///
  /// In en, this message translates to:
  /// **'Stories'**
  String get general_stories;

  /// Label for poll button
  ///
  /// In en, this message translates to:
  /// **'Poll'**
  String get general_poll;

  /// Label for optional fields
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get general_optional;

  /// Label indicating a setting is enabled
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get general_on;

  /// Label indicating a setting is disabled
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get general_off;

  /// Label for allow notification toggle
  ///
  /// In en, this message translates to:
  /// **'Allow Notification'**
  String get settings_allow_notification;

  /// Description for allow notification setting
  ///
  /// In en, this message translates to:
  /// **'Turn on to receive push notifications from this community.'**
  String get settings_allow_notification_description;

  /// Label for reported content
  ///
  /// In en, this message translates to:
  /// **'reported'**
  String get general_reported;

  /// Label for unreported content
  ///
  /// In en, this message translates to:
  /// **'unreported'**
  String get general_unreported;

  /// Label for see more button
  ///
  /// In en, this message translates to:
  /// **'...See more'**
  String get general_see_more;

  /// Label for camera option in media picker
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get general_camera;

  /// Label for photo/gallery option in media picker
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get general_photo;

  /// Label for video button
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get general_video;

  /// Label for posting states
  ///
  /// In en, this message translates to:
  /// **'Posting'**
  String get general_posting;

  /// Label for my timeline button
  ///
  /// In en, this message translates to:
  /// **'My Timeline'**
  String get general_my_timeline;

  /// Label for options button
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get general_options;

  /// Label for go back button
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get general_go_back;

  /// Title for post unavailable error page
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get post_unavailable_title;

  /// Description for post unavailable error page
  ///
  /// In en, this message translates to:
  /// **'The content you\'re looking for is unavailable.'**
  String get post_unavailable_description;

  /// Message shown for deleted comments
  ///
  /// In en, this message translates to:
  /// **'This comment has been deleted'**
  String get comment_deleted_message;

  /// Message shown for deleted reply comments
  ///
  /// In en, this message translates to:
  /// **'This reply has been deleted'**
  String get comment_reply_deleted_message;

  /// Title for globally featured post
  ///
  /// In en, this message translates to:
  /// **'Edit globally featured post?'**
  String get post_edit_globally_featured;

  /// Description for globally featured post
  ///
  /// In en, this message translates to:
  /// **'The post you\'re editing has been featured globally. If you edit your post, it would need to be re-approved, and will no longer be globally featured.'**
  String get post_edit_globally_featured_description;

  /// Plural form for post like count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 like} other{{count} likes}}'**
  String post_like_count(int count);

  /// Plural form for post comment count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 comment} other{{count} comments}}'**
  String post_comment_count(int count);

  /// Label for reported post
  ///
  /// In en, this message translates to:
  /// **'Post reported.'**
  String get post_reported;

  /// Label for unreported post
  ///
  /// In en, this message translates to:
  /// **'Post unreported.'**
  String get post_unreported;

  /// Plural form for profile followers count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No followers} =1{1 follower} other{{count} followers}}'**
  String profile_followers_count(int count);

  /// Plural form for community members count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No members} =1{1 member} other{{count} members}}'**
  String community_members_count(int count);

  /// Plural form for user posts count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{post} other{posts}}'**
  String profile_posts_count(int count);

  /// Plural form for member count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{member} other{members}}'**
  String profile_members_count(int count);

  /// Community story comments setting option
  ///
  /// In en, this message translates to:
  /// **'Block user'**
  String get user_block;

  /// Label for unblock user button
  ///
  /// In en, this message translates to:
  /// **'Unblock user'**
  String get user_unblock;

  /// Error message when deleting a post fails
  ///
  /// In en, this message translates to:
  /// **'Failed to delete post. Please try again.'**
  String get error_delete_post;

  /// Error message title when leaving a community fails
  ///
  /// In en, this message translates to:
  /// **'Unable to leave community'**
  String get error_leave_community;

  /// Error message description when leaving a community fails
  ///
  /// In en, this message translates to:
  /// **'You’re the only moderator in this group. To leave community, nominate other members to moderator role'**
  String get error_leave_community_description;

  /// Error message title when closing a community fails
  ///
  /// In en, this message translates to:
  /// **'Unable to close community'**
  String get error_close_community;

  /// Error message description when closing a community fails
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again later.'**
  String get error_close_community_description;

  /// Error message when maximum upload limit is reached
  ///
  /// In en, this message translates to:
  /// **'Maximum upload limit reached'**
  String get error_max_upload_reached;

  /// Error message description when maximum upload images limit is reached
  ///
  /// In en, this message translates to:
  /// **'You’ve reached the upload limit of {maxUploads} images. Any additional images will not be saved.'**
  String error_max_upload_image_reached_description(int maxUploads);

  /// Error message description when maximum upload videos limit is reached
  ///
  /// In en, this message translates to:
  /// **'You’ve reached the upload limit of {maxUploads} videos. Any additional videos will not be saved.'**
  String error_max_upload_videos_reached_description(int maxUploads);

  /// Error message when editing a post fails
  ///
  /// In en, this message translates to:
  /// **'Failed to edit post. Please try again.'**
  String get error_edit_post;

  /// Error message when creating a post fails
  ///
  /// In en, this message translates to:
  /// **'Failed to create post. Please try again.'**
  String get error_create_post;

  /// Error message when poll question exceeds maximum characters
  ///
  /// In en, this message translates to:
  /// **'Poll question cannot exceed {maxQuestionLength} characters.'**
  String error_max_poll_characters(int maxQuestionLength);

  /// Error message when poll option exceeds maximum characters
  ///
  /// In en, this message translates to:
  /// **'Poll option cannot exceed {maxQuestionLength} characters.'**
  String error_max_poll_option_characters(int maxQuestionLength);

  /// Error message when creating a poll fails
  ///
  /// In en, this message translates to:
  /// **'Failed to create poll. Please try again.'**
  String get error_create_poll;

  /// Error message when user selects a poll end time that is in the past or current moment
  ///
  /// In en, this message translates to:
  /// **'Poll end time must be in the future. Please select a valid date and time.'**
  String get error_poll_end_time_must_be_future;

  /// Title for error dialog when message exceeds character limit
  ///
  /// In en, this message translates to:
  /// **'Unable to send message'**
  String get error_message_too_long_title;

  /// Description for error dialog when message exceeds character limit
  ///
  /// In en, this message translates to:
  /// **'Your message is too long. Please shorten your message and try again.'**
  String get error_message_too_long_description;

  /// Fallback display name for users with no display name
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get user_profile_unknown_name;

  /// Display name for deleted users
  ///
  /// In en, this message translates to:
  /// **'Deleted user'**
  String get user_profile_deleted_name;

  /// Tab label for all members in community membership page
  ///
  /// In en, this message translates to:
  /// **'All members'**
  String get community_all_members;

  /// Tab label for moderators in community membership page
  ///
  /// In en, this message translates to:
  /// **'Moderators'**
  String get community_moderators;

  /// Hint text for member search field
  ///
  /// In en, this message translates to:
  /// **'Search member'**
  String get community_search_member_hint;

  /// Action to promote a member to moderator role
  ///
  /// In en, this message translates to:
  /// **'Promote to moderator'**
  String get community_promote_moderator;

  /// Action to demote a moderator to member role
  ///
  /// In en, this message translates to:
  /// **'Demote to member'**
  String get community_demote_member;

  /// Action to remove a member from the community
  ///
  /// In en, this message translates to:
  /// **'Remove from community'**
  String get community_remove_member;

  /// Action to report a user
  ///
  /// In en, this message translates to:
  /// **'Report user'**
  String get user_report;

  /// Action to unreport a user
  ///
  /// In en, this message translates to:
  /// **'Unreport user'**
  String get user_unreport;

  /// Empty state message when there are no videos in the feed
  ///
  /// In en, this message translates to:
  /// **'No videos yet'**
  String get feed_no_videos;

  /// Empty state message when there are no photos in the feed
  ///
  /// In en, this message translates to:
  /// **'No photos yet'**
  String get feed_no_photos;

  /// Empty state message when there are no pinned posts in the community
  ///
  /// In en, this message translates to:
  /// **'No pinned post yet'**
  String get feed_no_pinned_posts;

  /// Empty state message when there are no posts in the community feed
  ///
  /// In en, this message translates to:
  /// **'No posts yet'**
  String get feed_no_posts;

  /// Button text and title for adding members
  ///
  /// In en, this message translates to:
  /// **'Add member'**
  String get member_add;

  /// Hint text for searching users
  ///
  /// In en, this message translates to:
  /// **'Search user'**
  String get search_user_hint;

  /// Button text for editing user profile
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get profile_edit;

  /// Success message when profile is updated
  ///
  /// In en, this message translates to:
  /// **'Successfully updated your profile!'**
  String get profile_update_success;

  /// Error message when profile update fails
  ///
  /// In en, this message translates to:
  /// **'Failed to save your profile. Please try again.'**
  String get profile_update_failed;

  /// Community post permissions setting option
  ///
  /// In en, this message translates to:
  /// **'Post permission'**
  String get community_post_permission;

  /// No description provided for @community_story_comments.
  ///
  /// In en, this message translates to:
  /// **'Story comments'**
  String get community_story_comments;

  /// Label for close community setting
  ///
  /// In en, this message translates to:
  /// **'Close community'**
  String get community_setting_close_label;

  /// Description for close community setting
  ///
  /// In en, this message translates to:
  /// **'Closing this community will remove the community  page and all its content and comments.'**
  String get community_setting_close_description;

  /// label for post permissions page title
  ///
  /// In en, this message translates to:
  /// **'Who can post on this community'**
  String get community_post_permission_title_label;

  /// label for post permissions page description
  ///
  /// In en, this message translates to:
  /// **'You can control who can create posts in your community.'**
  String get community_post_permission_description_label;

  /// label for post item bottom text for non members
  ///
  /// In en, this message translates to:
  /// **'Join community to interact with all posts'**
  String get post_item_bottom_nonmember_label;

  /// success toast message for turning on notification
  ///
  /// In en, this message translates to:
  /// **'Notification turned on'**
  String get notification_turn_on_success;

  /// error toast message for turning on notification
  ///
  /// In en, this message translates to:
  /// **'Failed to turn on notification. Please try again.'**
  String get notification_turn_on_error;

  /// success toast message for turning off notification
  ///
  /// In en, this message translates to:
  /// **'Notification turned off'**
  String get notification_turn_off_success;

  /// error toast message for turning off notification
  ///
  /// In en, this message translates to:
  /// **'Failed to turn off notification. Please try again.'**
  String get notification_turn_off_error;

  /// success toast message for reporting user
  ///
  /// In en, this message translates to:
  /// **'User reported.'**
  String get user_report_success;

  /// error toast message for reporting user
  ///
  /// In en, this message translates to:
  /// **'Failed to report user. Please try again.'**
  String get user_report_error;

  /// success toast message for unreporting user
  ///
  /// In en, this message translates to:
  /// **'User unreported.'**
  String get user_unreport_success;

  /// error toast message for unreporting user
  ///
  /// In en, this message translates to:
  /// **'Failed to unreport user. Please try again.'**
  String get user_unreport_error;

  /// success toast message for blocking user
  ///
  /// In en, this message translates to:
  /// **'User blocked.'**
  String get user_block_success;

  /// error toast message for blocking user
  ///
  /// In en, this message translates to:
  /// **'Failed to block user. Please try again.'**
  String get user_block_error;

  /// success toast message for unblocking user
  ///
  /// In en, this message translates to:
  /// **'User unblocked.'**
  String get user_unblock_success;

  /// error toast message for unblocking user
  ///
  /// In en, this message translates to:
  /// **'Failed to unblock user. Please try again.'**
  String get user_unblock_error;

  /// Message displayed when no members are found in search
  ///
  /// In en, this message translates to:
  /// **'No members found'**
  String get search_no_members_found;

  /// Title for moderator promotion confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Moderator promotion'**
  String get moderator_promotion_title;

  /// Description for moderator promotion confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to promote this member to Moderator? They will gain access to all moderator features.'**
  String get moderator_promotion_description;

  /// Button text for promoting to moderator
  ///
  /// In en, this message translates to:
  /// **'Promote'**
  String get moderator_promote_button;

  /// Title for moderator demotion confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Moderator demotion'**
  String get moderator_demotion_title;

  /// Description for moderator demotion confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to demote this Moderator? They will lose access to all moderator features.'**
  String get moderator_demotion_description;

  /// Button text for demoting moderator
  ///
  /// In en, this message translates to:
  /// **'Demote'**
  String get moderator_demote_button;

  /// Title for member removal confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Confirm removal'**
  String get member_removal_confirm_title;

  /// Description for member removal confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this member from the group? They will be aware of their removal.'**
  String get member_removal_confirm_description;

  /// Button text for removing member
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get member_remove_button;

  /// Title for user ban confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Confirm ban'**
  String get user_ban_confirm_title;

  /// Description for user ban confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to ban this user? They will be removed from the group and won\'t be able to find it or rejoin unless they are unbanned.'**
  String get user_ban_confirm_description;

  /// Button text for banning user
  ///
  /// In en, this message translates to:
  /// **'Ban'**
  String get user_ban_button;

  /// Success message when adding member to community
  ///
  /// In en, this message translates to:
  /// **'Successfully added member to this community.'**
  String get member_add_success;

  /// Error message when adding member fails
  ///
  /// In en, this message translates to:
  /// **'Failed to add member. Please try again.'**
  String get member_add_error;

  /// Success message when promoting member to moderator
  ///
  /// In en, this message translates to:
  /// **'Successfully promoted to moderator.'**
  String get moderator_promote_success;

  /// Error message when promoting member fails
  ///
  /// In en, this message translates to:
  /// **'Failed to promote member. Please try again.'**
  String get moderator_promote_error;

  /// Success message when demoting moderator to member
  ///
  /// In en, this message translates to:
  /// **'Successfully demoted to member.'**
  String get moderator_demote_success;

  /// Error message when demoting moderator fails
  ///
  /// In en, this message translates to:
  /// **'Failed to demote member. Please try again.'**
  String get moderator_demote_error;

  /// Success message when removing member from community
  ///
  /// In en, this message translates to:
  /// **'Member removed from this community.'**
  String get member_remove_success;

  /// Error message when removing member fails
  ///
  /// In en, this message translates to:
  /// **'Failed to remove member. Please try again.'**
  String get member_remove_error;

  /// Success message when following user
  ///
  /// In en, this message translates to:
  /// **'User followed.'**
  String get user_follow_success;

  /// Error message when following user fails
  ///
  /// In en, this message translates to:
  /// **'Oops, something went wrong.'**
  String get user_follow_error;

  /// Success message when unfollowing user
  ///
  /// In en, this message translates to:
  /// **'User unfollowed.'**
  String get user_unfollow_success;

  /// Error message when unfollowing user fails
  ///
  /// In en, this message translates to:
  /// **'Oops, something went wrong.'**
  String get user_unfollow_error;

  /// Title for post target selection page
  ///
  /// In en, this message translates to:
  /// **'Post to'**
  String get post_target_selection_title;

  /// Title for blocked user feed empty state
  ///
  /// In en, this message translates to:
  /// **'You\'ve blocked this user'**
  String get user_feed_blocked_title;

  /// Description for blocked user feed empty state
  ///
  /// In en, this message translates to:
  /// **'Unblock to see their posts.'**
  String get user_feed_blocked_description;

  /// Title for private user feed empty state
  ///
  /// In en, this message translates to:
  /// **'This account is private'**
  String get user_feed_private_title;

  /// Description for private user feed empty state
  ///
  /// In en, this message translates to:
  /// **'Follow this user to see their posts.'**
  String get user_feed_private_description;

  /// Timestamp text for content posted just now in social feeds
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get timestamp_just_now;

  /// Timestamp text for content posted just now in chat
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get timestamp_now;

  /// Text for turning on chat notifications
  ///
  /// In en, this message translates to:
  /// **'Turn on notifications'**
  String get chat_notification_turn_on;

  /// Text for turning off chat notifications
  ///
  /// In en, this message translates to:
  /// **'Turn off notifications'**
  String get chat_notification_turn_off;

  /// Title for blocking user confirmation dialog in chat
  ///
  /// In en, this message translates to:
  /// **'Block user?'**
  String get chat_block_user_title;

  /// Description for blocking user confirmation dialog in chat
  ///
  /// In en, this message translates to:
  /// **'{displayName} won\'t be able to send you the message. They won\'t be notified that you\'ve blocked them.'**
  String chat_block_user_description(String displayName);

  /// Title for unblocking user confirmation dialog in chat
  ///
  /// In en, this message translates to:
  /// **'Unblock user?'**
  String get chat_unblock_user_title;

  /// Description for unblocking user confirmation dialog in chat
  ///
  /// In en, this message translates to:
  /// **'{displayName} will now be able to send you the message. They won\'t be notified that you\'ve unblocked them.'**
  String chat_unblock_user_description(String displayName);

  /// Text shown for photo messages in chat notifications
  ///
  /// In en, this message translates to:
  /// **'Send a photo'**
  String get chat_message_photo;

  /// Text shown for video messages in chat notifications
  ///
  /// In en, this message translates to:
  /// **'Send a video'**
  String get chat_message_video;

  /// Text for new follow requests notification
  ///
  /// In en, this message translates to:
  /// **'New follow requests'**
  String get user_follow_request_new;

  /// Text showing number of requests needing approval
  ///
  /// In en, this message translates to:
  /// **'{count} requests need your approval'**
  String user_follow_request_approval(String count);

  /// Button text for unfollowing a user
  ///
  /// In en, this message translates to:
  /// **'Unfollow'**
  String get user_unfollow;

  /// Title for dialog when unable to follow user
  ///
  /// In en, this message translates to:
  /// **'Unable to follow this user'**
  String get user_follow_unable_title;

  /// Description for dialog when unable to follow user
  ///
  /// In en, this message translates to:
  /// **'Oops! something went wrong. Please try again later.'**
  String get user_follow_unable_description;

  /// Button text for following a user
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get user_follow;

  /// Button text for canceling follow request
  ///
  /// In en, this message translates to:
  /// **'Cancel Request'**
  String get user_follow_cancel;

  /// Button text showing user is being followed
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get user_following;

  /// Title for blocking user confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Block user?'**
  String get user_block_confirm_title;

  /// Description for blocking user confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'{displayName} won\'t be able to see posts and comments that you\'ve created. They won\'t be notified that you\'ve blocked them.'**
  String user_block_confirm_description(String displayName);

  /// Button text for confirming block action
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get user_block_confirm_button;

  /// Title for unblocking user confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Unblock user?'**
  String get user_unblock_confirm_title;

  /// Description for unblocking user confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'{displayName} will now be able to see posts and comments that you\'ve created. They won\'t be notified that you\'ve unblocked them.'**
  String user_unblock_confirm_description(String displayName);

  /// Button text for confirming unblock action
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get user_unblock_confirm_button;

  /// Title for unfollowing user confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Unfollow this user?'**
  String get user_unfollow_confirm_title;

  /// Description for unfollowing user confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'If you change your mind, you\'ll have to request to follow them again.'**
  String get user_unfollow_confirm_description;

  /// Button text for confirming unfollow action
  ///
  /// In en, this message translates to:
  /// **'Unfollow'**
  String get user_unfollow_confirm_button;

  /// Default title for category page when category name is not available
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category_default_title;

  /// Empty state message when there are no communities in the category
  ///
  /// In en, this message translates to:
  /// **'No community yet'**
  String get community_empty_state;

  /// Title for the pending requests page
  ///
  /// In en, this message translates to:
  /// **'Pending Requests'**
  String get community_pending_requests_title;

  /// Title for empty state when no pending requests are available
  ///
  /// In en, this message translates to:
  /// **'No pending requests available'**
  String get community_pending_requests_empty_title;

  /// Description for empty state when no pending requests are available
  ///
  /// In en, this message translates to:
  /// **'Enable post review or join approval in community settings to manage requests.'**
  String get community_pending_requests_empty_description;

  /// Placeholder text for join requests feature that is not yet implemented
  ///
  /// In en, this message translates to:
  /// **'Join requests feature coming soon'**
  String get community_join_requests_coming_soon;

  /// Warning message for moderators about declining pending posts
  ///
  /// In en, this message translates to:
  /// **'Decline pending post will permanently delete the selected post from community.'**
  String get community_pending_posts_warning;

  /// Empty state message when there are no pending posts
  ///
  /// In en, this message translates to:
  /// **'No pending posts'**
  String get community_pending_posts_empty;

  /// Button text for accepting a pending post
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get community_pending_post_accept;

  /// Button text for declining a pending post
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get community_pending_post_decline;

  /// Success message when pending post is deleted
  ///
  /// In en, this message translates to:
  /// **'Post deleted.'**
  String get community_pending_post_delete_success;

  /// Error message when deleting pending post fails
  ///
  /// In en, this message translates to:
  /// **'Failed to delete post. Please try again.'**
  String get community_pending_post_delete_error;

  /// Success message when pending post is approved
  ///
  /// In en, this message translates to:
  /// **'Post accepted.'**
  String get community_pending_post_approve_success;

  /// Error message when approving pending post fails
  ///
  /// In en, this message translates to:
  /// **'Failed to accept post. This post has been reviewed by another moderator.'**
  String get community_pending_post_approve_error;

  /// Success message when pending post is declined
  ///
  /// In en, this message translates to:
  /// **'Post declined.'**
  String get community_pending_post_decline_success;

  /// Error message when declining pending post fails
  ///
  /// In en, this message translates to:
  /// **'Failed to decline post. This post has been reviewed by another moderator.'**
  String get community_pending_post_decline_error;

  /// Hint text for poll option input field
  ///
  /// In en, this message translates to:
  /// **'Option {optionNumber}'**
  String poll_option_hint(int optionNumber);

  /// Button text for adding a new poll option
  ///
  /// In en, this message translates to:
  /// **'Add option'**
  String get poll_add_option;

  /// Title for multiple selection toggle
  ///
  /// In en, this message translates to:
  /// **'Multiple selection'**
  String get poll_multiple_selection_title;

  /// Description for multiple selection toggle
  ///
  /// In en, this message translates to:
  /// **'Let participants vote more than one option.'**
  String get poll_multiple_selection_description;

  /// Text showing when poll ends with formatted date
  ///
  /// In en, this message translates to:
  /// **'Ends on {endDate}'**
  String poll_ends_on(String endDate);

  /// Label for poll end date
  ///
  /// In en, this message translates to:
  /// **'Ends on'**
  String get poll_ends_on_label;

  /// Placeholder text for date picker
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get poll_select_date;

  /// Placeholder text for time picker
  ///
  /// In en, this message translates to:
  /// **'Select Time'**
  String get poll_select_time;

  /// Poll duration options with proper pluralization
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{1 day} other{{days} days}}'**
  String poll_duration_days(int days);

  /// Label for hour in time picker
  ///
  /// In en, this message translates to:
  /// **'Hour'**
  String get poll_time_hour;

  /// Label for minute in time picker
  ///
  /// In en, this message translates to:
  /// **'Minute'**
  String get poll_time_minute;

  /// Label for display name field in edit profile
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get profile_edit_display_name;

  /// Label for about field in edit profile
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get profile_edit_about;

  /// Title for unsupported image type dialog
  ///
  /// In en, this message translates to:
  /// **'Unsupported image type'**
  String get profile_edit_unsupported_image_title;

  /// Description for unsupported image type dialog
  ///
  /// In en, this message translates to:
  /// **'Please upload a PNG or JPG image.'**
  String get profile_edit_unsupported_image_description;

  /// Title for inappropriate image dialog
  ///
  /// In en, this message translates to:
  /// **'Inappropriate image'**
  String get profile_edit_inappropriate_image_title;

  /// Description for inappropriate image dialog
  ///
  /// In en, this message translates to:
  /// **'Please choose a different image to upload.'**
  String get profile_edit_inappropriate_image_description;

  /// Title for unsaved changes confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Unsaved changes'**
  String get profile_edit_unsaved_changes_title;

  /// Description for unsaved changes confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to discard the changes? They will be lost when you leave this page.'**
  String get profile_edit_unsaved_changes_description;

  /// Title for chat home page
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat_title;

  /// Tab label for all chats
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get chat_tab_all;

  /// Tab label for direct chats
  ///
  /// In en, this message translates to:
  /// **'Direct'**
  String get chat_tab_direct;

  /// Tab label for group chats
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get chat_tab_groups;

  /// Message shown when waiting for network connection
  ///
  /// In en, this message translates to:
  /// **'Waiting for network...'**
  String get chat_waiting_for_network;

  /// Menu option for creating direct chat
  ///
  /// In en, this message translates to:
  /// **'Direct chat'**
  String get chat_direct_chat;

  /// Menu option for creating group chat
  ///
  /// In en, this message translates to:
  /// **'Group chat'**
  String get chat_group_chat;

  /// Menu option for archived chats
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get chat_archived;

  /// Text shown when editing a message
  ///
  /// In en, this message translates to:
  /// **'Editing message'**
  String get message_editing_message;

  /// Text shown when replying to your own message
  ///
  /// In en, this message translates to:
  /// **'yourself'**
  String get message_replying_yourself;

  /// Title for replied message display
  ///
  /// In en, this message translates to:
  /// **'Replied message'**
  String get message_replied_message;

  /// Text shown when replying to a message
  ///
  /// In en, this message translates to:
  /// **'Replying to {displayName}'**
  String message_replying_to(String displayName);

  /// Label for media button in message composer
  ///
  /// In en, this message translates to:
  /// **'Media'**
  String get message_media;

  /// Loading message shown when chat is being initialized
  ///
  /// In en, this message translates to:
  /// **'Loading chat...'**
  String get chat_loading;

  /// Message shown when user is blocked and cannot send messages
  ///
  /// In en, this message translates to:
  /// **'You can\'t send messages to this person.'**
  String get chat_blocked_message;

  /// Message shown when chat notifications are disabled
  ///
  /// In en, this message translates to:
  /// **'You have disabled notifications for chat'**
  String get chat_notifications_disabled;

  /// Action text for archiving a chat
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get chat_archive;

  /// Action text for unarchiving a chat
  ///
  /// In en, this message translates to:
  /// **'Unarchive'**
  String get chat_unarchive;

  /// Preview text for deleted messages
  ///
  /// In en, this message translates to:
  /// **'This message was deleted'**
  String get chat_message_deleted;

  /// Preview text for unsupported message types
  ///
  /// In en, this message translates to:
  /// **'No preview supported for this message type'**
  String get chat_message_no_preview;

  /// Preview text when there are no messages in the chat
  ///
  /// In en, this message translates to:
  /// **'No message yet'**
  String get chat_no_message_yet;

  /// Hint text for search input fields
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get general_search_hint;

  /// Empty state title for archived chats list
  ///
  /// In en, this message translates to:
  /// **'No archived chats'**
  String get chat_archived_empty_title;

  /// Title for archived chats page
  ///
  /// In en, this message translates to:
  /// **'Archived chats'**
  String get chat_archived_title;

  /// Toast message when chat is archived successfully
  ///
  /// In en, this message translates to:
  /// **'Chat archived.'**
  String get toast_chat_archived;

  /// Toast message when chat is unarchived successfully
  ///
  /// In en, this message translates to:
  /// **'Chat unarchived.'**
  String get toast_chat_unarchived;

  /// Toast message when chat archive fails
  ///
  /// In en, this message translates to:
  /// **'Failed to archive chat. Please try again'**
  String get toast_chat_archive_error;

  /// Toast message when chat unarchive fails
  ///
  /// In en, this message translates to:
  /// **'Failed to unarchive chat. Please try again'**
  String get toast_chat_unarchive_error;

  /// Dialog title when archive limit is reached
  ///
  /// In en, this message translates to:
  /// **'Too many chats archived'**
  String get chat_archive_limit_title;

  /// Dialog message when archive limit is reached
  ///
  /// In en, this message translates to:
  /// **'You can archive a maximum of 100 chat lists.'**
  String get chat_archive_limit_message;

  /// Empty state title for chat list
  ///
  /// In en, this message translates to:
  /// **'No conversation yet'**
  String get chat_empty_title;

  /// Empty state description for chat list
  ///
  /// In en, this message translates to:
  /// **'Let\'s create chat to get started.'**
  String get chat_empty_description;

  /// Button text to create a new chat
  ///
  /// In en, this message translates to:
  /// **'Create new chat'**
  String get chat_create_new;

  /// Title for group profile page
  ///
  /// In en, this message translates to:
  /// **'Group profile'**
  String get chat_group_profile_title;

  /// Error message when group profile fails to load
  ///
  /// In en, this message translates to:
  /// **'Error loading profile'**
  String get chat_group_profile_error;

  /// Hint text for group name input field
  ///
  /// In en, this message translates to:
  /// **'Enter group name'**
  String get chat_group_name_hint;

  /// Placeholder text for group name input
  ///
  /// In en, this message translates to:
  /// **'Name your group'**
  String get chat_group_name_placeholder;

  /// Title for member permissions page
  ///
  /// In en, this message translates to:
  /// **'Member permissions'**
  String get chat_member_permissions_title;

  /// Label for member section
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get chat_member_label;

  /// Error message when no user is selected
  ///
  /// In en, this message translates to:
  /// **'Please select at least one user'**
  String get chat_select_member_error;

  /// Hint text for message report details input
  ///
  /// In en, this message translates to:
  /// **'Share more details about this issue'**
  String get message_report_details_hint;

  /// Tab title for chats in search page
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get chat_search_tab_chats;

  /// Tab title for messages in search page
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get chat_search_tab_messages;

  /// Hint text shown when search query is too short
  ///
  /// In en, this message translates to:
  /// **'Start your search by typing\nat least 3 letters'**
  String get search_minimum_chars;

  /// Title for camera permission dialog
  ///
  /// In en, this message translates to:
  /// **'Allow access to your camera'**
  String get permission_camera_title;

  /// Detail text for camera permission dialog
  ///
  /// In en, this message translates to:
  /// **'This allows the app to take photos and record videos from your device camera.'**
  String get permission_camera_detail;

  /// Title for microphone permission dialog
  ///
  /// In en, this message translates to:
  /// **'Allow access to your microphone'**
  String get permission_microphone_title;

  /// Detail text for microphone permission dialog
  ///
  /// In en, this message translates to:
  /// **'This allows the app to record audio for videos from your device microphone.'**
  String get permission_microphone_detail;

  /// Button text to open app settings
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get permission_open_settings;

  /// Label for copy action in menus
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get general_copy;

  /// Label for report message button
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get message_report;

  /// Label for unreport message button
  ///
  /// In en, this message translates to:
  /// **'Unreport'**
  String get message_unreport;

  /// Toast message when message text is copied
  ///
  /// In en, this message translates to:
  /// **'Copied.'**
  String get toast_message_copied;

  /// Toast message when message is successfully reported
  ///
  /// In en, this message translates to:
  /// **'Message reported.'**
  String get toast_message_reported;

  /// Toast message when message is successfully unreported
  ///
  /// In en, this message translates to:
  /// **'Message unreported.'**
  String get toast_message_unreported;

  /// Toast message when reporting message fails
  ///
  /// In en, this message translates to:
  /// **'Failed to report message. Please try again.'**
  String get toast_message_report_error;

  /// Toast message when unreporting message fails
  ///
  /// In en, this message translates to:
  /// **'Failed to unreport message. Please try again.'**
  String get toast_message_unreport_error;

  /// Toast message when deleting message fails
  ///
  /// In en, this message translates to:
  /// **'Failed to delete message.'**
  String get toast_message_delete_error;

  /// Toast message when permission is denied
  ///
  /// In en, this message translates to:
  /// **'Permission denied.'**
  String get toast_permission_denied;

  /// Toast message when photo is successfully saved
  ///
  /// In en, this message translates to:
  /// **'Saved photo.'**
  String get toast_photo_saved;

  /// Toast message when saving image fails
  ///
  /// In en, this message translates to:
  /// **'Failed to save image.'**
  String get toast_photo_save_error;

  /// Toast message when video is successfully saved
  ///
  /// In en, this message translates to:
  /// **'Saved video.'**
  String get toast_video_saved;

  /// Toast message when saving video fails
  ///
  /// In en, this message translates to:
  /// **'Failed to save video.'**
  String get toast_video_save_error;

  /// Title for delete message confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete this message?'**
  String get message_delete_title;

  /// Description for delete message confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'This message will also be removed from your friend\'s devices.'**
  String get message_delete_description;

  /// Toast message when group chat is created successfully
  ///
  /// In en, this message translates to:
  /// **'Group chat created.'**
  String get chat_create_success;

  /// Error message when group creation fails
  ///
  /// In en, this message translates to:
  /// **'Failed to create group'**
  String get chat_create_error;

  /// Toast error message prompting user to retry group creation
  ///
  /// In en, this message translates to:
  /// **'Failed to create group chat. Please try again.'**
  String get chat_create_error_retry;

  /// AppBar title for create group page
  ///
  /// In en, this message translates to:
  /// **'New Group'**
  String get chat_create_title;

  /// Button text to create a new group
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get chat_create_button;

  /// Label for group name input field
  ///
  /// In en, this message translates to:
  /// **'Group name'**
  String get chat_group_name_label;

  /// Text indicating group name is optional
  ///
  /// In en, this message translates to:
  /// **'(Optional)'**
  String get chat_group_name_optional;

  /// Text indicating group name is required
  ///
  /// In en, this message translates to:
  /// **'(Required)'**
  String get chat_group_name_required;

  /// Label for public privacy option
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get chat_privacy_public;

  /// Description for public group privacy setting
  ///
  /// In en, this message translates to:
  /// **'Anyone can find the group through search and join the conversation.'**
  String get chat_privacy_public_desc;

  /// Label for private privacy option
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get chat_privacy_private;

  /// Description for private group privacy setting
  ///
  /// In en, this message translates to:
  /// **'Group is hidden from search and only accessible by invitation from moderators.'**
  String get chat_privacy_private_desc;

  /// Warning message about privacy setting being permanent
  ///
  /// In en, this message translates to:
  /// **'Ensure the correct privacy setting is chosen for your group, as it can\'t be changed later.'**
  String get chat_privacy_warning;

  /// AppBar title for select member page when creating group
  ///
  /// In en, this message translates to:
  /// **'New group'**
  String get chat_select_member_title;

  /// Button text to proceed to next step
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get general_next;

  /// AppBar title fallback for group settings page
  ///
  /// In en, this message translates to:
  /// **'Group Settings'**
  String get settings_group_settings;

  /// Section title for group settings
  ///
  /// In en, this message translates to:
  /// **'Group settings'**
  String get settings_group_settings_section;

  /// Menu item for group profile settings
  ///
  /// In en, this message translates to:
  /// **'Group profile'**
  String get settings_group_profile;

  /// Menu item for group notification settings
  ///
  /// In en, this message translates to:
  /// **'Group notifications'**
  String get settings_group_notifications;

  /// Menu item for member permission settings
  ///
  /// In en, this message translates to:
  /// **'Member permissions'**
  String get settings_member_permissions;

  /// Menu item for viewing all members
  ///
  /// In en, this message translates to:
  /// **'All members'**
  String get settings_all_members;

  /// Menu item for viewing banned users
  ///
  /// In en, this message translates to:
  /// **'Banned users'**
  String get settings_banned_users;

  /// Empty state message when no users are banned
  ///
  /// In en, this message translates to:
  /// **'Nothing here to see yet'**
  String get banned_users_empty_state;

  /// Title for unban user confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Confirm unban'**
  String get user_unban_confirm_title;

  /// Description for unban user confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to unban this user? They will be able to rejoin the group again.'**
  String get user_unban_confirm_description;

  /// Button text for unban action
  ///
  /// In en, this message translates to:
  /// **'Unban'**
  String get user_unban_button;

  /// Toast message shown when a user is successfully unbanned
  ///
  /// In en, this message translates to:
  /// **'User unbanned.'**
  String get toast_user_unbanned;

  /// Toast message shown when unbanning a user fails
  ///
  /// In en, this message translates to:
  /// **'Failed to unban user. Please try again.'**
  String get toast_user_unban_error;

  /// Section title for user's personal preferences
  ///
  /// In en, this message translates to:
  /// **'Your preferences'**
  String get settings_your_preferences;

  /// Lowercase notifications label
  ///
  /// In en, this message translates to:
  /// **'notifications'**
  String get general_notifications_lowercase;

  /// Button text to leave a group
  ///
  /// In en, this message translates to:
  /// **'Leave group'**
  String get chat_leave_group;

  /// Dialog title for leaving a group
  ///
  /// In en, this message translates to:
  /// **'Leave Group'**
  String get chat_leave_group_title;

  /// Confirmation message for leaving a group
  ///
  /// In en, this message translates to:
  /// **'If you leave this group, you will no longer see new activities or participate in this group.'**
  String get chat_leave_group_confirm;

  /// Dialog title when user is the last moderator
  ///
  /// In en, this message translates to:
  /// **'You\'re the last moderator'**
  String get chat_leave_group_last_mod_title;

  /// Message explaining moderator promotion requirement
  ///
  /// In en, this message translates to:
  /// **'You must promote another member to moderator before leaving.'**
  String get chat_leave_group_last_mod_message;

  /// Button text to promote a member to moderator
  ///
  /// In en, this message translates to:
  /// **'Promote member'**
  String get chat_promote_member;

  /// Label for default notification mode
  ///
  /// In en, this message translates to:
  /// **'Default mode'**
  String get notification_default_mode;

  /// Description for default notification mode
  ///
  /// In en, this message translates to:
  /// **'By default, members in this community will receive notifications, but they can choose to turn them off.'**
  String get notification_default_mode_desc;

  /// Label for silent notification mode
  ///
  /// In en, this message translates to:
  /// **'Silent mode'**
  String get notification_silent_mode;

  /// Description for silent notification mode
  ///
  /// In en, this message translates to:
  /// **'No notifications for everyone in this channel. Members can\'t turn on notifications in the channel.'**
  String get notification_silent_mode_desc;

  /// Label for subscribe notification mode
  ///
  /// In en, this message translates to:
  /// **'Subscribe mode'**
  String get notification_subscribe_mode;

  /// Description for subscribe notification mode
  ///
  /// In en, this message translates to:
  /// **'All members have the option to receive notifications, but they need to enable them. By default, notifications are turned off for each member.'**
  String get notification_subscribe_mode_desc;

  /// Title for notification preference page
  ///
  /// In en, this message translates to:
  /// **'Notification Preference'**
  String get notification_preference_title;

  /// Label for allow notifications toggle
  ///
  /// In en, this message translates to:
  /// **'Allow notifications'**
  String get notification_allow_notifications;

  /// Description for allow notifications toggle
  ///
  /// In en, this message translates to:
  /// **'Turn on to receive push notifications from this group.'**
  String get notification_allow_notifications_desc;

  /// Message shown when notifications are disabled by moderator
  ///
  /// In en, this message translates to:
  /// **'Group notifications have been disabled by moderator.'**
  String get notification_disabled_by_moderator;

  /// Toast message when notifications are enabled
  ///
  /// In en, this message translates to:
  /// **'Notifications enabled'**
  String get notification_enabled_toast;

  /// Toast message when notifications are disabled
  ///
  /// In en, this message translates to:
  /// **'Notifications disabled'**
  String get notification_disabled_toast;

  /// Section title for messaging permissions
  ///
  /// In en, this message translates to:
  /// **'Messaging'**
  String get settings_messaging;

  /// Description for everyone messaging permission
  ///
  /// In en, this message translates to:
  /// **'Everyone can send a message in the group.'**
  String get settings_everyone_desc;

  /// Description for moderators-only messaging permission
  ///
  /// In en, this message translates to:
  /// **'Members who are not moderators can read messages but cannot send any messages.'**
  String get settings_only_moderators_desc;

  /// Success toast when leaving a group
  ///
  /// In en, this message translates to:
  /// **'Group chat left.'**
  String get toast_group_chat_left;

  /// Error toast when failing to leave a group
  ///
  /// In en, this message translates to:
  /// **'Failed to leave group chat. Please try again.'**
  String get toast_group_chat_left_error;

  /// Success toast when group profile is updated
  ///
  /// In en, this message translates to:
  /// **'Group profile updated.'**
  String get toast_group_profile_updated;

  /// Error toast when failing to update group profile
  ///
  /// In en, this message translates to:
  /// **'Failed to update group profile. Please try again.'**
  String get toast_group_profile_error;

  /// Success toast when group notifications are updated
  ///
  /// In en, this message translates to:
  /// **'Group notification updated.'**
  String get toast_group_notification_updated;

  /// Error toast when failing to update group notifications
  ///
  /// In en, this message translates to:
  /// **'Failed to update group notification. Please try again.'**
  String get toast_group_notification_error;

  /// Success toast when member permissions are updated
  ///
  /// In en, this message translates to:
  /// **'Member permissions updated.'**
  String get toast_member_permissions_updated;

  /// Error toast when failing to update member permissions
  ///
  /// In en, this message translates to:
  /// **'Failed to update member permissions. Please try again.'**
  String get toast_member_permissions_error;

  /// Success toast when member list is updated
  ///
  /// In en, this message translates to:
  /// **'Member list updated.'**
  String get toast_member_list_updated;

  /// Error toast when failing to update member list
  ///
  /// In en, this message translates to:
  /// **'Failed to update member list. Please try again.'**
  String get toast_member_list_error;

  /// Success toast when banned users list is updated
  ///
  /// In en, this message translates to:
  /// **'Banned users updated.'**
  String get toast_banned_users_updated;

  /// Error toast when failing to update banned users
  ///
  /// In en, this message translates to:
  /// **'Failed to update banned users. Please try again.'**
  String get toast_banned_users_error;

  /// Success toast when multiple members are added
  ///
  /// In en, this message translates to:
  /// **'Members added'**
  String get toast_members_added;

  /// Success toast when a single member is added
  ///
  /// In en, this message translates to:
  /// **'Member added.'**
  String get toast_member_added;

  /// Error toast when failing to add multiple members
  ///
  /// In en, this message translates to:
  /// **'Failed to add members. Please try again.'**
  String get toast_members_add_error;

  /// Error toast when failing to add a single member
  ///
  /// In en, this message translates to:
  /// **'Failed to add member. Please try again.'**
  String get toast_member_add_error;

  /// Success toast when a member is removed
  ///
  /// In en, this message translates to:
  /// **'Member removed.'**
  String get toast_member_removed;

  /// Error toast when failing to remove a member
  ///
  /// In en, this message translates to:
  /// **'Failed to remove member. Please try again.'**
  String get toast_member_remove_error;

  /// Success toast when a member is promoted to moderator
  ///
  /// In en, this message translates to:
  /// **'Member promoted.'**
  String get toast_member_promoted;

  /// Error toast when failing to promote a member
  ///
  /// In en, this message translates to:
  /// **'Failed to promote member. Please try again.'**
  String get toast_member_promote_error;

  /// Success toast when a moderator is demoted
  ///
  /// In en, this message translates to:
  /// **'Member demoted.'**
  String get toast_member_demoted;

  /// Error toast when failing to demote a member
  ///
  /// In en, this message translates to:
  /// **'Failed to demote member. Please try again.'**
  String get toast_member_demote_error;

  /// Success toast when a user is banned
  ///
  /// In en, this message translates to:
  /// **'User banned.'**
  String get toast_user_banned;

  /// Error toast when failing to ban a user
  ///
  /// In en, this message translates to:
  /// **'Failed to ban user. Please try again.'**
  String get toast_user_ban_error;

  /// Success toast when a user is reported
  ///
  /// In en, this message translates to:
  /// **'User reported.'**
  String get toast_user_reported;

  /// Success toast when a user report is removed
  ///
  /// In en, this message translates to:
  /// **'User unreported.'**
  String get toast_user_unreported;

  /// Error toast when failing to report or unreport a user
  ///
  /// In en, this message translates to:
  /// **'Failed to report/unreport user. Please try again.'**
  String get toast_user_report_error;

  /// Success toast when a user is muted
  ///
  /// In en, this message translates to:
  /// **'User muted.'**
  String get toast_user_muted;

  /// Error toast when failing to mute a user
  ///
  /// In en, this message translates to:
  /// **'Failed to mute user. Please try again.'**
  String get toast_user_mute_error;

  /// Success toast when a user is unmuted
  ///
  /// In en, this message translates to:
  /// **'User unmuted.'**
  String get toast_user_unmuted;

  /// Error toast when failing to unmute a user
  ///
  /// In en, this message translates to:
  /// **'Failed to unmute user. Please try again.'**
  String get toast_user_unmute_error;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'es':
      {
        switch (locale.countryCode) {
          case 'CL':
            return AppLocalizationsEsCl();
          case 'CO':
            return AppLocalizationsEsCo();
          case 'MX':
            return AppLocalizationsEsMx();
          case 'PE':
            return AppLocalizationsEsPe();
        }
        break;
      }
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'BR':
            return AppLocalizationsPtBr();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
