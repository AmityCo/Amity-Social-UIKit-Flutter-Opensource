import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/core/theme/amity_color_token.dart';
import 'package:amity_uikit_beta_service/v4/core/theme/amity_token_context.dart';

class GroupSettingsTile extends StatelessWidget {
  final String title;
  final String iconAsset;
  final VoidCallback onTap;
  final Color? iconBackgroundColor;
  final Widget? trailing;
  final AmityThemeColor theme;
  final String? trailingText;

  const GroupSettingsTile({
    Key? key,
    required this.title,
    required this.iconAsset,
    required this.onTap,
    required this.theme,
    this.iconBackgroundColor,
    this.trailing,
    this.trailingText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          children: [
            // Leading icon
            Container(
              width: 32,
              height: 32,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: iconBackgroundColor ?? context.amityToken(AmityColorToken.lineDividerContentDefault),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SvgPicture.asset(
                iconAsset,
                package: 'amity_uikit_beta_service',
                color: context.amityToken(AmityColorToken.textListHeaderDefaultDefault),
              ),
            ),

            const SizedBox(width: 12),

            // Title
            Expanded(
              child: Text(
                title,
                style: AmityTextStyle.body(context.amityToken(AmityColorToken.textListHeaderDefaultDefault)),
              ),
            ),
            const SizedBox(width: 8),

            // Trailing text if provided
            if (trailingText != null) ...[
              Text(
                trailingText!,
                style: AmityTextStyle.body(context.amityToken(AmityColorToken.textListTrailingTextGeneral)),
              ),
              const SizedBox(width: 8),
            ],

            // Trailing widget or default arrow
            Container(
              child: trailing ??
                  SvgPicture.asset(
                    'assets/Icons/amity_ic_seemore_arrow.svg',
                    package: 'amity_uikit_beta_service',
                    color: context.amityToken(AmityColorToken.iconListLeadingDefaultDefault),
                    width: 24,
                    height: 24,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
