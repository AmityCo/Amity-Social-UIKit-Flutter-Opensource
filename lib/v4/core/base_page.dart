import 'package:amity_uikit_beta_service/v4/utils/config_provider.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BasePage extends StatelessWidget {
  final Widget? child;
  final String? pageId;

  const BasePage({Key? key, this.child, this.pageId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.light().copyWith(
        primaryColor: Colors.red,
      ),
      child: child!,
    );
  }
}

/// Rename this to BasePage
abstract class NewBasePage extends StatelessWidget {
  final String pageId;

  // ignore: prefer_const_constructors_in_immutables
  NewBasePage({super.key, required this.pageId});

  late final ConfigProvider configProvider;
  late final AmityThemeColor theme;

  Widget buildPage(BuildContext context);

  @override
  Widget build(BuildContext context) {
    configProvider = ConfigProvider();
    theme = configProvider.getTheme(pageId, '');
    return Consumer<ConfigProvider>(
      builder: (context, configProvider, child) {
        return buildPage(context);
      },
    );
    // return ChangeNotifierProvider<ConfigProvider>(
    //   create: (_) {
    //     configProvider.loadConfig();
    //     return configProvider;
    //   },
    //   child: Consumer<ConfigProvider>(
    //     builder: (context, configProvider, child) {
    //       return buildPage(context);
    //     },
    //   ),
    // );
  }
}

enum AmityPage { socialHomePage }

extension AmityComponentExtension on AmityPage {
  String get stringValue {
    switch (this) {
      case AmityPage.socialHomePage:
        return 'social_home_page';
    }
  }
}
