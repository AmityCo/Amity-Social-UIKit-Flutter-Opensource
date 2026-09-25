import 'package:amity_uikit_beta_service/v4/chat/home/base_chat_list_component.dart';
import 'package:flutter_test/flutter_test.dart';

/// The highlight rule behind PDT-4919: every case-insensitive, non-overlapping
/// occurrence, anywhere in the text — Android's `AmityChatListItem` rule.
void main() {
  test('matches anywhere, not only at word starts', () {
    expect(findCaseInsensitiveMatches('this is a test', 'test'), [10]);
    expect(findCaseInsensitiveMatches('retest', 'test'), [2]);
    expect(findCaseInsensitiveMatches('test reply', 'test'), [0]);
  });

  test('is case-insensitive and reports every occurrence', () {
    expect(findCaseInsensitiveMatches('Test, TEST, tested', 'test'), [0, 6, 12]);
  });

  test('does not overlap and ignores an empty query', () {
    expect(findCaseInsensitiveMatches('aaaa', 'aa'), [0, 2]);
    expect(findCaseInsensitiveMatches('anything', ''), isEmpty);
    expect(findCaseInsensitiveMatches('', 'x'), isEmpty);
  });
}
