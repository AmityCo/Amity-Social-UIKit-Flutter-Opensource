import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/core/theme/amity_color_token.dart';
import 'package:amity_uikit_beta_service/v4/core/theme/amity_token_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Which artwork slot the state draws, per the EmptyState atom spec.
///
/// The two differ in more than size: the icon slot is a glyph and is tinted with
/// `Icon/EmptyState/Icon/Default`, while the illustration slot is a finished
/// asset that carries its own colour and must not be tinted.
enum AmityEmptyStateVariant {
  /// 64x64 glyph, tinted.
  icon,

  /// 160x160 artwork, drawn as authored.
  illustration,
}

/// The EmptyState atom.
///
/// Lives under `core/ui/atoms/` rather than `core/ui/` because the atoms bind
/// `AmityColorToken` and social must not reach the token system — social already
/// imports six widgets straight out of `core/ui/`, so anything token-bound added
/// there would leak into it without a single token named in social's own source.
///
/// Actions stay a caller-supplied [action] widget: every real empty state routes
/// somewhere specific, and that navigation belongs at the call site.
class AmityEmptyState extends StatelessWidget {
  const AmityEmptyState({
    super.key,
    required this.title,
    this.description,
    this.asset,
    this.assetDark,
    this.variant = AmityEmptyStateVariant.illustration,
    this.action,
  });

  /// Headline. Binds `Text/EmptyState/Title/Default`.
  final String title;

  /// Optional supporting line. Binds `Text/EmptyState/Description/Default`.
  final String? description;

  /// SVG asset path within this package, or null to draw no artwork.
  final String? asset;

  /// Dark-mode counterpart of [asset].
  ///
  /// An illustration is multi-tone, so there is no single fill a colorFilter
  /// could re-theme — the artwork itself has to change. The pair lives on the
  /// atom rather than at the call site so a consumer cannot forget the dark one
  /// and silently ship the light artwork on a dark page; Android's atom carries
  /// the same illustrationLight/illustrationDark pair. Null falls back to
  /// [asset], which is correct for single-tone icons since those are tinted.
  final String? assetDark;

  final AmityEmptyStateVariant variant;

  /// Optional call to action rendered below the text.
  final Widget? action;

  static const double _iconSlot = 64;
  static const double _illustrationSlot = 160;

  @override
  Widget build(BuildContext context) {
    final isIcon = variant == AmityEmptyStateVariant.icon;
    final slot = isIcon ? _iconSlot : _illustrationSlot;
    final art = (context.amityIsDarkTheme ? assetDark : null) ?? asset;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (art != null) ...[
            SvgPicture.asset(
              art,
              package: 'amity_uikit_beta_service',
              width: slot,
              height: slot,
              // The slot is fixed and the artwork keeps its own aspect inside it.
              fit: BoxFit.contain,
              colorFilter: isIcon
                  ? ColorFilter.mode(
                      context.amityToken(AmityColorToken.iconEmptyStateIconDefault),
                      BlendMode.srcIn,
                    )
                  : null,
            ),
            // The icon sits inside the content block (gap 8); the illustration
            // is a sibling of that block, so it sits at the root gap of 4.
            SizedBox(height: isIcon ? 8 : 4),
          ],
          Text(
            title,
            textAlign: TextAlign.center,
            style: AmityTextStyle.titleBold(
              context.amityToken(AmityColorToken.textEmptyStateTitleDefault),
            ),
          ),
          if (description != null)
            Text(
              description!,
              textAlign: TextAlign.center,
              style: AmityTextStyle.caption(
                context.amityToken(AmityColorToken.textEmptyStateDescriptionDefault),
              ),
            ),
          if (action != null) ...[
            const SizedBox(height: 16),
            action!,
          ],
        ],
      ),
    );
  }
}
