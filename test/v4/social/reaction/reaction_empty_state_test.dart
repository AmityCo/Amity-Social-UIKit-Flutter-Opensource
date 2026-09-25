import 'package:amity_uikit_beta_service/l10n/generated/app_localizations.dart';
import 'package:amity_uikit_beta_service/v4/core/config_repository.dart';
import 'package:amity_uikit_beta_service/v4/core/ui/atoms/amity_empty_state.dart';
import 'package:amity_uikit_beta_service/v4/utils/config_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// PDT-5145 case 2. The reaction sheet used to keep its skeleton on screen
/// forever once the last reaction was removed; it now draws the EmptyState atom
/// with the smile-plus glyph and the two strings below.
///
/// The sheet itself cannot be pumped — it needs a live SDK session — so this
/// pins the two things that break silently: the glyph asset (a wrong path draws
/// nothing at all, with no error) and the copy, whose description carries a
/// placeholder and so is easy to break in the .arb.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await ConfigRepository().loadConfig();
  });

  testWidgets('the empty state draws the smile-plus glyph', (tester) async {
    await tester.pumpWidget(ChangeNotifierProvider(
      create: (_) => ConfigProvider(),
      child: const MaterialApp(
        home: Scaffold(
          body: AmityEmptyState(
            variant: AmityEmptyStateVariant.icon,
            asset: 'assets/Icons/amity_ic_smile_plus_r.svg',
            title: 'No reactions yet',
            description: 'Be the first to react to this message!',
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    final svg = tester.widget<SvgPicture>(find.byType(SvgPicture));
    expect((svg.bytesLoader as SvgAssetLoader).assetName,
        'assets/Icons/amity_ic_smile_plus_r.svg');
    expect(tester.getSize(find.byType(SvgPicture)), const Size(64, 64),
        reason: 'the EmptyState icon slot is 64 per the atom spec');
  });

  test('the empty-state copy matches the other platforms', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(l10n.reaction_no_reactions_yet, 'No reactions yet');
    expect(l10n.reaction_be_first_to_react('message'),
        'Be the first to react to this message!');
  });
}
