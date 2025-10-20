// ignore: must_be_immutable
import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/base_page.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_setting/element/setting_confirmation_back_button.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_setting/notification_setting/element/setting_radio_button.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_setting/permission_setting/post/bloc/community_post_permission_page_bloc.dart';
import 'package:amity_uikit_beta_service/v4/utils/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';

class AmityCommunityPostPermissionPage extends NewBasePage {
  AmityCommunityPostPermissionPage({super.key, required this.community})
      : super(pageId: 'community_posts_notification_page');

  late AmityCommunity community;

  @override
  Widget buildPage(BuildContext context) {
    return BlocProvider(
      create: (_) => CommunityPostPermissionPageBloc(community),
      child: BlocBuilder<CommunityPostPermissionPageBloc,
          CommunityPostPermissionPageState>(
        builder: (context, state) {
          return _getPageWidget(context, state);
        },
      ),
    );
  }

  Widget _getPageWidget(
      BuildContext context, CommunityPostPermissionPageState state) {
    return Scaffold(
        backgroundColor: theme.backgroundColor,
        appBar: AmityAppBar(
            title: context.l10n.community_post_permission,
            configProvider: configProvider,
            theme: theme,
            leadingButton: SettingConfirmationBackButton(
              shouldShowConfirmationDialog: state.settingsChanged,
              theme: theme,
            ),
            tailingButton: GestureDetector(
              onTap: state.settingsChanged
                  ? () {
                      context.read<CommunityPostPermissionPageBloc>().add(
                              CommunityPostPermissionSettingSaveEvent(
                                  context.read<AmityToastBloc>(), () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          }));
                    }
                  : null,
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  context.l10n.general_save,
                  style: TextStyle(
                      color: state.settingsChanged
                          ? theme.primaryColor
                          : theme.primaryColor
                              .blend(ColorBlendingOption.shade2),
                      fontSize: 15,
                      fontWeight: FontWeight.w400),
                ),
              ),
            )),
        body: ListView(
          children: [
            SettingRadioButtonWidget(
                title: context.l10n.community_post_permission_title_label,
                description:
                    context.l10n.community_post_permission_description_label,
                groupValue: state.postPermissionSetting,
                onChanged: (value) {
                  context.read<CommunityPostPermissionPageBloc>().add(
                      CommunityPostPermissionSettingChangedEvent(
                          postPermissionSetting:
                              value ?? RadioButtonSetting.everyone));
                },
                theme: theme),
          ],
        ));
  }

  Widget _getDividerWidget() {
    return Padding(
        padding: EdgeInsets.zero,
        child: Divider(
          color: theme.baseColorShade4,
          thickness: 1,
          indent: 16,
          endIndent: 16,
          height: 0,
        ));
  }
}
