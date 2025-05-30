import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';

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
              width: 24,
              height: 24,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: iconBackgroundColor ?? theme.baseColorShade4,
                borderRadius: BorderRadius.circular(4),
              ),
              child: SvgPicture.asset(
                iconAsset,
                package: 'amity_uikit_beta_service',
                color: theme.baseColor,
              ),
            ),

            const SizedBox(width: 12),

            // Title
            Expanded(
              child: Text(
                title,
                style: AmityTextStyle.body(theme.baseColor),
              ),
            ),
            const SizedBox(width: 8),

            // Trailing text if provided
            if (trailingText != null) ...[
              Text(
                trailingText!,
                style: AmityTextStyle.body(theme.baseColorShade1),
              ),
              const SizedBox(width: 8),
            ],

            // Trailing widget or default arrow
            Container(
              child: trailing ??
                  SvgPicture.asset(
                    'assets/Icons/amity_ic_seemore_arrow.svg',
                    package: 'amity_uikit_beta_service',
                    color: theme.baseColorShade1,
                    width: 16,
                    height: 16,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
