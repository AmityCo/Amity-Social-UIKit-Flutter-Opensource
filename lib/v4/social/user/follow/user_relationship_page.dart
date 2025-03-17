import 'package:amity_uikit_beta_service/v4/core/base_page.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/social/user/follow/user_follow_list_component.dart';
import 'package:amity_uikit_beta_service/v4/social/user/profile/bloc/user_profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum AmityUserRelationshipPageTab { follower, following }

class AmityUserRelationshipPage extends NewBasePage {
  final String userId;
  AmityUserRelationshipPageTab selectedTab;

  AmityUserRelationshipPage({
    super.key,
    required this.userId,
    required this.selectedTab,
  }) : super(pageId: 'user_relationship_page');

  @override
  Widget buildPage(BuildContext context) {
    return BlocProvider(
      create: (context) => UserProfileBloc(userId),
      child: BlocBuilder<UserProfileBloc, UserProfileState>(
          builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(state.user?.displayName ?? "",
                style: AmityTextStyle.titleBold(theme.baseColor)),
            backgroundColor: theme.backgroundColor,
            //scrolledUnderElevation: 0,
            leading: IconButton(
              icon: Icon(Icons.chevron_left, color: theme.baseColor),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          backgroundColor: theme.backgroundColor,
          body: DefaultTabController(
              length: 2,
              initialIndex:
                  selectedTab == AmityUserRelationshipPageTab.following ? 0 : 1,
              child: Column(
                children: [
                  TabBar(
                    tabAlignment: TabAlignment.start,
                    labelColor: theme.highlightColor,
                    unselectedLabelColor: theme.baseColorShade2,
                    indicatorColor: theme.highlightColor,
                    dividerColor: theme.baseColorShade4,
                    isScrollable: true,
                    labelStyle: AmityTextStyle.titleBold(theme.baseColorShade2),
                    tabs: const [
                      Tab(text: 'Following'),
                      Tab(text: 'Followers'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        UserFollowListComponent(
                          key: const Key("user-following-list"),
                          userId: userId,
                          selectedTab: AmityUserRelationshipPageTab.following,
                        ),
                        UserFollowListComponent(
                          key: const Key("user-follower-list"),
                          userId: userId,
                          selectedTab: AmityUserRelationshipPageTab.follower,
                        ),
                      ],
                    ),
                  ),
                ],
              )),
        );
      }),
    );
  }
}
