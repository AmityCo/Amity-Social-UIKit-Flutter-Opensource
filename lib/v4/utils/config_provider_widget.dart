import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/social/newsfeed/amity_news_feed_component.dart';
import 'package:amity_uikit_beta_service/v4/social/social_home_page/social_home_page.dart';
import 'package:amity_uikit_beta_service/v4/social/story/create/amity_create_story_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config_provider.dart';

class SocialHomePageConfigProviderWidget extends StatelessWidget {
  const SocialHomePageConfigProviderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Consumer<ConfigProvider>(
          builder: (context, configProvider, child) {
            return AmitySocialHomePage();
          },
        ),
    );
  }
}

class NewsFeedComponentConfigProviderWidget extends StatelessWidget {
  final String pageId;

  const NewsFeedComponentConfigProviderWidget(
      {super.key, required this.pageId});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConfigProvider>(
      builder: (context, configProvider, child) {
        return AmityNewsFeedComponent();
      },
    );
  }
}

class CreateStoryConfigProviderWidget extends StatelessWidget {
  final String pageId;
  final AmityStoryTargetType targetType;
  final String targetId;

  const CreateStoryConfigProviderWidget({
    super.key,
    required this.pageId,
    required this.targetType,
    required this.targetId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ConfigProvider>(
      builder: (context, configProvider, child) {
        return AmityCreateStoryPage(
          targetType: AmityStoryTargetType.COMMUNITY,
          targetId: targetId,
        );
      },
    );
  }
}