import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';


class ProfileTabItem extends StatelessWidget {

  final String image;
  final bool isSelected;
  final AmityThemeColor theme;
  final Function? onTap;

  const ProfileTabItem({
    super.key,
    required this.image,
    required this.isSelected,
    required this.theme,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          onTap?.call();
        },
        child: Container(
          decoration: (isSelected)
              ? BoxDecoration(
                  border: Border(
                    bottom: BorderSide(width: 2, color: theme.primaryColor),
                  ),
                )
              : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                color: theme.backgroundColor,
                width: double.infinity,
                height: 37,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          (isSelected)
                              ? theme.baseColor
                              : theme.baseColorShade3,
                          BlendMode.srcIn,
                        ),
                        child: SvgPicture.asset(
                          image,
                          package: 'amity_uikit_beta_service',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
