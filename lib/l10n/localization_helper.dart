import 'package:amity_uikit_beta_service/viewmodel/configuration_viewmodel.dart';
import 'package:flutter/material.dart';

import 'generated/app_localizations.dart';

// Extension for easier access to localized strings
extension BuildContextLocalizationsExtension on BuildContext {
  AppLocalizations get l10n => AmityUIConfiguration.customLocalization == null
      ? AppLocalizations.of(this)!
      : AmityUIConfiguration.customLocalization!;
}
