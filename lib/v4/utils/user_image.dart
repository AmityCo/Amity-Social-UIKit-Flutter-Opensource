import 'package:amity_sdk/amity_sdk.dart';
import 'package:flutter/material.dart';

import '../core/theme.dart';

class AmityUserImage extends StatelessWidget {
  final AmityUser? user;
  final AmityThemeColor theme;
  final double size;
  // final String? imageUrl;
  // final String displayName;

  const AmityUserImage({
    super.key,
    required this.user,
    required this.size,
    required this.theme,
  });

  String? get imageUrl => user?.avatarUrl;
  String get displayName => user?.displayName ?? "";

  double _mapSizeToFontSize(double size) {
    if (size == 64) return 32;
    if (size == 56) return 32;
    if (size == 40) return 20;
    if (size == 32) return 17;
    if (size == 28) return 15;
    if (size == 16) return 10;
    return 10; // default case
  }

  Widget _buildPlaceholder() {
    return Container(
      color: theme.primaryColor.blend(ColorBlendingOption.shade2),
      child: Center(
        child: Text(
          displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
          style: TextStyle(
            color: Colors.white,
            fontSize: _mapSizeToFontSize(size),
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (BuildContext context, Widget child,
            ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) {
            return child;
          } else {
            return _buildPlaceholder();
          }
        },
        errorBuilder:
            (BuildContext context, Object error, StackTrace? stackTrace) {
          return _buildPlaceholder();
        },
      );
    } else {
      return _buildPlaceholder();
    }
  }
}