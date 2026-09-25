import 'package:amity_uikit_beta_service/v4/core/config_repository.dart';
import 'package:amity_uikit_beta_service/v4/core/ui/atoms/amity_selection.dart';
import 'package:amity_uikit_beta_service/v4/utils/config_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// PDT-4908. The geometry here is the authoritative Selection atom spec
/// (UIKIT/atoms/Selection/v1.md): 24 hit-area frame, 2 padding so a 20 circle,
/// a 2 ring on Inactive only, and an 8 centre dot. Material's Radio cannot draw
/// it, which is why this atom exists — these asserts fail if someone
/// "simplifies" it back to a Radio or drops the ring.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await ConfigRepository().loadConfig();
  });

  Future<void> pump(WidgetTester tester, {required bool selected}) =>
      tester.pumpWidget(ChangeNotifierProvider(
        create: (_) => ConfigProvider(),
        child: MaterialApp(
          home: Scaffold(
            body: Center(child: AmityRadioSelection(isSelected: selected)),
          ),
        ),
      ));

  BoxDecoration circleOf(WidgetTester tester) {
    final containers = tester
        .widgetList<Container>(find.descendant(
          of: find.byType(AmityRadioSelection),
          matching: find.byType(Container),
        ))
        .toList();
    return containers.first.decoration as BoxDecoration;
  }

  testWidgets('frame is 24 and the circle is 20', (tester) async {
    await pump(tester, selected: false);
    expect(tester.getSize(find.byType(SizedBox).first), const Size(24, 24));
    final circle = find.descendant(
      of: find.byType(AmityRadioSelection),
      matching: find.byType(Container),
    );
    expect(tester.getSize(circle.first), const Size(20, 20));
  });

  testWidgets('inactive carries the 2 ring, active carries none',
      (tester) async {
    await pump(tester, selected: false);
    final inactive = circleOf(tester);
    expect(inactive.border, isNotNull);
    expect((inactive.border as Border).top.width, 2);

    await pump(tester, selected: true);
    expect(circleOf(tester).border, isNull,
        reason: 'an Active disc fills the circle, so the spec gives it no ring');
  });

  testWidgets('the centre dot is 8 and only paints when selected',
      (tester) async {
    await pump(tester, selected: true);
    final dot = find
        .descendant(
          of: find.byType(AmityRadioSelection),
          matching: find.byType(Container),
        )
        .last;
    expect(tester.getSize(dot), const Size(8, 8));
    expect((tester.widget<Container>(dot).decoration as BoxDecoration).color,
        isNot(Colors.transparent));

    await pump(tester, selected: false);
    final hidden = find
        .descendant(
          of: find.byType(AmityRadioSelection),
          matching: find.byType(Container),
        )
        .last;
    expect((tester.widget<Container>(hidden).decoration as BoxDecoration).color,
        Colors.transparent);
  });
}
