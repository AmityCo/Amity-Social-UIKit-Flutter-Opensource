import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {


  String toSocialTimestamp() {
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
      return 'Just now';
    }
  }

  String toChatTimestamp() {
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
      return 'now';
    }
  }
}