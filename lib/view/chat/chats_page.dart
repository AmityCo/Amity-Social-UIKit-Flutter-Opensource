import 'package:flutter/material.dart';

import 'chat_friend_tab.dart';

class ChatsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return DefaultTabController(
      length: 1,
      child: Scaffold(
        appBar: TabBar(
          physics: BouncingScrollPhysics(),
          isScrollable: true,
          indicatorColor: theme.primaryColor,
          labelColor: theme.primaryColor,
          unselectedLabelColor: Colors.black,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: [
            const Tab(text: "Group")
            // Tab(text: S.of(context).groups),)
          ],
        ),
        body: TabBarView(
          physics: BouncingScrollPhysics(),
          children: [
            AmitySLEChannelScreen(),
            // ChatGroupTabScreen(),
          ],
        ),
      ),
    );
  }
}
