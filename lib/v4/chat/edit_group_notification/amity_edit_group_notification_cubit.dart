part of 'amity_edit_group_notification_page.dart';

class AmityGroupNotificationCubit extends Cubit<AmityGroupNotificationState> {
  final AmityChannel channel;

  AmityGroupNotificationCubit(this.channel)
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
