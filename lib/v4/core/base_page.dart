import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/core/theme/amity_color_token.dart';
import 'package:amity_uikit_beta_service/v4/utils/config_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/amity_uikit_toast.dart';

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

  NewBasePage({super.key, required this.pageId});

  late ConfigProvider configProvider;
  late AmityThemeColor theme;
  late AmityUIConfig uiConfig;

  Widget buildPage(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return Consumer<ConfigProvider>(
      builder: (context, provider, child) {
        configProvider = provider;
        theme = configProvider.getTheme(pageId, '');
        uiConfig = configProvider.getUIConfig(pageId, null, null);
        return Theme(
            data: Theme.of(context).copyWith(
                textSelectionTheme: TextSelectionThemeData(
              cursorColor: theme.primaryColor,
              selectionColor: theme.primaryColor.withOpacity(0.3),
              selectionHandleColor: theme.primaryColor,
            )),
            child: AmityToast(
                pageId: pageId, elementId: 'toast', child: buildPage(context)));
      },
    );
  }

  /// Resolve a semantic colour token at this page's scope. Pass [componentId] /
  /// [elementId] from deeper widgets so a more specific customization can win.
  Color token(AmityColorToken t, {String? componentId, String? elementId}) =>
      configProvider.token(t,
          pageId: pageId, componentId: componentId, elementId: elementId);
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
