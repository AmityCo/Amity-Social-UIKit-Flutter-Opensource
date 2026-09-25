import 'package:amity_uikit_beta_service/v4/core/theme/amity_color_token.dart';
import 'package:amity_uikit_beta_service/v4/core/theme/amity_token_context.dart';
import 'package:flutter/material.dart';

/// The atomic Radio control, per the authoritative Selection atom spec
/// (`UIKIT/atoms/Selection/v1.md`).
///
/// Material's `Radio` cannot render this: Active is a **fully filled disc**
/// with an 8 centre dot in its own Icon token, where Material draws a ring plus
/// a dot in one colour. Patching `fillColor` — as the create-group page does —
/// gets the Inactive ring visible but leaves Active looking like Material.
///
/// Geometry from the spec's table: 24 hit-area frame, 2 padding, so a 20
/// circle; border ring 2 (the spec measured `strokeWeight: 2` off the Figma
/// COMPONENT_SETs and notes it corrects Android's 1.dp hardcode); centre dot 8.
///
/// Token grammar, all from the Selection family:
///  - Surface: `Surface/Selection/RadioAtomic/{Active|Inactive}/{Default|Disabled}`
///  - Border:  `Border/Selection/RadioAtomic/Inactive/{Default|Disabled}` — ring
///             on Inactive only; an Active disc fills the circle, so it needs none
///  - Icon:    `Icon/Selection/RadioAtomic/{Default|Disabled}` — the dot, drawn in
///             both states and transparent when Inactive, mirroring the source
///
/// Radio only for now. The spec covers CheckboxAtomic with the same geometry and
/// a ~14 check glyph; add that variant when a surface needs it.
class AmityRadioSelection extends StatelessWidget {
  const AmityRadioSelection({
    super.key,
    required this.isSelected,
    this.isDisabled = false,
    this.onTap,
  });

  final bool isSelected;
  final bool isDisabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final surface = context.amityToken(isSelected
        ? (isDisabled
            ? AmityColorToken.surfaceSelectionRadioAtomicActiveDisabled
            : AmityColorToken.surfaceSelectionRadioAtomicActiveDefault)
        : (isDisabled
            ? AmityColorToken.surfaceSelectionRadioAtomicInactiveDisabled
            : AmityColorToken.surfaceSelectionRadioAtomicInactiveDefault));
    final border = context.amityToken(isDisabled
        ? AmityColorToken.borderSelectionRadioAtomicInactiveDisabled
        : AmityColorToken.borderSelectionRadioAtomicInactiveDefault);
    final dot = context.amityToken(isDisabled
        ? AmityColorToken.iconSelectionRadioAtomicDisabled
        : AmityColorToken.iconSelectionRadioAtomicDefault);

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 24,
        height: 24,
        child: Center(
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: surface,
              border: isSelected
                  ? null
                  : Border.all(color: border, width: 2),
            ),
            child: Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? dot : Colors.transparent,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
