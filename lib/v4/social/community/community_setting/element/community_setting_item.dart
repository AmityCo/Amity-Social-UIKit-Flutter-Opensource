import 'package:amity_uikit_beta_service/v4/core/base_element.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CommunitySettingItem extends BaseElement {
  final String iconPath;
  final GestureTapCallback? onTap;

  CommunitySettingItem(this.iconPath,
      {this.onTap, super.key, required super.pageId, required super.componentId, required super.elementId});

  @override
  Widget buildElement(BuildContext context) {
    String title =
        configProvider.getConfig('$pageId/$componentId/$elementId')['text'] ?? '';
    return _getSettingItemWidget(
        iconPath, title,
        onTap: onTap);
  }

  Widget _getSettingItemWidget(String iconPath, String title,
      {GestureTapCallback? onTap}) {
    return GestureDetector(
        onTap: onTap,
        child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 16),
            child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                    width: 24,
                    height: 24,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                          4), // Adjust radius to your need
                      color: theme
                          .baseColorShade4, // Choose the color to fit your design
                    ),
                    child: SvgPicture.asset(
                      iconPath,
                      package: 'amity_uikit_beta_service',
                      fit: BoxFit.contain,
                    )),
                title: Text(title,
                    style: TextStyle(
                        color: theme.baseColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w400)),
                trailing: Icon(Icons.chevron_right, color: theme.baseColor))));
  }
}
