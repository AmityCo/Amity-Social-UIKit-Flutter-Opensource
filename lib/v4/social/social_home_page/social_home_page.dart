import 'package:amity_uikit_beta_service/v4/core/base_page.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/amity_uikit_toast.dart';
import 'package:amity_uikit_beta_service/v4/social/global_search/global_search_page.dart';
import 'package:amity_uikit_beta_service/v4/social/globalfeed/tab_content/scrollable_tab.dart';
import 'package:amity_uikit_beta_service/v4/social/globalfeed/tab_content/tab_content.dart';
import 'package:amity_uikit_beta_service/v4/social/my_community_search/my_community_search_page.dart';
import 'package:amity_uikit_beta_service/v4/social/social_home_page/bloc/social_home_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/social_home_page/bloc/social_home_state.dart';
import 'package:amity_uikit_beta_service/v4/social/social_home_page/social_home_top_navigation_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AmitySocialHomePage extends NewBasePage {
  AmitySocialHomePage({super.key}) : super(pageId: 'social_home_page');

  @override
  Widget buildPage(BuildContext context) {
    return BlocProvider(
      create: (context) => SocialHomeBloc(),
      child: Builder(builder: (context) {
        return BlocBuilder<SocialHomeBloc, SocialHomeState>(
          builder: (context, state) {
            AmitySocialHomePageTab currentTab = AmitySocialHomePageTab.newsFeed;

            if (state is TabState) {
              if (state.selectedIndex == 0) {
                currentTab = AmitySocialHomePageTab.newsFeed;
              } else if (state.selectedIndex == 1) {
                currentTab = AmitySocialHomePageTab.explore;
              } else {
                currentTab = AmitySocialHomePageTab.myCommunities;
              }
            }
            return Scaffold(
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(kToolbarHeight),
                child: AmitySocialHomeTopNavigationComponent(
                  pageId: pageId,
                  selectedTab: currentTab,
                  searchButtonAction: () {
                    if (currentTab == AmitySocialHomePageTab.newsFeed) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AmitySocialGlobalSearchPage(),
                        ),
                      );
                    } else if (currentTab ==
                        AmitySocialHomePageTab.myCommunities) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AmityMyCommunitiesSearchPage(),
                        ),
                      );
                    }
                  },
                ),
              ),
              backgroundColor: theme.backgroundColor,
              body: Column(
                children: [
                  ScrollableTabs(
                    pageId: 'social_home_page',
                  ),
                  const Expanded(child: TabContent()),
                  AmityToast(pageId: pageId, elementId: "toast"),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
