import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/core/theme/amity_color_token.dart';
import 'package:amity_uikit_beta_service/v4/core/theme/amity_token_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Hierarchy axis — Figma `Hierachy` (sic), values Default / Subdue.
///
/// Named [defaultHierarchy] rather than `default` because that is a reserved
/// word in Dart; it maps to the `.../Banner/Default/...` half of the token
/// family, and [subdue] to `.../Banner/Subdue/...`.
enum AmityBannerHierarchy { defaultHierarchy, subdue }

/// The Banner atom — a full-bleed notice row.
///
/// Every part resolves through the Banner token family. Chat was previously
/// painting the right surface but borrowing its text colour from the *List*
/// family, which is the kind of drift a shared atom exists to stop.
///
/// Lives under `core/ui/atoms/` because it binds `AmityColorToken` and social
/// must not reach the token system — see the sibling EmptyState atom.
class AmityBanner extends StatelessWidget {
  const AmityBanner({
    super.key,
    this.hierarchy = AmityBannerHierarchy.subdue,
    this.header,
    this.description,
    this.leadingIcon,
    this.trailing,
    this.centered = false,
  });

  final AmityBannerHierarchy hierarchy;

  /// Bold title line. Binds `Text/Banner/{H}/Header/General`.
  final String? header;

  /// Body line. Binds `Text/Banner/{H}/TextDescription/General`.
  final String? description;

  /// SVG asset path for the 16x16 leading glyph, tinted via
  /// `Icon/Banner/{H}/Leading/Icon/General`.
  final String? leadingIcon;

  final Widget? trailing;

  /// Centres the content group. The spec and the Android atom agree this also
  /// changes the inset — 12/16 rather than the default row's 8/16 — so it is one
  /// flag, not two independent knobs.
  final bool centered;

  bool get _isSubdue => hierarchy == AmityBannerHierarchy.subdue;

  static const double _leadingIconSize = 16;

  Color _surface(BuildContext c) => c.amityToken(_isSubdue
      ? AmityColorToken.surfaceBannerSubdueGeneral
      : AmityColorToken.surfaceBannerDefaultGeneral);

  Color _headerColor(BuildContext c) => c.amityToken(_isSubdue
      ? AmityColorToken.textBannerSubdueHeaderGeneral
      : AmityColorToken.textBannerDefaultHeaderGeneral);

  Color _descriptionColor(BuildContext c) => c.amityToken(_isSubdue
      ? AmityColorToken.textBannerSubdueTextDescriptionGeneral
      : AmityColorToken.textBannerDefaultTextDescriptionGeneral);

  Color _leadingIconColor(BuildContext c) => c.amityToken(_isSubdue
      ? AmityColorToken.iconBannerSubdueLeadingIconGeneral
      : AmityColorToken.iconBannerDefaultLeadingIconGeneral);

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        if (header != null)
          Text(
            header!,
            textAlign: centered ? TextAlign.center : TextAlign.start,
            style: AmityTextStyle.captionBold(_headerColor(context)),
          ),
        if (description != null)
          Text(
            description!,
            textAlign: centered ? TextAlign.center : TextAlign.start,
            style: AmityTextStyle.caption(_descriptionColor(context)),
          ),
      ],
    );

    return Container(
      width: double.infinity,
      color: _surface(context),
      padding: EdgeInsets.symmetric(
        vertical: centered ? 12 : 8,
        horizontal: 16,
      ),
      child: Row(
        // The spec's implementation guidance is explicit: vertically centre the
        // leading slot, the content column and the trailing row against each
        // other, whatever their heights.
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment:
            centered ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          if (leadingIcon != null) ...[
            SvgPicture.asset(
              leadingIcon!,
              package: 'amity_uikit_beta_service',
              width: _leadingIconSize,
              height: _leadingIconSize,
              colorFilter: ColorFilter.mode(
                _leadingIconColor(context),
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 16),
          ],
          centered ? Flexible(child: content) : Expanded(child: content),
          if (trailing != null) ...[
            const SizedBox(width: 16),
            trailing!,
          ],
        ],
      ),
    );
  }
}
