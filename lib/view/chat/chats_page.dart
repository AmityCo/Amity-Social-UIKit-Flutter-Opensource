import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/configuration_viewmodel.dart';
import 'chat_friend_tab.dart';

class ChatsPage extends StatelessWidget {
  const ChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: Scaffold(
        appBar: TabBar(
          physics: const BouncingScrollPhysics(),
          isScrollable: true,
          indicatorColor:
              Provider.of<AmityUIConfiguration>(context).primaryColor,
          labelColor: Provider.of<AmityUIConfiguration>(context).primaryColor,
          unselectedLabelColor: Colors.black,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [
            Tab(text: "Group")
            // Tab(text: S.of(context).groups),)
          ],
        ),
        body: const TabBarView(
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
