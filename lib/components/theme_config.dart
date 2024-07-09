import 'package:amity_uikit_beta_service/viewmodel/configuration_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThemeConfig extends StatelessWidget {
  const ThemeConfig({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final uiConfig = Provider.of<AmityUIConfiguration>(context);

    Widget themeOr(Widget mediaQueryOr) {
      if (uiConfig.themeData != null) {
        return Theme(
          data: uiConfig.themeData!,
          child: mediaQueryOr,
        );
      } else {
        return mediaQueryOr;
      }
    }

    Widget mediaQueryOr() {
      if (uiConfig.mediaQueryData != null) {
        return MediaQuery(
          data: uiConfig.mediaQueryData!,
          child: child,
        );
      } else {
        return child;
      }
    }

    return themeOr(
      mediaQueryOr(),
    );
  }
}
