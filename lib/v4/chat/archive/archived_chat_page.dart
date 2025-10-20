import 'package:amity_uikit_beta_service/v4/chat/home/archived_chat_list_component.dart';
import 'package:amity_uikit_beta_service/v4/core/Network/network_connectivity_bloc.dart';
import 'package:amity_uikit_beta_service/v4/core/base_component.dart';
import 'package:amity_uikit_beta_service/v4/core/base_page.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class AmityArchivedChatPage extends NewBasePage {
  AmityArchivedChatPage({super.key}) : super(pageId: 'archived_chat_page');

  @override
  Widget buildPage(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ArchivedChatPageNavigationBar(),
      ),
      backgroundColor: theme.backgroundColor,
      body: ArchivedChatListComponent(),
    );
  }
}

class ArchivedChatPageNavigationBar extends NewBaseComponent {
  ArchivedChatPageNavigationBar({Key? key, String? pageId})
      : super(key: key, pageId: pageId, componentId: 'archived_chat_top_navigation');

  @override
  Widget buildComponent(BuildContext context) {
    return BlocProvider(
      create: (context) => NetworkConnectivityBloc(),
      child: BlocBuilder<NetworkConnectivityBloc, NetworkConnectivityState>(
        builder: (context, state) {
          return AppBar(
            automaticallyImplyLeading: false,
            titleSpacing: 4,
            title: Text("Archived chats", style: AmityTextStyle.headline(theme.baseColor)),
            centerTitle: true,
            leadingWidth: 65,
            leading: Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: IconButton(
                icon: SvgPicture.asset(
                  "assets/Icons/amity_ic_back_button.svg",
                  package: 'amity_uikit_beta_service',
                  color: theme.baseColor,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            backgroundColor: theme.backgroundColor,
            elevation: 0,
            actions: const [],
            iconTheme: const IconThemeData(color: Colors.black),
          );
        },
      ),
    );
  }
}