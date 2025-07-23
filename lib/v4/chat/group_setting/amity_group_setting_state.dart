part of 'amity_group_setting_page.dart';

// State implementation
class AmityGroupSettingState {
  final AmityChannel channel;
  final bool isLoading;
  final String? error;
  final bool isModerator;
  final bool isNotificationsEnabled;

  const AmityGroupSettingState({
    required this.channel,
    this.isLoading = false,
    this.error,
    this.isModerator = false,
    this.isNotificationsEnabled = false,
  });

  AmityGroupSettingState copyWith({
    AmityChannel? channel,
    bool? isLoading,
    String? error,
    bool? isModerator,
    bool? isNotificationsEnabled,
  }) {
    return AmityGroupSettingState(
      channel: channel ?? this.channel,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isModerator: isModerator ?? this.isModerator,
      isNotificationsEnabled: isNotificationsEnabled ?? this.isNotificationsEnabled,
    );
  }
}
