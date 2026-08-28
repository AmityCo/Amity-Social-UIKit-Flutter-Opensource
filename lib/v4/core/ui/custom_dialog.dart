import 'package:flutter/material.dart';

class TimedDialog extends StatefulWidget {
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  const TimedDialog({
    super.key,
    required this.text,
    this.backgroundColor,
    this.textColor,
  });

  @override
  _TimedDialogState createState() => _TimedDialogState();
}

class _TimedDialogState extends State<TimedDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  // late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200), // duration of the fade-out
      vsync: this,
    );
    // _opacityAnimation = Tween<double>(begin: 1, end: 1).animate(_controller);

    // Wait for 3 seconds before starting the fade-out
    Future.delayed(const Duration(seconds: 1), () {
      _controller.forward().then((_) {
        Navigator.of(context).pop(); // Close dialog after animation
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Don't forget to dispose of the controller!
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.backgroundColor ?? Colors.grey.withOpacity(0.6);
    final fgColor = widget.textColor ?? Colors.white;
    return Center(
      child: SizedBox(
        width: 200,
        child: Dialog(
          backgroundColor: bgColor,
          elevation: 0,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check,
                  color: fgColor,
                  size: 50,
                ),
                const SizedBox(height: 16),
                Text(
                  widget.text,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: fgColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
