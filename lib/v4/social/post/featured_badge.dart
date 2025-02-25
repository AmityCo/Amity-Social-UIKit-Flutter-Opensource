import 'package:flutter/material.dart';
import 'package:amity_uikit_beta_service/v4/core/base_element.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';

class FeaturedBadge extends BaseElement {

  final String text;

  FeaturedBadge({super.key, required this.text}): super(elementId: "featured_badge");

  @override
  Widget buildElement(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        decoration: BoxDecoration(
        color: theme.secondaryColor.blend(ColorBlendingOption.shade4),
        borderRadius: const BorderRadius.only(topRight: Radius.circular(4), bottomRight: Radius.circular(4)),
        ),
        child: Text(
        text,
        style: AmityTextStyle.captionBold(theme.secondaryColor),
        ),
      ),
    );
  }
}