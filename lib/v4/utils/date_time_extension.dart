import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  String toSocialTimestamp(BuildContext context) {
    final currentDateTime = DateTime.now();
    final difference = currentDateTime.difference(this);
    final yearDiff = (difference.inDays / 365).floor();
    final weekDiff = (difference.inDays / 7).floor();
    if (yearDiff >= 1) {
      return DateFormat('d MMM yyyy').format(this);
    } else if (weekDiff >= 1) {
      return DateFormat('d MMM').format(this);
    } else if (difference.inDays >= 1) {
      return '${difference.inDays}d';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes}m';
    } else {
      return context.l10n.timestamp_just_now;
    }
  }

  String toChatTimestamp(BuildContext context) {
    final currentDateTime = DateTime.now();
    final difference = currentDateTime.difference(this);
    final yearDiff = (difference.inDays / 365).floor();
    final weekDiff = (difference.inDays / 7).floor();
    if (yearDiff >= 1) {
      return DateFormat('d MMM yyyy', Localizations.localeOf(context).toLanguageTag()).format(this);
    } else if (weekDiff >= 1) {
      return DateFormat('d MMM', Localizations.localeOf(context).toLanguageTag()).format(this);
    } else if (difference.inDays >= 1) {
      return '${difference.inDays}d';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes}m';
    } else {
      return context.l10n.timestamp_now;
    }
  }
}
