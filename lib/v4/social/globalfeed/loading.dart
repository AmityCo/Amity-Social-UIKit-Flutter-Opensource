import 'package:amity_uikit_beta_service/v4/utils/config_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Loading extends StatelessWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appTheme = Provider.of<ConfigProvider>(context).getTheme(null, null);
    // TODO 1: Replace the return statement with a Shimmer widget
    return CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(appTheme.primaryColor),
    );
  }
}
