import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/components/alert_dialog.dart';
import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_creation/community_setup_page.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_membership/community_membership_page.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_setting/notification_setting/community_notification_setting_page.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_setting/element/community_setting_item.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_setting/permission_setting/post/community_post_permission_page.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_setting/permission_setting/story/community_story_setting_page.dart';
import 'package:amity_uikit_beta_service/v4/utils/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:amity_uikit_beta_service/v4/core/base_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/community_setting_page_bloc.dart';

// ignore: must_be_immutable
class AmityCommunitySettingPage extends NewBasePage {
  AmityCommunitySettingPage({super.key, required this.community})
      : super(pageId: 'community_setting_page');

  late AmityCommunity community;

  @override
  Widget buildPage(BuildContext context) {
    return BlocProvider(
      create: (_) => CommunitySettingPageBloc(community),
      child: BlocBuilder<CommunitySettingPageBloc, CommunitySettingPageState>(
        builder: (context, state) {
          return _getPageWidget(context, state);
        },
      ),
    );
  }

  Widget _getPageWidget(BuildContext context, CommunitySettingPageState state) {
    return Scaffold(
        backgroundColor: theme.backgroundColor,
        appBar: AmityAppBar(
            title: community.displayName ?? "Unknown",
            configProvider: configProvider,
            theme: theme),
        body: ListView(
          children: [
            // Basic Info Section
            _getSectionTitleWidget(context.l10n.community_basic_info),

            if (state.shouldShowEditProfile)
              CommunitySettingItem(
                  'assets/Icons/amity_ic_edit_profile_setting.svg', onTap: () {
                _goToEditProfilePage(context);
              }, pageId: pageId, componentId: '*', elementId: 'edit_profile'),

            CommunitySettingItem('assets/Icons/amity_icon_member_setting.svg',
                onTap: () {
              _goToCommunityMemberPage(context);
            }, pageId: pageId, componentId: '*', elementId: 'members'),

            if (state.shouldShowNotificationSetting)
              Stack(
                alignment: Alignment.centerRight,
                children: [
                  CommunitySettingItem(
                      'assets/Icons/amity_ic_notification_setting.svg',
                      onTap: () {
                    _goToNotificationSettingPage(context, state);
                  },
                      pageId: pageId,
                      componentId: '*',
                      elementId: 'notifications'),
                  Positioned(
                    right: 45,
                    child: Text(
                        state.isNotificationEnabled
                            ? context.l10n.general_on
                            : context.l10n.general_off,
                        style: TextStyle(
                            color: theme.baseColorShade1,
                            fontSize: 15,
                            fontWeight: FontWeight.w400)),
                  ),
                ],
              ),

            _getDividerWidget(),

            // Community Permission Section
            if (state.shouldShowPostPermission || state.shouldShowStoryComments)
              _getSectionTitleWidget(context.l10n.settings_permissions),

            if (state.shouldShowPostPermission)
              CommunitySettingItem(
                  'assets/Icons/amity_ic_post_permission_setting.svg',
                  onTap: () {
                _goToPostPermissionSettingPage(context);
              },
                  pageId: pageId,
                  componentId: '*',
                  elementId: 'post_permission'),

            if (state.shouldShowStoryComments)
              CommunitySettingItem(
                  'assets/Icons/amity_ic_story_comment_setting.svg', onTap: () {
                _goToStoryCommentSettingPage(context);
              }, pageId: pageId, componentId: '*', elementId: 'story_setting'),

            if (state.shouldShowPostPermission || state.shouldShowStoryComments)
              _getDividerWidget(),

            // Leave Community
            _getSettingDetailItemWidget(
                configProvider.getConfig('$pageId/*/leave_community')['text'],
                null, onTap: () {
              ConfirmationDialog().show(
                  context: context,
                  title: context.l10n.community_leave,
                  detailText:context.l10n.community_leave_description,
                  onConfirm: () {
                    context
                        .read<CommunitySettingPageBloc>()
                        .add(LeaveCommunityEvent(
                            toastBloc: context.read<AmityToastBloc>(),
                            onSuccess: () {
                              // Navigate back to the social home page
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            },
                            onFailure: () {
                              AmityDialog().showAlertErrorDialog(
                                  title: context.l10n.error_leave_community,
                                  message:context.l10n.error_leave_community_description);
                            }));
                  });
            }),

            _getDividerWidget(),

            // Close Community
            if (state.shouldShowCloseCommunity)
              _getSettingDetailItemWidget(
                  configProvider.getConfig('$pageId/*/close_community')['text'],
                  configProvider.getConfig(
                      '$pageId/*/close_community_description')['text'],
                  onTap: () {
                ConfirmationDialog().show(
                    context: context,
                    title: context.l10n.community_close,
                    detailText: context.l10n.community_close_description,
                    onConfirm: () {
                      context
                          .read<CommunitySettingPageBloc>()
                          .add(CloseCommunityEvent(
                              toastBloc: context.read<AmityToastBloc>(),
                              onSuccess: () {
                                // Navigate back to the social home page
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                              },
                              onFailure: () {
                                AmityDialog().showAlertErrorDialog(
                                    title: context.l10n.error_close_community,
                                    message: context.l10n
                                        .error_close_community_description);
                              }));
                    });
              }),

            _getDividerWidget(),
          ],
        ));
  }

  Widget _getSectionTitleWidget(String title) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
        child: Text(title,
            style: TextStyle(
                color: theme.baseColor,
                fontSize: 17,
                fontWeight: FontWeight.w600)));
  }

  Widget _getSettingDetailItemWidget(String title, String? detail,
      {GestureTapCallback? onTap}) {
    return GestureDetector(
        onTap: onTap,
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(title,
                    style: TextStyle(
                        color: theme.alertColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
                subtitle: detail != null
                    ? Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 8),
                        child: Text(detail,
                            style: TextStyle(
                                color: theme.baseColorShade1,
                                fontSize: 13,
                                fontWeight: FontWeight.w400)))
                    : null)));
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

  void _goToEditProfilePage(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) =>
            AmityCommunitySetupPage(mode: EditMode(community))));
  }

  void _goToCommunityMemberPage(BuildContext context) {
    if (community.communityId != null) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) =>
              AmityCommunityMembershipPage(community: community)));
    }
  }

  void _goToNotificationSettingPage(
      BuildContext context, CommunitySettingPageState state) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AmityCommunityNotificationSettingPage(
              community: community,
              notificationSettings: state.notificationSettings)),
    );
    context
        .read<CommunitySettingPageBloc>()
        .add(const CommunityNotificationSettingPageLoadEvent());
  }

  void _goToPostPermissionSettingPage(BuildContext context) {
    // Navigator.of(context).push(MaterialPageRoute(
    //     builder: (context) => PostReviewPage(community: community)));
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            AmityCommunityPostPermissionPage(community: community)));
  }

  void _goToStoryCommentSettingPage(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            AmityCommunityStorySettingPage(community: community)));
  }
}
