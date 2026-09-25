import 'package:amity_uikit_beta_service/v4/core/theme/amity_color_token.dart';
import 'package:amity_uikit_beta_service/v4/core/theme/amity_token_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The failed-to-send badge beside a message bubble.
///
/// The design (Figma `10848:54753`) draws a 24 disc measuring `#0A0A0A` on the
/// dark page with a white exclamation inside — and `#0A0A0A` is exactly
/// `Surface/IconButton/Transparent/Primary/Enabled` (`#00000099`) composited
/// over `Surface/Page/Background/Default` (`#191919`), so the disc is that
/// token rather than a new near-black one.
///
/// The glyph is `amity_ic_error_message_glyph.svg`, not
/// `amity_ic_error_message.svg`: the latter is a filled disc with the
/// exclamation knocked *out* of it, so tinting it a light colour paints a light
/// disc with a page-coloured exclamation — which is the white badge QA reported
/// (PDT-5115). A knockout can never show a white exclamation on a dark page, so
/// the glyph has to be its own shape drawn on top of the disc.
///
/// Four call sites had four different constructions of this badge (bare red
/// glyph, bare grey glyph, disc-on-circle, disc alone); they all use this now.
class AmityMessageErrorBadge extends StatelessWidget {
  const AmityMessageErrorBadge({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final badge = Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.amityToken(
            AmityColorToken.surfaceIconButtonTransparentPrimaryEnabled),
      ),
      // 20 in a 24 disc puts the glyph at the design's 10 tall.
      child: SvgPicture.asset(
        'assets/Icons/amity_ic_error_message_glyph.svg',
        package: 'amity_uikit_beta_service',
        width: 20,
        height: 20,
        colorFilter: ColorFilter.mode(
            context.amityToken(
                AmityColorToken.iconIconButtonTransparentPrimaryDefault),
            BlendMode.srcIn),
      ),
    );

    if (onTap == null) return badge;
    return GestureDetector(onTap: onTap, child: badge);
  }
}
