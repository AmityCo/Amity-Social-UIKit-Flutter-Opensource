import 'package:amity_uikit_beta_service/v4/core/theme/amity_color_token.dart';
import 'package:amity_uikit_beta_service/v4/core/theme/amity_token_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The close control on the full-screen image and video viewers.
///
/// The design (Figma `10855:17607` / `10855:13108`) draws a 32 Icon Button on
/// `Surface/IconButton/Transparent/Primary/Enabled` holding a 24 `cross-r`
/// glyph in `Icon/IconButton/Transparent/Primary/Default`. That surface is
/// translucent black, so over the player's black canvas it reads as no
/// background — which is how QA described it (PDT-5123).
///
/// It lives here rather than as a private helper in each viewer because the two
/// viewers had already drifted apart once, and this is the one thing about them
/// the design pins.
class AmityMediaViewerCloseButton extends StatelessWidget {
  const AmityMediaViewerCloseButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.amityToken(
            AmityColorToken.surfaceIconButtonTransparentPrimaryEnabled),
      ),
      child: Center(
        child: SvgPicture.asset(
          'assets/Icons/amity_ic_cross_r.svg',
          package: 'amity_uikit_beta_service',
          width: 24,
          height: 24,
          colorFilter: ColorFilter.mode(
              context.amityToken(
                  AmityColorToken.iconIconButtonTransparentPrimaryDefault),
              BlendMode.srcIn),
        ),
      ),
    );
  }
}
