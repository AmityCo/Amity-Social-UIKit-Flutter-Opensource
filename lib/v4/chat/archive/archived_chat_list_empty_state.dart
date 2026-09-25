import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/core/ui/atoms/amity_empty_state.dart';
import 'package:flutter/material.dart';

class ArchivedChatListEmptyState extends StatelessWidget {
  final AmityThemeColor theme;

  const ArchivedChatListEmptyState({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    // The artwork is a single-colour glyph, so it takes the tinted icon slot: it
    // was drawing its authored #EBECEF everywhere, which is a bright mark on a
    // dark page rather than the subdued one the token gives.
    return AmityEmptyState(
      variant: AmityEmptyStateVariant.icon,
      asset: 'assets/Icons/amity_ic_archived_chat_empty.svg',
      title: context.l10n.chat_archived_empty_title,
    );
  }
}
