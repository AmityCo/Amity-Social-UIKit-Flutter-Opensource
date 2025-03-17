import 'package:flutter/material.dart';

class AmityNewsFeedDivider extends StatelessWidget {
  const AmityNewsFeedDivider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: Theme.of(context).dividerColor.withOpacity(0.12),
    );
  }
}