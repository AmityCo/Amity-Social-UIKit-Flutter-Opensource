part of 'group_setting_page.dart';

// Cubit implementation
class GroupSettingCubit extends Cubit<GroupSettingState> {
  GroupSettingCubit({required AmityChannel channel, required bool isModerator}) 
      : super(GroupSettingState(
          channel: channel, 
          isLoading: true,
          isModerator: isModerator,
        )) {
    // Just initialize with the loading flag set to false
    _initialize();
  }

  Future<void> _initialize() async {
    // Check the notification settings during initialization
    await refreshNotificationSettings();
    emit(state.copyWith(isLoading: false));
  }

  void updateChannelData(AmityChannel updatedChannel) {
    emit(state.copyWith(
      channel: updatedChannel,
      isLoading: false,
      // Maintain the same moderator status when updating channel data
    ));
  }

  Future<void> refreshNotificationSettings() async {
    try {
      final settings = await AmityCoreClient()
          .notifications()
          .channel(state.channel.channelId ?? "")
          .getSettings();
      
      emit(state.copyWith(
        isNotificationsEnabled: settings.isEnabled ?? false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isNotificationsEnabled: false,
        error: "Failed to load notification settings: $e",
      ));
    }
  }

  Future<void> fetchUpdatedChannel() async {
    try {
      final updatedChannel = await AmityChatClient.newChannelRepository()
          .getChannel(state.channel.channelId ?? "");
      emit(state.copyWith(
        channel: updatedChannel,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: "Failed to fetch updated channel: $e",
        isLoading: false,
      ));
    }
  }

}
