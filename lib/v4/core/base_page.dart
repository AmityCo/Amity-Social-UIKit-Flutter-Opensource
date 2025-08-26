import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/utils/config_provider.dart';
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
  late final AmityUIConfig uiConfig;

  Widget buildPage(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return Consumer<ConfigProvider>(
      builder: (context, provider, child) {
        if (!isInitialized()) {
          configProvider = provider;
          theme = configProvider.getTheme(pageId, '');
          uiConfig = configProvider.getUIConfig(pageId, null, null);
        }
        return Theme(
            data: Theme.of(context).copyWith(
                textSelectionTheme: TextSelectionThemeData(
              cursorColor: theme.primaryColor,
              selectionColor: theme.primaryColor.withOpacity(0.3),
              selectionHandleColor: theme.primaryColor,
            )),
            child: buildPage(context));
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

  bool isInitialized() {
    try {
      configProvider;
      theme;
      uiConfig;
      return true;
    } catch (e) {
      return false;
    }
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
