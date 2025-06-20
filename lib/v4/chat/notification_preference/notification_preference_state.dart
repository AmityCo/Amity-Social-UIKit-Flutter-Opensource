part of 'notification_preference_page.dart';

class NotificationPreferenceState extends Equatable {
  final bool enabled;
  final bool initialEnabled;
  bool get hasChanges => enabled != initialEnabled;

  const NotificationPreferenceState({
    required this.enabled,
    required this.initialEnabled,
  });

  NotificationPreferenceState copyWith({
    bool? enabled,
    bool? initialEnabled,
  }) {
    return NotificationPreferenceState(
      enabled: enabled ?? this.enabled,
      initialEnabled: initialEnabled ?? this.initialEnabled,
    );
  }
  
  @override
  List<Object> get props => [enabled, initialEnabled];
}
