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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
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

  /// Label for the featured posts
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get general_featured;

  /// Label for edit profile button
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get profile_edit;

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

  /// Label for close button
  ///
  /// In en, this message translates to:
  /// **'Close community?'**
  String get community_close;

  /// Confirmation message for closing a community
  ///
  /// In en, this message translates to:
  /// **'All members will be removed from  the community. All posts, messages, reactions, and media shared in community will be deleted. This cannot be undone.'**
  String get community_close_description;

  /// Label for join community button
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get community_join;

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

  /// Label for everyone settings
  ///
  /// In en, this message translates to:
  /// **'Everyone'**
  String get settings_everyone;

  /// Label for only moderators settings
  ///
  /// In en, this message translates to:
  /// **'Only moderators'**
  String get settings_only_moderators;

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

  /// Label for save button
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

  /// Label for on state
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get general_on;

  /// Label for off state
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get general_off;

  /// Label for reported content
  ///
  /// In en, this message translates to:
  /// **'reported'**
  String get general_reported;

  /// Label for see more button
  ///
  /// In en, this message translates to:
  /// **'...See more'**
  String get general_see_more;

  /// Label for camera button
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get general_camera;

  /// Label for photo button
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

  /// Label for block user button
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
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {

  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'es': {
  switch (locale.countryCode) {
    case 'CL': return AppLocalizationsEsCl();
case 'CO': return AppLocalizationsEsCo();
case 'MX': return AppLocalizationsEsMx();
case 'PE': return AppLocalizationsEsPe();
   }
  break;
   }
    case 'pt': {
  switch (locale.countryCode) {
    case 'BR': return AppLocalizationsPtBr();
   }
  break;
   }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'pt': return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
