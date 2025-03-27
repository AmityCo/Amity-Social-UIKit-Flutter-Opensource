import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:amity_uikit_beta_service/v4/core/base_page.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_setting/permission_setting/story/bloc/community_story_setting_page_bloc.dart';
import 'package:amity_uikit_beta_service/v4/utils/app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AmityCommunityStorySettingPage extends NewBasePage {
  AmityCommunityStorySettingPage({super.key, required this.community})
      : super(pageId: 'community_story_setting_page');

  late AmityCommunity community;

  @override
  Widget buildPage(BuildContext context) {
    return BlocProvider(
      create: (_) => CommunityStorySettingPageBloc(community: community),
      child: BlocBuilder<CommunityStorySettingPageBloc,
          CommunityStorySettingPageState>(
        builder: (context, state) {
          return _getPageWidget(context, state);
        },
      ),
    );
  }

  Widget _getPageWidget(
      BuildContext context, CommunityStorySettingPageState state) {
    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AmityAppBar(
            title: community.displayName ?? "Unknown",
            configProvider: configProvider,
            theme: theme),
      body:  _getToggleSettingWidget(context, state)
    );
  }

  Widget _getToggleSettingWidget(
      BuildContext context, CommunityStorySettingPageState state) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.settings_allow_stories_comments,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: theme.baseColor),
                    ),
                    SizedBox(height: 4), // Reduced padding
                    Text(
                      context.l10n.settings_allow_stories_comments_description,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: theme.baseColorShade1),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 8.0), // Adjust the left padding as needed
                child: CupertinoSwitch(
                  value: state.isCommentEnabled,
                  onChanged: (bool value) {
                    context.read<CommunityStorySettingPageBloc>().add(
                        CommunityStorySettingChangedEvent(
                            isCommentEnabled: value));
                  },
                  activeColor: theme.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
