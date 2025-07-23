part of 'notification_preference_page.dart';

class NotificationPreferenceCubit extends Cubit<NotificationPreferenceState> {
  final AmityChannel? channel;

  NotificationPreferenceCubit({this.channel})
      : super(const NotificationPreferenceState(
          enabled: false,
          initialEnabled: false,
        )) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      if (channel != null) {
        // Channel notification settings
        final settings = await AmityCoreClient()
            .notifications()
            .channel(channel!.channelId ?? "")
            .getSettings();

        emit(state.copyWith(
          enabled: settings.isEnabled ?? true,
          initialEnabled: settings.isEnabled ?? true,
        ));
      }
    } catch (e) {
      // Default to enabled on error
      emit(state.copyWith(enabled: true, initialEnabled: true));
    }
  }

  void setEnabled(bool value) {
    emit(state.copyWith(enabled: value));
  }

  Future<void> savePreference() async {
    if (channel != null) {
      // Save channel notification settings
      if (state.enabled) {
        await AmityCoreClient()
            .notifications()
            .channel(channel!.channelId ?? "")
            .enable();
      } else {
        await AmityCoreClient()
            .notifications()
            .channel(channel!.channelId ?? "")
            .disable();
      }
    }
    emit(state.copyWith(initialEnabled: state.enabled));
  }
}
