part of 'group_setting_page.dart';

// State implementation
class GroupSettingState {
  final AmityChannel channel;
  final bool isLoading;
  final String? error;
  final bool isModerator;
  final bool isNotificationsEnabled;

  const GroupSettingState({
    required this.channel,
    this.isLoading = false,
    this.error,
    this.isModerator = false,
    this.isNotificationsEnabled = false,
  });

  GroupSettingState copyWith({
    AmityChannel? channel,
    bool? isLoading,
    String? error,
    bool? isModerator,
    bool? isNotificationsEnabled,
  }) {
    return GroupSettingState(
      channel: channel ?? this.channel,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isModerator: isModerator ?? this.isModerator,
      isNotificationsEnabled: isNotificationsEnabled ?? this.isNotificationsEnabled,
    );
  }
}
