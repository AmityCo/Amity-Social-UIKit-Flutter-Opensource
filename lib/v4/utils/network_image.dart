import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AmityNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final String placeHolderPath;

  const AmityNetworkImage(
      {super.key, required this.imageUrl, required this.placeHolderPath});

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.fill,
        loadingBuilder: (BuildContext context, Widget child,
            ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) {
            return child;
          } else {
            return SvgPicture.asset(
              placeHolderPath,
              package: 'amity_uikit_beta_service',
            );
          }
        },
        errorBuilder:
            (BuildContext context, Object error, StackTrace? stackTrace) {
          return SvgPicture.asset(
            placeHolderPath,
            package: 'amity_uikit_beta_service',
          );
        },
      );
    } else {
      return SvgPicture.asset(
        placeHolderPath,
        package: 'amity_uikit_beta_service',
      );
    }
  }
}
