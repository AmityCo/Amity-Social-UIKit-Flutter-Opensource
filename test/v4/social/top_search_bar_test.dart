import 'package:amity_uikit_beta_service/v4/core/config_repository.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/core/theme/amity_color_token.dart';
import 'package:amity_uikit_beta_service/v4/social/top_search_bar/top_search_bar.dart';
import 'package:amity_uikit_beta_service/v4/utils/config_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amity_uikit_beta_service/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';

/// PDT-5150. Two things the search bar got wrong on a dark page: the iOS
/// keyboard came up light because keyboardAppearance was never set (Flutter
/// honours that flag on iOS only), and Cancel used the flat theme's primary
/// (#1054DE) where the design binds the ghost main-button label (#4A82F2).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await ConfigRepository().loadConfig();
    ConfigRepository().setPreferredTheme(AmityThemeStyle.dark);
  });

  Future<void> pump(WidgetTester tester) => tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => ConfigProvider(),
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            home: Scaffold(
              body: AmityTopSearchBarComponent(
                textcontroller: TextEditingController(),
                hintText: 'hint',
                onTextChanged: (_) {},
              ),
            ),
          ),
        ),
      );

  testWidgets('the field asks iOS for a keyboard in the app brightness',
      (tester) async {
    await pump(tester);
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.keyboardAppearance, Brightness.dark,
        reason: 'unset, iOS draws its light keyboard under the dark page');
  });

  testWidgets('the engine is handed Brightness.dark for the keyboard',
      (tester) async {
    // Stronger than reading the widget: this is the payload Flutter sends over
    // the TextInput channel when the field takes focus, which is what iOS
    // reads to pick the keyboard's appearance. The pixels belong to the OS, so
    // this is the last point in our control that can be measured.
    await pump(tester);
    await tester.tap(find.byType(TextField));
    await tester.pump();

    final args = tester.testTextInput.setClientArgs;
    expect(args, isNotNull,
        reason: 'the field never attached to the text input channel');
    expect(args!['keyboardAppearance'], 'Brightness.dark',
        reason: 'unset, iOS falls back to its light keyboard — the bug');
  });

  testWidgets('Cancel takes the ghost main-button token', (tester) async {
    await pump(tester);
    final expected = ConfigRepository().resolveToken(
        null, AmityColorToken.textMainButtonDefaultGhostPrimaryEnabled);

    final cancel = tester.widgetList<Text>(find.byType(Text)).last;
    expect(cancel.style?.color, expected);
    expect(cancel.style?.color, isNot(darkTheme.primaryColor),
        reason: 'the flat theme primary is the colour QA reported');
  });
}
