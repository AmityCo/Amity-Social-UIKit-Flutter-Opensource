import 'package:amity_uikit_beta_service/v4/core/config_repository.dart';
import 'package:amity_uikit_beta_service/v4/core/ui/message_error_badge.dart';
import 'package:amity_uikit_beta_service/v4/utils/config_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// PDT-5115. The badge used to draw amity_ic_error_message.svg, a filled disc
/// with the exclamation knocked out of it — tint that light and you get a light
/// disc, which is the white badge QA reported. These two asserts fail if anyone
/// points it back at the knockout asset or drops the disc behind the glyph.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    // Absent asset under test leaves the config empty, which is enough: the
    // badge only needs a provider to read tokens through.
    await ConfigRepository().loadConfig();
  });

  testWidgets('draws the exclamation glyph, not the knockout disc',
      (tester) async {
    await tester.pumpWidget(ChangeNotifierProvider(
      create: (_) => ConfigProvider(),
      child: const MaterialApp(
        home: Scaffold(body: Center(child: AmityMessageErrorBadge())),
      ),
    ));

    final svg = tester.widget<SvgPicture>(find.byType(SvgPicture));
    final loader = svg.bytesLoader as SvgAssetLoader;
    expect(loader.assetName,
        'assets/Icons/amity_ic_error_message_glyph.svg',
        reason: 'the knockout asset cannot show a white exclamation on a dark '
            'page — see the widget doc');

    final box = tester.widget<Container>(find.descendant(
      of: find.byType(AmityMessageErrorBadge),
      matching: find.byType(Container),
    ));
    final decoration = box.decoration as BoxDecoration;
    expect(decoration.shape, BoxShape.circle);
    expect(decoration.color, isNotNull,
        reason: 'the glyph needs the disc behind it; bare on the page it is '
            'the old bug in the other direction');
  });
}
