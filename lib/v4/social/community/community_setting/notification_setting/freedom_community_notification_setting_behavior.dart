import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_setting/notification_setting/comment/bloc/community_comment_notification_setting_page_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_setting/notification_setting/post/bloc/community_post_notification_setting_page_bloc.dart';
import 'package:flutter/cupertino.dart';

class FreedomCommunityNotificationSettingBehavior {
  bool forceShowComment() => false;

  bool forceShowPost() => false;

  bool notDefaultSetting() => true;

  Future<void> Function({
    required AmityCommunity community,
    required void Function(CommunityPostNotificationSettingPageState) emit,
    required CommunityPostNotificationSettingPageState state,
  })? initialPostSetting;

  Future<void> Function({
    required AmityCommunity community,
    required void Function(CommunityCommentNotificationSettingPageState) emit,
    required CommunityCommentNotificationSettingPageState state,
  })? initialCommentSetting;

  void Function({
    required AmityCommunity community,
    required CommunityPostNotificationSettingSaveEvent event,
    required CommunityPostNotificationSettingPageState state,
  })? savePostSetting;

  void Function({
    required AmityCommunity community,
    required CommunityCommentNotificationSettingSaveEvent event,
    required CommunityCommentNotificationSettingPageState state,
  })? saveCommentSetting;

  Future<void> Function()? saveStorySetting;

  void Function(BuildContext context)? onSaveSuccess;

  Widget Function(BuildContext context, bool isChanged)? buildSaveButton;

  Future<void> Function(AmityCommunity community, bool isEnable)? toggleMute;
}
