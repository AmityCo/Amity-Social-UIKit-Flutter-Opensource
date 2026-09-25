import 'dart:io';

import 'package:amity_uikit_beta_service/v4/core/ui/mention/mention_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// PDT-5126 case 1. The mention list is a Popover in the design: 359x112,
/// radius 12, Surface/Popover/Background/Default, and **no border**. It used to
/// paint theme.backgroundColor — #191919, the colour of the chat page right
/// behind it — inside a hardcoded Colors.grey.withOpacity(0.2) outline.
///
/// The overlay itself only renders inside an Overlay with a live mention
/// controller, so this pins the panel widget the two overlay branches share:
/// it must honour the colour handed to it and add no outline of its own.
void main() {
  testWidgets('the panel takes its surface and draws no border',
      (tester) async {
    const surface = Color(0xFF292B32);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SuggestionListOverlay(
          itemCount: 2,
          rowHeight: 48,
          suggestionMaxRow: 3,
          scrollController: ScrollController(),
          backgroundColor: surface,
          borderRadius: BorderRadius.circular(12.0),
          itemBuilder: (_, __) => const SizedBox(height: 48),
        ),
      ),
    ));

    final container = tester.widget<AnimatedContainer>(
      find.byType(AnimatedContainer),
    );
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.color, surface,
        reason: 'the panel must paint the surface it is given, not the page');
    expect(decoration.border, isNull,
        reason: 'the design has no outline on the Popover');
    expect(decoration.borderRadius, BorderRadius.circular(12.0));
  });

  // PDT-5126 case 1, round 2. The test above pins the *panel* — and the panel
  // was right all along. What QA failed was a **row**: the pinned "@All" row
  // painted `primaryColor.withOpacity(0.05)`, which composites to #272D3B over
  // the popover and reads as a highlight the design does not have. A test that
  // only checks the container can never see that, which is how it shipped.
  //
  // The spec gives the @All row no fill of its own — "two rows sit on a shared
  // row surface" (AmityMentionPicker/v2), each Surface/Popover/Lists/Default —
  // and Android draws both rows through one shared Row with that background.
  // So the contract is: every row builder binds that token and invents nothing.
  //
  // This reads the source because the builders are private to the State and the
  // overlay renders only with a live mention controller — the same reason the
  // panel test pins the shared widget instead of the picker.
  test('every mention row binds the shared row surface and invents no fill',
      () {
    final source =
        File('lib/v4/core/ui/mention/mention_field.dart').readAsStringSync();

    const builders = [
      '_buildAllMentionRow',
      '_buildUserRow',
      '_buildMemberRow',
    ];

    for (final name in builders) {
      final start = source.indexOf('Widget $name');
      expect(start, isNot(-1), reason: '$name no longer exists — retarget me');

      // Slice to the next builder so each body is checked on its own.
      var end = source.length;
      for (final other in builders) {
        if (other == name) continue;
        final i = source.indexOf('Widget $other');
        if (i > start && i < end) end = i;
      }
      final body = source.substring(start, end);

      expect(
        body.contains(
            'context.amityToken(AmityColorToken.surfacePopoverListsDefault)'),
        isTrue,
        reason: '$name must paint Surface/Popover/Lists/Default',
      );
      expect(
        body.contains('withOpacity'),
        isFalse,
        reason: '$name must not tint its own background — that is the '
            'primaryColor.withOpacity(0.05) defect QA failed',
      );
    }
  });

  // The @All row's featured icon, same spec section. The disc is
  // Surface/FeaturedIcon/Solid and the at-s glyph is Icon/FeaturedIcon/Solid
  // at 24 — Android binds both tokens and uses 24.dp. Flutter hardcoded
  // primaryColor and Colors.white, which happen to resolve to the same pixels
  // today, and drew the glyph at 16, which does not: more of the disc showed
  // than on Android and the icon read heavier.
  test('the @All featured icon binds its tokens and draws the glyph at 24',
      () {
    final source =
        File('lib/v4/core/ui/mention/mention_field.dart').readAsStringSync();
    final start = source.indexOf('Widget _buildAllMentionRow');
    final end = source.indexOf('Widget _buildUserRow');
    expect(start, isNot(-1));
    expect(end, greaterThan(start));
    // Strip line comments: the comment above this widget names the very
    // identifiers being banned, and matching prose is not matching code.
    final body = source
        .substring(start, end)
        .split('\n')
        .where((l) => !l.trimLeft().startsWith('//'))
        .join('\n');

    expect(
      body.contains(
          'context.amityToken(AmityColorToken.surfaceFeaturedIconSolid)') ||
          body.contains('amityToken(AmityColorToken.surfaceFeaturedIconSolid)'),
      isTrue,
      reason: 'the 32 disc must bind Surface/FeaturedIcon/Solid',
    );
    expect(
      body.contains('AmityColorToken.iconFeaturedIconSolid'),
      isTrue,
      reason: 'the at-s glyph must bind Icon/FeaturedIcon/Solid',
    );
    expect(
      body.contains('Colors.white'),
      isFalse,
      reason: 'the glyph colour must come from a token, not Colors.white',
    );
    expect(
      body.contains('widget.theme.primaryColor'),
      isFalse,
      reason: 'the disc must come from the featured-icon token, not the '
          'theme primary — they coincide today and would not if a customer '
          'themed the featured icon on its own',
    );
    expect(
      RegExp(r'width:\s*24,\s*height:\s*24').hasMatch(body),
      isTrue,
      reason: 'the at-s glyph is 24x24 in the spec and 24.dp on Android',
    );
    expect(
      body.contains("assets/Icons/amity_ic_at_s.svg"),
      isTrue,
      reason: 'the row must draw the spec/Android at-s asset, not the legacy '
          'tight-cropped amity_ic_mention_all.svg',
    );
  });

  // The whole row, not one element at a time. Three separate QA rounds each
  // found one more binding in this row still on the flat theme — the row fill,
  // then the featured icon, then the trailing label, which rendered
  // theme.baseColorShade3 (#40434E) on the popover's #292B32 and was
  // effectively unreadable. Pinning every element the spec names so the next
  // one cannot be found the same way.
  test('no row in the mention picker paints from the flat theme', () {
    final source =
        File('lib/v4/core/ui/mention/mention_field.dart').readAsStringSync();

    const builders = [
      '_buildAllMentionRow',
      '_buildUserRow',
      '_buildMemberRow',
    ];
    for (final name in builders) {
      final start = source.indexOf('Widget $name');
      // Bound at the next member declaration, not at the next builder in the
      // list — the last builder would otherwise run to end of file and pick up
      // the TextField's own style, which is not a picker row.
      final next = RegExp(r'\n  (Widget|void|bool|String|Future|double) ')
          .firstMatch(source.substring(start + 1));
      final end = next == null ? source.length : start + 1 + next.start;
      final body = source
          .substring(start, end)
          .split('\n')
          .where((l) => !l.trimLeft().startsWith('//'))
          .join('\n');

      expect(
        RegExp(r'widget\.theme\.\w*[Cc]olor').hasMatch(body),
        isFalse,
        reason: '$name still reads a colour off the flat theme; every colour '
            'in these rows is a semantic token in AmityMentionPicker/v2',
      );
    }

    // And the two text tokens the spec names by role.
    final all = source.substring(
      source.indexOf('Widget _buildAllMentionRow'),
      source.indexOf('Widget _buildUserRow'),
    );
    expect(all.contains('AmityColorToken.textListHeaderDefaultDefault'), isTrue,
        reason: 'the "All" label is Text/List/Header/Default/Default');
    expect(all.contains('AmityColorToken.textListTrailingTextGeneral'), isTrue,
        reason: 'the "Notify everyone" label is Text/List/Trailing/Text/General');
  });

  // The box size is meaningless without the asset's own padding, which is how
  // drawing the tight-cropped glyph at the spec's 24 came out tighter than the
  // 16 it replaced. at-s.svg is a 24 viewBox whose ink spans 3..21 — 18 units
  // with 3 units of padding — so inside the 32 disc it covers 18/32. A
  // tight-cropped replacement would silently cover 24/32 again.
  test('the at-s asset carries the padding the 24 box assumes', () {
    final svg = File('assets/Icons/amity_ic_at_s.svg').readAsStringSync();
    expect(svg.contains('viewBox="0 0 24 24"'), isTrue,
        reason: 'at-s is drawn on a 24 viewBox');

    final d = RegExp('[dD]="([^"]+)"')
        .allMatches(svg)
        .map((m) => m.group(1)!)
        .join(' ');
    final nums = RegExp(r'-?\d+\.?\d*')
        .allMatches(d)
        .map((m) => double.parse(m.group(0)!))
        .toList();
    final xs = [for (var i = 0; i < nums.length; i += 2) nums[i]];
    final ink = xs.reduce((a, b) => a > b ? a : b) -
        xs.reduce((a, b) => a < b ? a : b);

    // 18 of 24, i.e. 0.75 of the box and 18/32 = 0.5625 of the disc.
    expect(ink, closeTo(18, 1),
        reason: 'the glyph must keep ~3 units of padding inside its 24 box; '
            'a tight crop here renders wider than Android at the same size');
  });
}
