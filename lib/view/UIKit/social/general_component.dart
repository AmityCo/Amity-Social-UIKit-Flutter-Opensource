import 'package:flutter/material.dart';

class AmityGeneralCompomemt {
  static void showOptionsBottomSheet(
      BuildContext context, List<Widget> listTiles) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext bc) {
        return Container(
          padding: const EdgeInsets.only(top: 20, bottom: 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          child: Wrap(
            children: listTiles,
          ),
        );
      },
    );
  }
}

class TimeAgoWidget extends StatelessWidget {
  final DateTime createdAt; // Assuming createdAt is a DateTime object
  final Color? textColor;

  const TimeAgoWidget({Key? key, required this.createdAt, this.textColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      _formatDate(createdAt),
      style: TextStyle(
        color: textColor ?? Colors.grey,
      ),
    );
  }

  String _formatDate(DateTime date) {
    DateTime localDate = date.toLocal();
    Duration difference = DateTime.now().difference(localDate);

    // Calculate the difference in weeks, months, and years
    int weeks = (difference.inDays / 7).floor();
    int months = (difference.inDays / 30).floor(); // Approximation
    int years = (difference.inDays / 365).floor(); // Approximation

    if (years > 0) {
      return '$years year${years > 1 ? 's' : ''} ago';
    } else if (months > 0) {
      return '$months month${months > 1 ? 's' : ''} ago';
    } else if (weeks > 0) {
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}
