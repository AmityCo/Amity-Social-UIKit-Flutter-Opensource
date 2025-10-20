import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum RadioButtonSetting { everyone, onlyModerator, off }

class SettingRadioButtonWidget extends StatelessWidget {
  final String title;
  final String description;
  final RadioButtonSetting groupValue;
  final ValueChanged<RadioButtonSetting?> onChanged;
  final AmityThemeColor theme;

  const SettingRadioButtonWidget({
    Key? key,
    required this.title,
    required this.description,
    required this.groupValue,
    required this.onChanged,
    required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: theme.baseColor),
                ),
              ],
            ),
            const SizedBox(height: 10.0), // Add padding between the children
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                description,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: theme.baseColorShade1),
              ),
            ),
            const SizedBox(height: 24.0),
            _getRadioButtonTile(
              title: context.l10n.settings_everyone,
              value: RadioButtonSetting.everyone,
              groupValue: groupValue,
              onChanged: onChanged,
            ),
            const SizedBox(height: 32.0),
            _getRadioButtonTile(
              title: context.l10n.settings_only_moderators,
              value: RadioButtonSetting.onlyModerator,
              groupValue: groupValue,
              onChanged: onChanged,
            ),
            const SizedBox(height: 32.0),
            _getRadioButtonTile(
              title: context.l10n.settings_only_admins,
              value: RadioButtonSetting.off,
              groupValue: groupValue,
              onChanged: onChanged,
            ),
          ],
        ));
  }

  Widget _getRadioButtonTile<T>({
    required String title,
    required T value,
    required T groupValue,
    required void Function(T?) onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: theme.baseColor,
          ),
        ),
        SizedBox(
          width: 25,
          height: 30,
          child: Center(
            child: Radio(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: theme.primaryColor,
            ),
          ),
        )
      ],
    );
  }
}

class CustomRadioButton<T> extends StatelessWidget {
  final T value;
  final T groupValue;
  final Function(T?) onChanged;
  final Color selectedColor;
  final Color unselectedColor;

  const CustomRadioButton({
    Key? key,
    required this.value,
    required this.onChanged,
    required this.groupValue,
    this.selectedColor = Colors.blue,
    this.unselectedColor = Colors.grey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onChanged(value);
      },
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: value == groupValue ? selectedColor : Colors.transparent,
          border: value != groupValue
              ? Border.all(color: unselectedColor, width: 2)
              : null,
        ),
        child: value == groupValue
            ? Center(
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
