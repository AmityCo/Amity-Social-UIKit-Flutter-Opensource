import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:flutter/material.dart';

enum PostPermissionSetting { everyoneCanPost, adminReviewPost, onlyAdminsCanPost }

class PostPermissionRadioButtonWidget extends StatelessWidget {
  final String title;
  final String description;
  final PostPermissionSetting groupValue;
  final ValueChanged<PostPermissionSetting?> onChanged;
  final AmityThemeColor theme;

  const PostPermissionRadioButtonWidget({
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
          const SizedBox(height: 10.0),
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
            title: context.l10n.permission_everyone_can_post,
            value: PostPermissionSetting.everyoneCanPost,
          ),
          const SizedBox(height: 32.0),
          _getRadioButtonTile(
            title: context.l10n.permission_admin_review_post,
            value: PostPermissionSetting.adminReviewPost,
          ),
          const SizedBox(height: 32.0),
          _getRadioButtonTile(
            title: context.l10n.permission_only_admins_can_post,
            value: PostPermissionSetting.onlyAdminsCanPost,
          ),
        ],
      ),
    );
  }

  Widget _getRadioButtonTile({
    required String title,
    required PostPermissionSetting value,
  }) {
    return GestureDetector(
      onTap: () => onChanged(value),
      behavior: HitTestBehavior.opaque,
      child: Row(
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
              child: Radio<PostPermissionSetting>(
                value: value,
                groupValue: groupValue,
                onChanged: onChanged,
                activeColor: theme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
