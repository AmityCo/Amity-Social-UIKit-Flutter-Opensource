// The token table reaches the running app through rootBundle
// (config_repository.dart `_loadJsonAsset`), so it must be declared under
// `flutter: assets:` in pubspec.yaml. Every other test in this directory reads
// the same file with `File()`, straight off disk, and therefore passes whether
// or not the asset is declared. That gap is not theoretical: a trunk merge once
// dropped the asset line, all 82 of those tests stayed green, and the build
// shipped with every token resolving to the loud magenta miss colour.
//
// This is the only test that fails in that case.
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('the token table is bundled as an asset, not merely present on disk',
      () async {
    final raw = await rootBundle
        .loadString('assets/tokens/amity-uikit-design-tokens.json');
    expect(raw, isNotEmpty);
  });
}
