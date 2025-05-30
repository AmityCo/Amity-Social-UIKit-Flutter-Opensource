part of 'group_notification_page.dart';

class GroupNotificationCubit extends Cubit<GroupNotificationState> {
  final AmityChannel channel;

  GroupNotificationCubit(this.channel)
      : super(GroupNotificationInitial(getInitialMode(channel))) {
    loadNotificationSettings();
  }

  static NotificationMode getInitialMode(AmityChannel channel) {
    return channel.notificationMode ?? NotificationMode.defaultMode;
  }

  void loadNotificationSettings() async {
    NotificationMode initialMode = channel.notificationMode ?? NotificationMode.defaultMode;
    emit(GroupNotificationLoaded(initialMode, initialMode));
  }

  void setNotificationMode(NotificationMode mode) {
    if (state is GroupNotificationLoaded || state is GroupNotificationInitial) {
      emit(GroupNotificationLoaded(mode, state.initialMode));
    }
  }
}
