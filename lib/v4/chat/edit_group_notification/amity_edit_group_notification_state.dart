part of 'amity_edit_group_notification_page.dart';

abstract class AmityGroupNotificationState {
  final NotificationMode selectedMode;
  final NotificationMode initialMode;
  final bool hasChanges;
  
  AmityGroupNotificationState(this.selectedMode, this.initialMode)
    : hasChanges = selectedMode != initialMode;
}

class GroupNotificationInitial extends AmityGroupNotificationState {
  GroupNotificationInitial(NotificationMode selectedMode) : super(selectedMode, selectedMode);
}

class GroupNotificationLoading extends AmityGroupNotificationState {
  GroupNotificationLoading(NotificationMode selectedMode, NotificationMode initialMode) : super(selectedMode, initialMode);
}

class GroupNotificationLoaded extends AmityGroupNotificationState {
  GroupNotificationLoaded(NotificationMode selectedMode, NotificationMode initialMode) : super(selectedMode, initialMode);
}

class GroupNotificationSuccess extends AmityGroupNotificationState {
  GroupNotificationSuccess(NotificationMode selectedMode) : super(selectedMode, selectedMode);
}

class GroupNotificationError extends AmityGroupNotificationState {
  final String errorMessage;
  
  GroupNotificationError(this.errorMessage) : super(NotificationMode.defaultMode, NotificationMode.defaultMode);
}