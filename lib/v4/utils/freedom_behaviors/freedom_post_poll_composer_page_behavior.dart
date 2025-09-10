import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FreedomPostPollComposerPageBehavior {
  DateFormat getEndDateFormat(BuildContext context) => DateFormat(
        "dd MMM 'at' hh:mm a",
        Localizations.localeOf(context).toLanguageTag(),
      );
}
