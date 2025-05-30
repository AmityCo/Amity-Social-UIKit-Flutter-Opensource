part of 'notification_preference_page.dart';

class NotificationPreferenceCubit extends Cubit<NotificationPreferenceState> {
  final AmityChannel? channel;
  final AmityUser? user;
  final bool isChannelMode;

  NotificationPreferenceCubit({this.channel, this.user})
      : isChannelMode = channel != null,
        super(NotificationPreferenceState(
          enabled: false,
          initialEnabled: false,
        )) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      if (isChannelMode && channel != null) {
        // Channel notification settings
        final settings = await AmityCoreClient()
            .notifications()
            .channel(channel!.channelId ?? "")
            .getSettings();

        print("Notification settings: ${settings.isEnabled}");

        emit(state.copyWith(
          enabled: settings.isEnabled ?? true,
          initialEnabled: settings.isEnabled ?? true,
        ));
      } else if (user != null) {
        // User notification settings
        // Using metadata for user notification settings
        final enabled = user!.metadata?['notification_enabled'] == 'true';
        emit(state.copyWith(
          enabled: enabled,
          initialEnabled: enabled,
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
    try {
      if (isChannelMode && channel != null) {
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
              
          _showToast("Notifications disabled");
        }
      } else if (user != null) {
        // Save user notification settings to metadata
        await AmityCoreClient.newUserRepository()
            .updateUser(user!.userId!)
            .metadata(
                {'notification_enabled': state.enabled.toString()}).update();
                
        _showToast(state.enabled ? "User notifications enabled" : "User notifications disabled");
      }
      emit(state.copyWith(initialEnabled: state.enabled));
    } catch (e) {
      _showToast("Failed to update notification settings");
    }
  }
  
  void _showToast(String message) {
    // Use BuildContext.findAncestorStateOfType to get context from any widget
    // This should be called within a build method or event handler
    // For simplicity, we'll rely on the caller to handle the toast via the UI
  }
}
