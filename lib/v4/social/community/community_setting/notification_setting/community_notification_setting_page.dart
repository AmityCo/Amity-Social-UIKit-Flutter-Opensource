import 'package:amity_uikit_beta_service/freedom_uikit_behavior.dart';
import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:amity_uikit_beta_service/v4/core/base_page.dart';
import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_setting/notification_setting/bloc/community_notification_setting_page_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_setting/notification_setting/comment/community_comment_notification_setting_page.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_setting/notification_setting/post/community_post_notification_setting_page.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_setting/notification_setting/story/community_story_notification_setting_page.dart';
import 'package:amity_uikit_beta_service/v4/utils/app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class AmityCommunityNotificationSettingPage extends NewBasePage {
  AmityCommunityNotificationSettingPage(
      {super.key, required this.community, this.notificationSettings})
      : super(pageId: 'community_setting_page');

  late AmityCommunity community;
  AmityCommunityNotificationSettings? notificationSettings;

  @override
  Widget buildPage(BuildContext context) {
    return BlocProvider(
        create: (_) => CommunityNotificationSettingPageBloc(community, notificationSettings),
        child: BlocBuilder<CommunityNotificationSettingPageBloc,
            CommunityNotificationSettingPageState>(builder: (context, state) {
          return _getPageWidget(context, state);
        }));
  }

  Widget _getPageWidget(
      BuildContext context, CommunityNotificationSettingPageState state) {
    final behavior = FreedomUIKitBehavior.instance.communityNotificationSettingBehavior;
    return Scaffold(
        backgroundColor: theme.backgroundColor,
        appBar: AmityAppBar(
            title: context.l10n.settings_notifications,
            configProvider: configProvider,
            theme: theme),
        body: ListView(
          children: [
            _getToggleSettingWidget(context, state),
            !state.isNotificaitonEnabled
                ? const SizedBox()
                : Column(
                    children: [
                      if (state.isPostNetworkEnabled || state.isCommentNetworkEnabled || state.isStoryNetworkEnabled)
                        _getDividerWidget(),

                      if (state.isPostNetworkEnabled || behavior.forceShowPost())
                        _getSettingItemWidget(
                            'assets/Icons/amity_icon_post_notification_setting.svg',
                            context.l10n.profile_posts, onTap: () {
                          _goToPostSettingPage(context);
                        }),

                      if (state.isCommentNetworkEnabled || behavior.forceShowComment())
                        _getSettingItemWidget(
                            'assets/Icons/amity_icon_comment_notification_setting.svg',
                            context.l10n.general_comments, onTap: () {
                          _goToCommentSettingPage(context);
                        }),
                        
                      if (state.isStoryNetworkEnabled)
                        _getSettingItemWidget(
                            'assets/Icons/amity_icon_story_notification_setting.svg',
                            context.l10n.general_stories, onTap: () {
                          _goToStorySettingPage(context);
                        }),
                    ],
                  )
          ],
        ));
  }

  Widget _getToggleSettingWidget(
      BuildContext context, CommunityNotificationSettingPageState state) {
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.settings_allow_notification,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: theme.baseColor),
                ),
                CupertinoSwitch(
                  value: state.isNotificaitonEnabled,
                  onChanged: (bool value) {
                    context.read<CommunityNotificationSettingPageBloc>().add(
                        CommunityNotificationSettingToggleEvent(
                            isNotificationEnabled: value));
                  },
                  activeColor: theme.primaryColor,
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(context.l10n.settings_allow_notification_description,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: theme.baseColorShade1),
              ),
            ),
          ],
        ));
  }

  Widget _getSettingItemWidget(String iconPath, String title,
      {GestureTapCallback? onTap}) {
    return GestureDetector(
        onTap: onTap,
        child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 16),
            child: ListTile(
                horizontalTitleGap: 10,
                contentPadding: EdgeInsets.zero,
                leading: Container(
                    width: 24,
                    height: 20,
                    padding: const EdgeInsets.all(0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                          4), // Adjust radius to your need
                      color: Colors
                          .transparent, // Choose the color to fit your design
                    ),
                    child: SvgPicture.asset(
                      iconPath,
                      package: 'amity_uikit_beta_service',
                      fit: BoxFit.contain,
                      width: 24,
                      height: 20,
                    )),
                title: Text(title,
                    style: TextStyle(
                        color: theme.baseColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w400)),
                trailing: Icon(Icons.chevron_right, color: theme.baseColor))));
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

  void _goToPostSettingPage(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            AmityCommunityPostsNotificationSettingPage(community: community, notificationSettings: notificationSettings)));
  }

  void _goToCommentSettingPage(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => AmityCommunityCommentsNotificationSettingPage(
            community: community, notificationSettings: notificationSettings)));
  }

  void _goToStorySettingPage(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => AmityCommunityStoriesNotificationSettingPage(
            community: community, notificationSettings: notificationSettings)));
  }
}
