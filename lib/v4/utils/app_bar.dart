import 'package:flutter/material.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/utils/config_provider.dart';

class AmityAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AmityAppBar(
      {Key? key,
      required this.title,
      required this.configProvider,
      required this.theme,
      this.leadingButton,
      this.tailingButton,
      this.displayBottomLine = false // Add the rightButton parameter
      })
      : preferredSize = const Size.fromHeight(kToolbarHeight),
        super(key: key);

  final String title;
  final Widget? leadingButton;
  final Widget? tailingButton;
  final bool displayBottomLine; // Make the rightButton parameter nullable

  @override
  final Size preferredSize;

  final ConfigProvider configProvider;
  final AmityThemeColor theme;

  @override
  Widget build(BuildContext context) {
    return renderAppBar();
  }

  Widget renderAppBar() {
    return Stack(
      alignment: AlignmentDirectional.bottomCenter,
      children: [
        AppBar(
          backgroundColor: theme.backgroundColor,
          scrolledUnderElevation: 0.0,
          title: Text(title),
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: theme.baseColor,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
          leading: leadingButton,
          actions: tailingButton != null
              ? [tailingButton!]
              : [], // Conditionally include the right button
        ),
        if (displayBottomLine) _getDividerWidget(),
      ],
    );
  }

  Widget _getDividerWidget() {
    return Padding(
        padding: EdgeInsets.zero,
        child: Divider(
          color: theme.baseColorShade4,
          thickness: 1,
          indent: 0,
          endIndent: 0,
          height: 1,
        ));
  }
}
