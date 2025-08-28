import 'package:amity_uikit_beta_service/freedom_uikit_behavior.dart';
import 'package:flutter/material.dart';

import 'generated/app_localizations.dart';

// Extension for easier access to localized strings
extension BuildContextLocalizationsExtension on BuildContext {
  AppLocalizations get l10n {
    final custom =
        FreedomUIKitBehavior.instance.localizationBehavior.customLocalization;
    return custom ?? AppLocalizations.of(this)!;
  }
}
