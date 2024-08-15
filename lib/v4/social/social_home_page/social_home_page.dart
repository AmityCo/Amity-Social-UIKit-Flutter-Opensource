import 'package:amity_uikit_beta_service/v4/core/base_page.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/amity_uikit_toast.dart';
import 'package:amity_uikit_beta_service/v4/social/globalfeed/tab_content/scrollable_tab.dart';
import 'package:amity_uikit_beta_service/v4/social/globalfeed/tab_content/tab_content.dart';
import 'package:amity_uikit_beta_service/v4/social/social_home_page/bloc/social_home_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/social_home_page/social_home_top_navigation_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SocialHomePage extends NewBasePage {
  SocialHomePage({super.key, required super.pageId});

  @override
  Widget buildPage(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AmitySocialHomeTopNavigationComponent(
            pageId: pageId, componentId: "top_navigation"),
      ),
      backgroundColor: theme.backgroundColor,
      body: BlocProvider(
        create: (_) => SocialHomeBloc(),
        child: Column(
          children: [
            ScrollableTabs(
              pageId: 'social_home_page',
            ),
            const Expanded(child: TabContent()),
            AmityToast(elementId: "toast"),
          ],
        ),
      ),
    );
  }
}
