import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ArchivedChatListEmptyState extends StatelessWidget {
  final AmityThemeColor theme;

  const ArchivedChatListEmptyState({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/Icons/amity_ic_archived_chat_empty.svg',
            package: 'amity_uikit_beta_service',
            width: 60,
            height: 45,
          ),
          const SizedBox(height: 16),
          Text(context.l10n.chat_archived_empty_title,
              style: AmityTextStyle.titleBold(theme.baseColorShade3)),
        ],
      ),
    );
  }
}