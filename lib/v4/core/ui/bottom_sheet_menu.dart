import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class BottomSheetMenu {
  final List<BottomSheetMenuOption> options;

  BottomSheetMenu({required this.options});

  void show(BuildContext context, AmityThemeColor theme) async {
    double itemHeight = 48;
    double baseHeight = 100;
    double height = baseHeight + (options.length * itemHeight);

    showModalBottomSheet(
        context: context,
        backgroundColor: theme.backgroundColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        builder: (context) {
          return SizedBox(
            height: height,
            child: Column(
              children: [
                // Grabber
                Container(
                  width: double.infinity,
                  height: 36,
                  padding: const EdgeInsets.only(top: 12, bottom: 20),
                  color: theme.backgroundColor,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 36,
                        height: 4,
                        decoration: ShapeDecoration(
                          color: theme.baseColorShade3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Menu Options
                Column(
                  children: options.map((option) {
                    return ListTile(
                      tileColor: theme.backgroundColor,
                      contentPadding: const EdgeInsets.only(left: 24),
                      horizontalTitleGap: 16,
                      minVerticalPadding: 0,
                      leading: SvgPicture.asset(
                        option.icon,
                        package: 'amity_uikit_beta_service',
                        width: 20,
                        height: 20,
                        colorFilter: option.colorFilter ??
                            ColorFilter.mode(
                              theme.baseColor,
                              BlendMode.srcIn,
                            ),
                      ),
                      title: Text(
                        option.title,
                        style: option.textStyle ??
                            AmityTextStyle.bodyBold(theme.baseColor),
                      ),
                      onTap: () {
                        option.onTap();
                      },
                    );
                  }).toList(),
                )
              ],
            ),
          );
        });
  }
}

class BottomSheetMenuOption {
  final String title;
  final String icon;
  final TextStyle? textStyle;
  final ColorFilter? colorFilter;
  final Function onTap;

  BottomSheetMenuOption(
      {required this.title,
      required this.icon,
      this.textStyle,
      this.colorFilter,
      required this.onTap});
}
