import 'package:amity_sdk/amity_sdk.dart';

/// Whether the current user may create a story.
///
/// Matches the Android/iOS UIKit gate:
/// `(allowAllUserToCreateStory || MANAGE_COMMUNITY_STORY) && isJoined`.
///
/// `allowAllUserToCreateStory` is a network-level setting, so it is fetched
/// once and cached for the session — the SDK exposes no observable for it, so
/// flipping the console setting only takes effect on the next app start.
class StoryCreatePermission {
  static Future<bool>? _allowAllUsers;
  static bool? _resolved;

  /// The last resolved value, readable synchronously — the rule helpers in
  /// `story_creation_rule.dart` are sync, and the reconciled SDK exposes only
  /// the async `getSocialSettings()`. Null until the first fetch lands, so a
  /// sync read kicks the fetch off and the next build sees the real value.
  static bool get allowAllUsersNow {
    if (_resolved == null) allowAllUsers();
    return _resolved ?? false;
  }

  /// Network setting: may any joined member create a story?
  static Future<bool> allowAllUsers() {
    if (!AmityCoreClient.isUserLoggedIn()) return Future.value(false);
    return _allowAllUsers ??= AmityCoreClient.getSocialSettings()
        .then((settings) {
      _resolved = settings.story.allowAllUserToCreateStory;
      return _resolved!;
    })
        .catchError((_) {
      _allowAllUsers = null; // a failed fetch should not stick — let it retry
      return false;
    });
  }

  static Future<bool> check({
    required bool hasManageStoryPermission,
    required bool isJoined,
  }) async {
    if (!isJoined) return false;
    if (hasManageStoryPermission) return true;
    return allowAllUsers();
  }
}
