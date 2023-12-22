import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/components/custom_user_avatar.dart';
import 'package:amity_uikit_beta_service/view/social/user_follower_component.dart';
import 'package:amity_uikit_beta_service/view/social/user_following_component.dart';
import 'package:amity_uikit_beta_service/viewmodel/follower_following_viewmodel.dart';
import 'package:animation_wrappers/animations/faded_slide_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/configuration_viewmodel.dart';

class FollowScreen extends StatefulWidget {
  final AmityUser user;
  const FollowScreen({super.key, required this.user});

  @override
  State<FollowScreen> createState() => _FollowScreenState();
}

class _FollowScreenState extends State<FollowScreen> {
  TabController? _tabController;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.user.displayName ?? "displayname is null",
          style: Theme.of(context).textTheme.headline6!.copyWith(fontSize: 24),
        ),
      ),
      backgroundColor: Provider.of<AmityUIConfiguration>(context)
          .messageRoomConfig
          .backgroundColor,
      body: SafeArea(
        bottom: false,
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
            body: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  indicatorColor:
                      Provider.of<AmityUIConfiguration>(context).primaryColor,
                  tabs: [
                    Tab(
                      child: Text(
                        "Follower",
                        style: theme.textTheme.bodyText1,
                      ),
                    ),
                    Tab(
                      child: Text(
                        "Following",
                        style: theme.textTheme.bodyText1,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Consumer<FollowerVM>(builder: (context, vm, _) {
                    return TabBarView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        AmityFollowerScreen(
                          userId: widget.user.userId!,
                        ),
                        AmityFollowingScreen(
                          userId: widget.user.userId!,
                        ),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
