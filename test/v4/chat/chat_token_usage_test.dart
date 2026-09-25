import 'dart:convert';
import 'dart:io';

import 'package:amity_uikit_beta_service/v4/core/theme/amity_color_token.dart';
import 'package:amity_uikit_beta_service/v4/core/theme/amity_theme_defaults.dart';
import 'package:amity_uikit_beta_service/v4/core/theme/amity_token_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards the Chat migration at the level a reviewer cannot: it reads the Chat
/// source, collects every token the widgets actually name, and checks each one
/// end to end.
///
/// A wrong-but-valid token is a design review question. A token that resolves to
/// magenta, or a leftover flat-theme reference, is a defect — and neither shows
/// up in `flutter analyze`.
/// Chat renders through these, and nothing else owns them.
const chatOwnedOutsideTheDirectory = [
  'lib/v4/utils/message_color.dart',
  'lib/v4/core/channel_avatar.dart',
];

/// Shared with Social, so still on the flat theme by design — migrating them is
/// Social's plan, not this one. Listed rather than ignored: Chat visibly renders
/// each of these, so "Chat is migrated" is true of the directory and not yet of
/// the surface. The counts are pinned so the debt cannot grow unnoticed, and so
/// the next person can see exactly what is left.
const sharedWithSocialStillFlat = <String, int>{
  // 25 → 24: the "+ Add" member chip now binds the IconButton tokens (PDT-4900).
  'lib/v4/core/shared/user/user_list.dart': 24,
  'lib/v4/social/reaction/reaction_list.dart': 13,
  // 12 → 9: the mention popover's surface and its dismiss button bind Popover
  // and IconButton tokens now (PDT-5126).
  // PDT-5126, one QA round each: 9 -> 8 the @All row's primaryColor tint,
  // 8 -> 7 its featured-icon disc, 7 -> 4 the three display-name labels and
  // the "Notify everyone" trailing label. The picker's rows carry no
  // flat-theme colour now; mention_popover_test pins that.
  'lib/v4/core/ui/mention/mention_field.dart': 4,
  // 8 → 7: the search bar's Cancel label binds the ghost MainButton token
  // (PDT-5150).
  'lib/v4/social/top_search_bar/top_search_bar.dart': 7,
  'lib/v4/core/base_component.dart': 3,
  'lib/v4/core/base_page.dart': 3,
  // amity_uikit_toast.dart left the list: it is the Toast atom now (PDT-4903).
  'lib/v4/utils/skeleton.dart': 2,
};

/// Raw colours still hardcoded in Chat, per file.
///
/// Nothing checked for these before: the guards looked for `theme.` and for
/// token validity, and a literal `Colors.white` is neither. Two of them were
/// theme values written out by hand — the failed-to-send label carried
/// `#FA4D30`, which IS `alert_color`, so re-theming it changed everything
/// except that label.
///
/// What is left is pinned rather than ignored. Most of it is the camera page,
/// which is fixed chrome over a live preview and arguably should not be
/// themed at all; the rest is scrims, shadows and button labels that want a
/// design decision, not a mechanical swap. `Colors.transparent` is excluded —
/// it is a hit target, not a colour.
const rawColoursStillHardcoded = <String, int>{
  'lib/v4/chat/message_composer/message_camera_page.dart': 13,
  'lib/v4/chat/message/message_bubble_view.dart': 4,
  'lib/v4/chat/message/widgets/message_popup.dart': 3,
  'lib/v4/chat/message/components/amity_message_report_reason_component.dart': 2,
  'lib/v4/chat/message/widgets/message_link_preview_widget.dart': 2,
  'lib/v4/chat/archive/archived_chat_page.dart': 1,
  // 4 → 1 each: the scrim, the two grey underlines and the camera glyph went to
  // tokens (PDT-4900 / PDT-4906); the over-limit `Colors.red` counter remains.
  'lib/v4/chat/createGroup/ui/amity_create_group_page.dart': 1,
  'lib/v4/chat/edit_group_profile/amity_edit_group_profile_page.dart': 1,
  'lib/v4/chat/group_message/amity_group_chat_page.dart': 1,
  'lib/v4/chat/group_message/widgets/group_chat_page_helpers.dart': 1,
  'lib/v4/chat/home/base_chat_list_component.dart': 1,
  'lib/v4/chat/message/chat_page.dart': 1,
  // amity_message_report_component.dart is clean: Submit label and the radio
  // dot bind MainButton / Selection tokens (PDT-4922).
  'lib/v4/chat/message/components/message_report_error_component.dart': 1,
  'lib/v4/chat/message/message_avatar.dart': 1,
  'lib/v4/chat/message/widgets/generic_widget.dart': 1,
  'lib/v4/chat/message/widgets/text_message_widget.dart': 1,
  'lib/v4/chat/message_composer/message_composer.dart': 1,
  // chat_home_page.dart (app-bar iconTheme, PDT-4868) and
  // chat_list_empty_state.dart (CTA label, PDT-4868) are clean.
};

void main() {
  late List<String> chatSources;
  late AmityTokenTable table;

  setUpAll(() {
    chatSources = [
      ...Directory('lib/v4/chat')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart')),
      // Chat-owned files that do not live under lib/v4/chat. message_color is
      // the bubble's whole palette and was where the worst flattening happened,
      // yet a directory-shaped scan never saw it.
      ...chatOwnedOutsideTheDirectory.map(File.new),
    ].map((f) => f.readAsStringSync()).toList();
    table = AmityTokenResolver.tableFromJson(
        jsonDecode(File('assets/tokens/amity-uikit-design-tokens.json')
            .readAsStringSync()) as Map<String, dynamic>);
  });

  // The whitespace is load-bearing, for the second time in this file: the
  // formatter wraps long names as `AmityColorToken\n    .textChatBubble…`, and
  // `AmityColorToken\.` walks past every one. Nine tokens across twenty-six
  // call sites were invisible here — and to the spec generator, which shares
  // this pattern, so the published tables were missing them too.
  Set<String> tokensUsed() => {
        for (final src in chatSources)
          ...RegExp(r'AmityColorToken\s*\.\s*(\w+)')
              .allMatches(src)
              .map((m) => m.group(1)!)
      };

  test('Chat names no token that does not exist', () {
    final known = {for (final t in AmityColorToken.values) t.name};
    expect(tokensUsed().difference(known), isEmpty);
  });

  test('Chat has no flat-theme references left', () {
    // `theme.<colour>` — the pre-migration accessor. The import line
    // (`core/theme.dart`) is not a reference, hence the exclusion of `dart`.
    //
    // The whitespace in the middle is load-bearing: the formatter wraps long
    // chains as `theme\n    .secondaryColor`, and a `\btheme\.` pattern walks
    // straight past those. Six such references survived the migration and the
    // first version of this test.
    final leftovers = <String>[];
    for (final src in chatSources) {
      for (final m
          in RegExp(r'\btheme\s*\.\s*([a-zA-Z]\w*)', multiLine: true)
              .allMatches(src)) {
        if (m.group(1) != 'dart') leftovers.add(m.group(0)!.replaceAll('\n', ' '));
      }
    }
    expect(leftovers, isEmpty);
  });

  test('no resolved token is then shifted by blend() or darken()', () {
    // A token put through a colour transform is not a token: the customer sets
    // the key and still gets something else. Every one of these was a
    // derivation standing in for a state token that already exists.
    final shifted = <String>[];
    for (final src in chatSources) {
      for (final m in RegExp(
              r'AmityColorToken\s*\.\s*\w+\)\s*\n?\s*\.(blend|darken)\(',
              multiLine: true)
          .allMatches(src)) {
        shifted.add(m.group(0)!.replaceAll(RegExp(r'\s+'), ' '));
      }
    }
    expect(shifted, isEmpty);
  });

  test('every token Chat uses resolves to a real colour, not magenta', () {
    const config =
        AmityTokenConfig(theme: kAmityThemeDefaults, customizations: {});
    final byName = {for (final t in AmityColorToken.values) t.name: t};

    final magenta = <String>[];
    for (final name in tokensUsed()) {
      final token = byName[name];
      if (token == null) continue; // covered by the first test
      for (final mode in ['light', 'dark']) {
        final resolved = AmityTokenResolver.resolveToken(
            config, table, null, mode, token.path);
        if (resolved.value == AmityTokenResolver.missingColor) {
          magenta.add('$name[$mode] (${token.path})');
        }
      }
    }
    expect(magenta, isEmpty);
  });

  test('Chat uses a substantial part of the token set', () {
    // A floor, not a target: if a refactor collapses the migration back onto a
    // handful of tokens, that is a regression worth noticing.
    expect(tokensUsed().length, greaterThan(60));
  });

  // The exclusion list above is a claim about how much of the Chat surface is
  // still flat-theme. Pin it: if one of these grows a reference the debt is
  // bigger than the PR said, and if one shrinks to zero it should move into
  // chatOwnedOutsideTheDirectory or off the list entirely.
  test('the Social-shared flat-theme debt is exactly what was declared', () {
    final actual = <String, int>{};
    for (final path in sharedWithSocialStillFlat.keys) {
      final src = File(path).readAsStringSync();
      actual[path] = RegExp(r'\btheme\s*\.\s*([a-zA-Z]\w*)')
          .allMatches(src)
          .where((m) => m.group(1) != 'dart')
          .length;
    }
    expect(actual, sharedWithSocialStillFlat);
  });

  // A colour written as a literal is outside the token system entirely — no
  // config reaches it, in either mode. Pin the remainder so it can only shrink.
  test('the raw-colour debt is exactly what was declared', () {
    final pattern = RegExp(
        r'Colors\.(?!transparent)[a-zA-Z]+'
        r'|Color\(0x[0-9A-Fa-f]{8}\)'
        r'|Color\.fromARGB\([^)]*\)');
    final actual = <String, int>{};
    for (final f in Directory('lib/v4/chat')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      final n = pattern.allMatches(f.readAsStringSync()).length;
      if (n > 0) actual[f.path] = n;
    }
    expect(actual, rawColoursStillHardcoded);
  });

  // Three widgets draw an avatar disc, and each had drifted to its own colour:
  // the channel one was right, the message one was on a *button* token, and the
  // user one computed a shade off primaryColor. All three read as pale blue on
  // white, so nothing looked wrong until the three pages were laid side by side
  // in dark. Neither the magenta check nor the flat-theme count can see this —
  // a plausible token in the wrong role passes both.
  //
  // The avatar flip is not in the palette (every rung of the primary ramp is
  // the same hex in both modes); it is the token pointing at shade2 on light
  // and shade1 on dark. So a computed shade can never express it, and the only
  // correct binding is the token itself.
  test('every avatar disc binds the same token', () {
    // Four, not three — user_image.dart is the one that actually renders the
    // member-picker row, reached through AmityUserImage rather than
    // AmityUserAvatar. Fixing the other three left p8 unchanged on device,
    // which is how it surfaced. Keep this list closed by grepping for the
    // disc idiom, not by memory.
    const avatarWidgets = [
      'lib/v4/core/channel_avatar.dart',
      'lib/v4/core/user_avatar.dart',
      'lib/v4/utils/user_image.dart',
      'lib/v4/chat/message/message_avatar.dart',
    ];
    final wrong = <String>[];
    for (final path in avatarWidgets) {
      final src = File(path).readAsStringSync();
      if (!src.contains('AmityColorToken.surfaceAvatarProfileDefault')) {
        wrong.add(path);
      }
    }
    expect(wrong, isEmpty,
        reason: 'an avatar disc must resolve Surface/Avatar/Profile/Default, '
            'not a neighbouring colour that happens to look similar on white');
  });
}
