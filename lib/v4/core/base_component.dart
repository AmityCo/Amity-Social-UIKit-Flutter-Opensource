import 'package:amity_uikit_beta_service/v4/utils/config_provider.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
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

  // ignore: prefer_const_constructors_in_immutables
  NewBaseComponent({super.key, this.pageId, required this.componentId});

  @override
  Widget build(BuildContext context) {
    if (!isInitialized()) {
      configProvider = context.watch<ConfigProvider>();
      theme = configProvider.getTheme(pageId, componentId);
    }
    return buildComponent(context);
  }

  Widget buildComponent(BuildContext context);

  bool isInitialized() {
    try {
      configProvider; 
      theme; 
      return true;
    } catch (e) {
      return false;
    }
  }
}
