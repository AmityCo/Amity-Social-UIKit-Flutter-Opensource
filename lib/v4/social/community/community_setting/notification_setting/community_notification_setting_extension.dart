import 'package:amity_sdk/amity_sdk.dart';

extension AmityCommunityNotificationSettingsExtension
    on AmityCommunityNotificationSettings {
  
  // Post notification setting events
  bool isPostCreatedEventEnabled() {
    return (events?.firstWhere((event) => event is PostCreated) as PostCreated?)
            ?.isNetworkEnabled ??
        false;
  }

  bool isPostReactedEventEnabled() {
    return (events?.firstWhere((event) => event is PostReacted) as PostReacted?)
            ?.isNetworkEnabled ??
        false;
  }

  bool isPostNetworkEnabled() {
    return isPostCreatedEventEnabled() || isPostReactedEventEnabled();
  }

  // Comment notification setting events

  bool isCommentCreatedEventEnabled() {
    return (events?.firstWhere((event) => event is CommentCreated)
                as CommentCreated?)
            ?.isNetworkEnabled ??
        false;
  }

  bool isCommentReactedEventEnabled() {
    return (events?.firstWhere((event) => event is CommentReacted)
                as CommentReacted?)
            ?.isNetworkEnabled ??
        false;
  }

  bool isCommentRepliedEventEnabled() {
    return (events?.firstWhere((event) => event is CommentReplied)
                as CommentReplied?)
            ?.isNetworkEnabled ??
        false;
  }
        
  bool isCommentNetworkEnabled() {
    return isCommentCreatedEventEnabled() ||
        isCommentReactedEventEnabled() ||
        isCommentRepliedEventEnabled();
  }

  // Story notification setting events
  bool isStoryCreatedEventEnabled() {
    return (events?.firstWhere((event) => event is StoryCreated)
                as StoryCreated?)
            ?.isNetworkEnabled ??
        false;
  }

  bool isStoryReactedEventEnabled() {
    return (events?.firstWhere((event) => event is StoryReacted)
                as StoryReacted?)
            ?.isNetworkEnabled ??
        false;
  }

  bool isStoryCommentCreatedEventEnabled() {
    return (events?.firstWhere((event) => event is StoryCommentCreated)
                as StoryCommentCreated?)
            ?.isNetworkEnabled ??
        false;
  }

  bool isStoryNetworkEnabled() {
    return isStoryCreatedEventEnabled() ||
        isStoryReactedEventEnabled() ||
        isStoryCommentCreatedEventEnabled();
  }

  // Social network
  bool isSocialNetworkEnabled() {
    return isPostNetworkEnabled() ||
        isCommentNetworkEnabled() ||
        isStoryNetworkEnabled();
  }
}