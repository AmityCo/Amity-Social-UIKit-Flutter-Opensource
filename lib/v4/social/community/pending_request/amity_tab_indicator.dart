import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:flutter/material.dart';

class AmityTabIndicator extends StatelessWidget {
  final String title;
  final int count;
  final bool selected;
  final Color selectedColor;
  final Color unselectedColor;

  const AmityTabIndicator({
    Key? key,
    required this.title,
    required this.count,
    this.selected = false,
    required this.selectedColor,
    required this.unselectedColor,
  }) : super(key: key);

  String get formattedCount {
    if (count > 10) {
      return "10+";
    } else {
      return count.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentColor = selected ? selectedColor : unselectedColor;

    return Tab(
      child: Padding(
        padding: EdgeInsets.zero,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: AmityTextStyle.titleBold(currentColor)),
            const SizedBox(width: 4),
            Text("(${formattedCount})",
                style: AmityTextStyle.titleBold(currentColor)),
          ],
        ),
      ),
    );
  }
}
