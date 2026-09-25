import 'package:amity_uikit_beta_service/v4/core/theme/amity_color_token.dart';
import 'package:amity_uikit_beta_service/v4/core/theme/amity_token_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The dismiss control on the mention suggestion panel.
///
/// Design (Figma `10887:76674`): a 24 Icon Button on
/// `Surface/IconButton/Filled/Secondary/Enabled` — #636878 on the dark palette
/// — holding a 16 cross glyph in `Icon/IconButton/Filled/Secondary/Default`,
/// sitting 8 above the panel's top right.
///
/// It used to be a bare `Material` with no colour, so its disc came from
/// `ThemeData`'s light canvas, wrapped around `amity_ic_close_viewer.svg`,
/// which bakes its own 80%-opaque white circle (PDT-5126 case 2).
///
/// A widget rather than a method on the field's state so its pixels can be
/// rendered and measured — the field itself needs a live SDK session to build.
class AmityMentionDismissButton extends StatelessWidget {
  const AmityMentionDismissButton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.amityToken(
              AmityColorToken.surfaceIconButtonFilledSecondaryEnabled),
        ),
        child: SvgPicture.asset(
          'assets/Icons/amity_ic_cross_r.svg',
          package: 'amity_uikit_beta_service',
          width: 16,
          height: 16,
          colorFilter: ColorFilter.mode(
              context.amityToken(
                  AmityColorToken.iconIconButtonFilledSecondaryDefault),
              BlendMode.srcIn),
        ),
      ),
    );
  }
}
