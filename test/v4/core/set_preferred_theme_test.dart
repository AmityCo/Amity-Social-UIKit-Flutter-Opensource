import 'package:amity_uikit_beta_service/v4/core/config_repository.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/utils/config_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    // Asset is absent under test, so this initializes _config to {} —
    // meaning no preferred_theme from config, i.e. system style.
    await ConfigRepository().loadConfig();
  });

  test('setPreferredTheme overrides the resolved theme on the fly', () {
    final repo = ConfigRepository();

    repo.setPreferredTheme(AmityThemeStyle.dark);
    expect(repo.getTheme(null).backgroundColor, darkTheme.backgroundColor);

    repo.setPreferredTheme(AmityThemeStyle.light);
    expect(repo.getTheme(null).backgroundColor, lightTheme.backgroundColor);
  });

  test('setPreferredTheme notifies ConfigProvider listeners', () {
    final provider = ConfigProvider();
    var notified = 0;
    provider.addListener(() => notified++);

    ConfigRepository().setPreferredTheme(AmityThemeStyle.dark);
    expect(notified, 1);

    // Same value again must not spam rebuilds.
    ConfigRepository().setPreferredTheme(AmityThemeStyle.dark);
    expect(notified, 1);

    ConfigRepository().setPreferredTheme(AmityThemeStyle.system);
    expect(notified, 2);

    // Disposed providers must stop listening (no leak, no crash).
    provider.dispose();
    ConfigRepository().setPreferredTheme(AmityThemeStyle.light);
    expect(notified, 2);
  });
}
