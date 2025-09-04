class FreedomCommunityNotificationSettingBehavior {
  bool forceShowComment() => false;

  bool forceShowPost() => false;

  Function()? saveSetting;

  Function()? postReactChanged;
  Function()? postNewChanged;

  Function()? commentReactChanged;
  Function()? commentNewChanged;
  Function()? commentReplyChanged;
}
