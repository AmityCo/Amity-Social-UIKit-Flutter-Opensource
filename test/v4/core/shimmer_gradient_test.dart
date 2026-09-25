import 'package:amity_uikit_beta_service/v4/core/config_repository.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/core/theme/amity_color_token.dart';
import 'package:flutter_test/flutter_test.dart';

/// PDT-5151. The dark shimmer used to hardcode Color.fromARGB(255,167,167,167)
/// at both ends of the gradient with a dark middle — the light/dark
/// relationship inverted — so every skeleton rested at #A7A7A7, a light grey
/// block on a #191919 sheet. Ten surfaces share this one gradient.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await ConfigRepository().loadConfig();
  });

  for (final style in [AmityThemeStyle.dark, AmityThemeStyle.light]) {
    test('shimmer derives from the skeleton token in $style', () {
      final repo = ConfigRepository();
      repo.setPreferredTheme(style);

      final base =
          repo.resolveToken(null, AmityColorToken.surfaceSkeletonEffectDefault);
      final colors = repo.getShimmerGradient().colors;

      // Every stop is that one token at some alpha — nothing invented.
      for (final c in colors) {
        expect(c.value & 0x00FFFFFF, base.value & 0x00FFFFFF,
            reason: 'a stop drifted off the token: $c vs $base');
      }

      // The sweep peaks in the middle and rests at the ends, the way the light
      // gradient always did and the dark one did not.
      final alphas = colors.map((c) => c.alpha).toList();
      expect(alphas.first, lessThan(alphas[alphas.length ~/ 2]));
      expect(alphas.last, lessThan(alphas[alphas.length ~/ 2]));
    });
  }
}
