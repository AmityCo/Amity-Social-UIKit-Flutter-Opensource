import 'package:amity_uikit_beta_service/components/alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

// ignore: must_be_immutable
class SettingConfirmationBackButton extends StatelessWidget {
  bool shouldShowConfirmationDialog;

  SettingConfirmationBackButton({super.key, required this.shouldShowConfirmationDialog});
  
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
              title: "Leave without finishing?",
              detailText: "Your changes that you made may not be saved.",
              rightButtonText: 'Leave',
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
          colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
          package: 'amity_uikit_beta_service',
          height: 20,
          width: 20,
        ),
      ),
    );
  }
}
