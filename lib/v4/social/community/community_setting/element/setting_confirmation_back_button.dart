import 'package:amity_uikit_beta_service/components/alert_dialog.dart';
import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/utils/config_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

// ignore: must_be_immutable
class SettingConfirmationBackButton extends StatelessWidget {
  bool shouldShowConfirmationDialog;
  AmityThemeColor theme;

  SettingConfirmationBackButton({
    super.key,
    required this.shouldShowConfirmationDialog,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return _backButton(context);
  }

  Widget _backButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (shouldShowConfirmationDialog) {
          ConfirmationDialog().show(
              context: context,
              title: context.l10n.settings_leave_confirmation,
              detailText: context.l10n.settings_leave_description,
              rightButtonText: context.l10n.general_leave,
              onConfirm: () {
                Navigator.pop(context);
              });
        } else {
          Navigator.pop(context);
        }
      },
      child: Center(
        child: SvgPicture.asset(
          "assets/Icons/amity_ic_back_button.svg",
          colorFilter: ColorFilter.mode(theme.baseColor, BlendMode.srcIn),
          package: 'amity_uikit_beta_service',
          height: 20,
          width: 20,
        ),
      ),
    );
  }
}
