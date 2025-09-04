import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:amity_uikit_beta_service/v4/core/base_page.dart';
import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_setting/element/setting_confirmation_back_button.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_setting/notification_setting/element/setting_radio_button.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_setting/notification_setting/story/bloc/community_story_notification_setting_page_bloc.dart';
import 'package:amity_uikit_beta_service/v4/utils/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AmityCommunityStoriesNotificationSettingPage extends NewBasePage {
  AmityCommunityStoriesNotificationSettingPage(
      {super.key, required this.community, this.notificationSettings})
      : super(pageId: 'community_stories_notification_page');

  late AmityCommunity community;
  AmityCommunityNotificationSettings? notificationSettings;

  @override
  Widget buildPage(BuildContext context) {
    return BlocProvider(
        create: (_) => CommunityStoryNotificationSettingPageBloc(
            community, notificationSettings),
        child: BlocBuilder<CommunityStoryNotificationSettingPageBloc,
                CommunityStoryNotificationSettingPageState>(
            builder: (context, state) {
          return _getPageWidget(context, state);
        }));
  }

  Widget _getPageWidget(
      BuildContext context, CommunityStoryNotificationSettingPageState state) {
    return Scaffold(
        backgroundColor: theme.backgroundColor,
        appBar: AmityAppBar(
            title: "Stories",
            configProvider: configProvider,
            theme: theme,
            leadingButton: SettingConfirmationBackButton(
                shouldShowConfirmationDialog: state.settingsChanged,
                theme: theme),
            tailingButton: GestureDetector(
              onTap: state.settingsChanged
                  ? () {
                      context
                          .read<CommunityStoryNotificationSettingPageBloc>()
                          .add(CommunityStoryNotificationSettingSaveEvent(
                              context.read<AmityToastBloc>(), () {
                            Navigator.of(context)
                              ..pop()
                              ..pop()
                              ..pop();
                          }));
                    }
                  : null,
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  'Save',
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
            if (state.isNewStoryNetworkEnabled) ...[
              SettingRadioButtonWidget(
                  title: context.l10n.settings_new_stories,
                  description: context.l10n.settings_new_stories_description,
                  groupValue: state.newStorySetting,
                  onChanged: (value) {
                    context
                        .read<CommunityStoryNotificationSettingPageBloc>()
                        .add(CommunityStoryNotificationSettingChangedEvent(
                            reactStorySetting: state.reactStorySetting,
                            newStorySetting:
                                value ?? RadioButtonSetting.everyone,
                            commentStorySetting: state.commentStorySetting));
                  },
                  theme: theme),
              _getDividerWidget(),
            ],
            if (state.isReactStoryNetworkEnabled) ...[
              SettingRadioButtonWidget(
                  title: context.l10n.settings_story_reactions,
                  description:
                      context.l10n.settings_story_reactions_description,
                  groupValue: state.reactStorySetting,
                  onChanged: (value) {
                    context
                        .read<CommunityStoryNotificationSettingPageBloc>()
                        .add(CommunityStoryNotificationSettingChangedEvent(
                            reactStorySetting:
                                value ?? RadioButtonSetting.everyone,
                            newStorySetting: state.newStorySetting,
                            commentStorySetting: state.commentStorySetting));
                  },
                  theme: theme),
              _getDividerWidget(),
            ],
            if (state.isCommentStoryNetworkEnabled) ...[
              SettingRadioButtonWidget(
                  title: context.l10n.settings_story_comments,
                  description: context.l10n.settings_story_comments_description,
                  groupValue: state.commentStorySetting,
                  onChanged: (value) {
                    context
                        .read<CommunityStoryNotificationSettingPageBloc>()
                        .add(CommunityStoryNotificationSettingChangedEvent(
                            reactStorySetting: state.reactStorySetting,
                            newStorySetting: state.newStorySetting,
                            commentStorySetting:
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
