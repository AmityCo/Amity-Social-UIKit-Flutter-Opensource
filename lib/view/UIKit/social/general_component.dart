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

  const TimeAgoWidget({Key? key, required this.createdAt}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      _formatDate(createdAt),
      style: const TextStyle(
          // Add your text style here
          ),
    );
  }

  String _formatDate(DateTime date) {
    DateTime localDate = date.toLocal();
    Duration difference = DateTime.now().difference(localDate);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}
