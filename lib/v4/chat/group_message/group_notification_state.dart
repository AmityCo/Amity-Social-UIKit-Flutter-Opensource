part of 'group_notification_page.dart';

abstract class GroupNotificationState {
  final NotificationMode selectedMode;
  final NotificationMode initialMode;
  final bool hasChanges;
  
  GroupNotificationState(this.selectedMode, this.initialMode)
    : hasChanges = selectedMode != initialMode;
}

class GroupNotificationInitial extends GroupNotificationState {
  GroupNotificationInitial(NotificationMode selectedMode) : super(selectedMode, selectedMode);
}

class GroupNotificationLoading extends GroupNotificationState {
  GroupNotificationLoading(NotificationMode selectedMode, NotificationMode initialMode) : super(selectedMode, initialMode);
}

class GroupNotificationLoaded extends GroupNotificationState {
  GroupNotificationLoaded(NotificationMode selectedMode, NotificationMode initialMode) : super(selectedMode, initialMode);
}

class GroupNotificationSuccess extends GroupNotificationState {
  GroupNotificationSuccess(NotificationMode selectedMode) : super(selectedMode, selectedMode);
}

class GroupNotificationError extends GroupNotificationState {
  final String errorMessage;
  
  GroupNotificationError(this.errorMessage) : super(NotificationMode.defaultMode, NotificationMode.defaultMode);
}