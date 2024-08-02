import 'package:flutter/material.dart';

class AmityBadgeIconWidget extends StatelessWidget {
  final Color bgColor;
  final IconData icon;
  const AmityBadgeIconWidget({super.key , required this.bgColor , required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16, 
      height: 16,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),

      child: Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: bgColor,
        ),
        child: Center(
          child: Icon(
            icon,
            size: 10,
            color: Colors.white,
          ),
        ),
      ),

      
    );
  }
}