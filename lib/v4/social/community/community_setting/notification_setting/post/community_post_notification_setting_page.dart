import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/freedom_uikit_behavior.dart';
import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:amity_uikit_beta_service/v4/core/base_page.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_setting/element/setting_confirmation_back_button.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_setting/notification_setting/element/setting_radio_button.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_setting/notification_setting/post/bloc/community_post_notification_setting_page_bloc.dart';
import 'package:amity_uikit_beta_service/v4/utils/app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum PostNotificationSetting { everyone, onlyModerator, off }

// ignore: must_be_immutable
class AmityCommunityPostsNotificationSettingPage extends NewBasePage {
  AmityCommunityPostsNotificationSettingPage(
      {super.key, required this.community, this.notificationSettings})
      : super(pageId: 'community_posts_notification_page');

  late AmityCommunity community;
  AmityCommunityNotificationSettings? notificationSettings;

  @override
  Widget buildPage(BuildContext context) {
    return BlocProvider(
        create: (_) => CommunityPostNotificationSettingPageBloc(
            community, notificationSettings),
        child: BlocBuilder<CommunityPostNotificationSettingPageBloc,
                CommunityPostNotificationSettingPageState>(
            builder: (context, state) {
          return _getPageWidget(context, state);
        }));
  }

  Widget _getPageWidget(
      BuildContext context, CommunityPostNotificationSettingPageState state) {
    final behavior = FreedomUIKitBehavior.instance.communityNotificationSettingBehavior;
    return Scaffold(
        backgroundColor: theme.backgroundColor,
        appBar: AmityAppBar(
            title: context.l10n.profile_posts,
            configProvider: configProvider,
            theme: theme,
            leadingButton: SettingConfirmationBackButton(shouldShowConfirmationDialog: state.settingsChanged),
            tailingButton: GestureDetector(
              onTap: state.settingsChanged
                  ? () {
                      context
                          .read<CommunityPostNotificationSettingPageBloc>()
                          .add(CommunityPostNotificationSettingSaveEvent(
                              context.read<AmityToastBloc>(), () {
                                if (behavior.onSaveSuccess != null) {
                                  behavior.onSaveSuccess?.call(context);
                                  return;
                                }
                            Navigator.of(context)..pop()..pop()..pop();
                          }));
                    }
                  : null,
              child: behavior.buildSaveButton?.call(context, state.settingsChanged) ?? Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  context.l10n.general_edit,
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
        body: (state.isLoading) ? Container() : ListView(
          children: [
            if (state.isReactPostNetworkEnabled || behavior.forceShowPost()) ...[
              SettingRadioButtonWidget(
                  title: context.l10n.settings_react_posts,
                  description: context.l10n.settings_react_posts_description,
                  groupValue: state.reactPostSetting,
                  onChanged: (value) {
                    context.read<CommunityPostNotificationSettingPageBloc>().add(
                        CommunityPostNotificationSettingChangedEvent(
                            reactPostSetting:
                                value ?? RadioButtonSetting.everyone,
                            newPostSetting: state.newPostSetting));
                  },
                  theme: theme),
              _getDividerWidget(),
            ],
            
            if (state.isNewPostNetworkEnabled || behavior.forceShowPost()) ...[
              SettingRadioButtonWidget(
                  title: context.l10n.settings_new_posts,
                  description: context.l10n.settings_new_posts_description,
                  groupValue: state.newPostSetting,
                  onChanged: (value) {
                    context.read<CommunityPostNotificationSettingPageBloc>().add(
                        CommunityPostNotificationSettingChangedEvent(
                            reactPostSetting: state.reactPostSetting,
                            newPostSetting:
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
          height: 0,
        ));
  }
}
