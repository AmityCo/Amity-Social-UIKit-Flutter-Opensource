import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/utils/config_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BaseComponent extends StatelessWidget {
  final Widget child;

  const BaseComponent({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.light().copyWith(
        primaryColor: Colors.teal,
      ),
      child: child,
    );
  }
}

// Rename this to BaseComponent
abstract class NewBaseComponent extends StatelessWidget {
  final String? pageId;
  final String componentId;
  late final AmityThemeColor theme;
  late final ConfigProvider configProvider;
  late final Map<String, dynamic> config;

  NewBaseComponent({super.key, this.pageId, required this.componentId});

  @override
  Widget build(BuildContext context) {
    if (!isInitialized()) {
      configProvider = context.watch<ConfigProvider>();
      theme = configProvider.getTheme(pageId, componentId);
      config = configProvider.getMapConfig(pageId,componentId, null);
    }
    return Theme(
      data: Theme.of(context)
        .copyWith(
          textSelectionTheme: TextSelectionThemeData(
            cursorColor: theme.primaryColor,
            selectionColor: theme.primaryColor.withOpacity(0.3),
            selectionHandleColor: theme.primaryColor,
          )
        ),
      child: buildComponent(context)
    );
  }

  Widget buildComponent(BuildContext context);

  bool isInitialized() {
    try {
      configProvider; 
      theme; 
      config;
      return true;
    } catch (e) {
      return false;
    }
  }
}
