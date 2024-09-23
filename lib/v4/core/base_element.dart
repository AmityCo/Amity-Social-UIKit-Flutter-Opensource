import 'package:amity_uikit_beta_service/v4/utils/config_provider.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

abstract class BaseElement extends StatelessWidget {
  final String? pageId;
  final String? componentId;
  final String elementId;

  late final AmityThemeColor theme;
  late final ConfigProvider configProvider;

  // ignore: prefer_const_constructors_in_immutables
  BaseElement(
      {super.key, this.pageId, this.componentId, required this.elementId});

  @override
  Widget build(BuildContext context) {
    configProvider = context.watch<ConfigProvider>();
    theme = configProvider.getTheme(pageId, componentId);
    return buildElement(context);
  }

  Widget buildElement(BuildContext context);
}


