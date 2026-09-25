import 'dart:io' show Platform;

import 'package:amity_uikit_beta_service/v4/core/config_repository.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/core/theme/amity_color_token.dart';
import 'package:amity_uikit_beta_service/v4/chat/message/message_bubble_view.dart';
import 'package:amity_uikit_beta_service/v4/core/ui/mention/mention_dismiss_button.dart';
import 'package:amity_uikit_beta_service/v4/core/ui/mention/mention_field.dart';
import 'package:amity_uikit_beta_service/v4/social/top_search_bar/top_search_bar.dart';
import 'package:amity_uikit_beta_service/v4/utils/config_provider.dart';
import 'package:amity_uikit_beta_service/v4/utils/shimmer_widget.dart';
import 'package:amity_uikit_beta_service/v4/utils/skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amity_uikit_beta_service/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Renders the three surfaces fixed for PDT-5126 / PDT-5150 / PDT-5151 to PNGs
/// so their composited pixels can be measured, the same way a device
/// screenshot is measured.
///
/// Run with `RENDER_PROOF=1 flutter test test/v4/render_proof_test.dart
/// --update-goldens` to (re)write the images; the measurements are taken from
/// the files afterwards. This is a rendering harness, not an assertion suite —
/// the behavioural assertions live in the sibling tests, and goldens compare
/// byte-for-byte against the host's font rasterisation, so this stays skipped
/// unless asked for by name. CI must never run it.
final _proofRun = Platform.environment.containsKey('RENDER_PROOF');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    // The link preview keeps its metadata cache in shared_preferences, which
    // has no platform implementation under test.
    SharedPreferences.setMockInitialValues({});
    await ConfigRepository().loadConfig();
    ConfigRepository().setPreferredTheme(AmityThemeStyle.dark);
  });

  Widget host(Widget child, {double width = 375, double height = 120}) =>
      ChangeNotifierProvider(
        create: (_) => ConfigProvider(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          home: Scaffold(
            // The page these surfaces sit on, so the measurement sees the same
            // composite a device does.
            backgroundColor: ConfigRepository()
                .resolveToken(null, AmityColorToken.surfacePageBackgroundDefault),
            body: Center(
              child: SizedBox(width: width, height: height, child: child),
            ),
          ),
        ),
      );

  testWidgets('PDT-5150 search bar', (tester) async {
    await tester.pumpWidget(host(
      AmityTopSearchBarComponent(
        textcontroller: TextEditingController(),
        hintText: 'Search',
        onTextChanged: (_) {},
      ),
      height: 60,
    ));
    await expectLater(find.byType(AmityTopSearchBarComponent),
        matchesGoldenFile('proof/pdt5150_search_bar.png'));
  }, skip: !_proofRun);

  testWidgets('PDT-5126 mention popover', (tester) async {
    await tester.pumpWidget(host(
      SuggestionListOverlay(
        itemCount: 2,
        rowHeight: 48,
        suggestionMaxRow: 3,
        scrollController: ScrollController(),
        backgroundColor: ConfigRepository()
            .resolveToken(null, AmityColorToken.surfacePopoverBackgroundDefault),
        borderRadius: BorderRadius.circular(12.0),
        itemBuilder: (_, __) => const SizedBox(height: 48),
      ),
      width: 359,
      height: 112,
    ));
    await expectLater(find.byType(SuggestionListOverlay),
        matchesGoldenFile('proof/pdt5126_mention_popover.png'));
  }, skip: !_proofRun);

  testWidgets('PDT-5126 c2 mention dismiss button', (tester) async {
    await tester.pumpWidget(
        host(const Center(child: AmityMentionDismissButton()), width: 60, height: 60));
    // flutter_svg decodes off the asset bundle asynchronously; without this the
    // golden captures the disc before the glyph has drawn.
    await tester.pumpAndSettle();
    await expectLater(find.byType(AmityMentionDismissButton),
        matchesGoldenFile('proof/pdt5126_dismiss_button.png'));
  }, skip: !_proofRun);

  testWidgets('PDT-5023 reaction row, middle one already reacted',
      (tester) async {
    ReactionItem item(String n, String f, {bool mine = false}) => ReactionItem(
        reaction: AmityReactionType(
            name: n, imagePath: 'assets/Icons/amity_ic_${f}_reaction.svg'),
        isSelected: mine);
    // At the harness's default 1x, the 32 disc behind a 30 glyph is a single
    // antialiased pixel of ring — invisible to a colour scan. Render at 3x so
    // the ring is measurable.
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(host(
      ReactionRow(
        reactions: [
          item('like', 'like'),
          item('love', 'heart', mine: true),
          item('fire', 'fire'),
        ],
        onReactionSelected: (_, __) {},
        theme: ConfigRepository().getTheme(null),
      ),
      width: 208,
      height: 52,
    ));
    await expectLater(find.byType(ReactionRow),
        matchesGoldenFile('proof/pdt5023_reaction_row.png'));
  }, skip: !_proofRun);

  testWidgets('PDT-5151 skeleton shimmer', (tester) async {
    await tester.pumpWidget(host(
      Shimmer(
        linearGradient: ConfigProvider().getShimmerGradient(),
        child: const ShimmerLoading(
          isLoading: true,
          child: Row(
            children: [
              SizedBox(width: 16),
              SkeletonImage(width: 40, height: 40, borderRadius: 40),
              SizedBox(width: 12),
              SkeletonText(width: 180, height: 10),
            ],
          ),
        ),
      ),
      height: 56,
    ));
    await tester.pump(const Duration(milliseconds: 100));
    await expectLater(find.byType(Shimmer),
        matchesGoldenFile('proof/pdt5151_skeleton.png'));
  }, skip: !_proofRun);
}
