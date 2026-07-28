import 'package:flutter/foundation.dart';

/// Runtime signaling channel between the host app and the SDK for the
/// preferred theme.
///
/// The SDK is a lower-level dependency than the app, so it cannot import the
/// app's `AppThemeMode`/`AppTheme`. This notifier serves as the entry point:
/// the app pushes the effective theme (`'light'`, `'dark'`, `'system'`, or
/// `null` to use the value from `config.json`) whenever the user changes the
/// theme, and the [ConfigProvider] listens for updates and re-renders the
/// screens.
///
/// Stores only the preferred theme value—not the SDK configuration, which is
/// no longer a singleton and now lives within the [ConfigProvider] instance.
class AmityThemePreference {
  AmityThemePreference._();

  static final ValueNotifier<String?> notifier = ValueNotifier<String?>(null);

  /// Sets the preferred theme at runtime. Accepts `'light'`, `'dark'`, `'system'`,
  /// or `null` (uses the value from `config.json`).
  static void set(String? preferredTheme) {
    notifier.value = preferredTheme;
  }
}
