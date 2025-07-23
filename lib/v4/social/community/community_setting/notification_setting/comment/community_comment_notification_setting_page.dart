import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:amity_uikit_beta_service/v4/core/base_page.dart';
import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_setting/element/setting_confirmation_back_button.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_setting/notification_setting/comment/bloc/community_comment_notification_setting_page_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_setting/notification_setting/element/setting_radio_button.dart';
import 'package:amity_uikit_beta_service/v4/utils/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ignore: must_be_immutable
class AmityCommunityCommentsNotificationSettingPage extends NewBasePage {
  AmityCommunityCommentsNotificationSettingPage(
      {super.key, required this.community, this.notificationSettings})
      : super(pageId: 'community_comments_notification_page');

  late AmityCommunity community;
  AmityCommunityNotificationSettings? notificationSettings;

  @override
  Widget buildPage(BuildContext context) {
    return BlocProvider(
        create: (_) => CommunityCommentNotificationSettingPageBloc(
            community, notificationSettings),
        child: BlocBuilder<CommunityCommentNotificationSettingPageBloc,
                CommunityCommentNotificationSettingPageState>(
            builder: (context, state) {
          return _getPageWidget(context, state);
        }));
  }

  Widget _getPageWidget(BuildContext context,
      CommunityCommentNotificationSettingPageState state) {
    return Scaffold(
        backgroundColor: theme.backgroundColor,
        appBar: AmityAppBar(
            title: context.l10n.general_comments,
            configProvider: configProvider,
            theme: theme,
            leadingButton: SettingConfirmationBackButton(shouldShowConfirmationDialog: state.settingsChanged),
            tailingButton: GestureDetector(
              onTap: state.settingsChanged
                  ? () {
                      context
                          .read<CommunityCommentNotificationSettingPageBloc>()
                          .add(CommunityCommentNotificationSettingSaveEvent(
                              context.read<AmityToastBloc>(), () {
                            Navigator.of(context)..pop()..pop()..pop();
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
            if (state.isReactCommentNetworkEnabled) ...[
              SettingRadioButtonWidget(
                  title: context.l10n.settings_react_comments,
                  description: context.l10n.settings_react_comments_description,
                  groupValue: state.reactCommentSetting,
                  onChanged: (value) {
                    context
                        .read<CommunityCommentNotificationSettingPageBloc>()
                        .add(CommunityCommentNotificationSettingChangedEvent(
                            reactCommentSetting:
                                value ?? RadioButtonSetting.everyone,
                            newCommentSetting: state.newCommentSetting,
                            replyCommentSetting: state.replyCommentSetting));
                  },
                  theme: theme),
              _getDividerWidget(),
            ],

            if (state.isNewCommentNetworkEnabled) ...[
              SettingRadioButtonWidget(
                  title: context.l10n.settings_new_comments,
                  description: context.l10n.settings_new_comments_description,
                  groupValue: state.newCommentSetting,
                  onChanged: (value) {
                    context
                        .read<CommunityCommentNotificationSettingPageBloc>()
                        .add(CommunityCommentNotificationSettingChangedEvent(
                            reactCommentSetting: state.reactCommentSetting,
                            newCommentSetting:
                                value ?? RadioButtonSetting.everyone,
                            replyCommentSetting: state.replyCommentSetting));
                  },
                  theme: theme),
              _getDividerWidget(),
            ],

            if (state.isReplyCommentNetworkEnabled) ...[
              SettingRadioButtonWidget(
                  title: context.l10n.settings_new_replies,
                  description: context.l10n.settings_new_replies_description,
                  groupValue: state.replyCommentSetting,
                  onChanged: (value) {
                    context
                        .read<CommunityCommentNotificationSettingPageBloc>()
                        .add(CommunityCommentNotificationSettingChangedEvent(
                            reactCommentSetting: state.reactCommentSetting,
                            newCommentSetting: state.newCommentSetting,
                            replyCommentSetting:
                                value ?? RadioButtonSetting.everyone));
                  },
                  theme: theme),
            ]
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
      ),
    );
  }
}
