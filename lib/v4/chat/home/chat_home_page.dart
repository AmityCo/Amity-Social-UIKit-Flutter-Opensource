import 'package:amity_uikit_beta_service/v4/chat/create/channel_create_conversation_page.dart';
import 'package:amity_uikit_beta_service/v4/chat/home/chat_list_component.dart';
import 'package:amity_uikit_beta_service/v4/core/base_component.dart';
import 'package:amity_uikit_beta_service/v4/core/base_page.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/core/Network/network_connectivity_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/cupertino.dart';

class AmityChatHomePage extends NewBasePage {
  AmityChatHomePage({super.key}) : super(pageId: 'chat_home_page');

  @override
  Widget buildPage(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ChatHomePageNavigationBar(),
      ),
      backgroundColor: theme.backgroundColor,
      body: ChatListComponent(),
    );
  }
}

class ChatHomePageNavigationBar extends NewBaseComponent {
  ChatHomePageNavigationBar({Key? key, String? pageId})
      : super(key: key, pageId: pageId, componentId: 'chat_top_navigation');

  @override
  Widget buildComponent(BuildContext context) {
    return BlocProvider(
      create: (context) => NetworkConnectivityBloc(),
      child: BlocBuilder<NetworkConnectivityBloc, NetworkConnectivityState>(
        builder: (context, state) {
          return AppBar(
            automaticallyImplyLeading: false,
            titleSpacing: 4,
            title: Visibility(
              visible: !state.isConnected,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CupertinoActivityIndicator(
                    radius: 8,
                  ),
                  const SizedBox(width: 4),
                  Text("Waiting for network...",
                      style: AmityTextStyle.caption(theme.baseColorShade1)),
                ],
              ),
            ),
            centerTitle: true,
            leadingWidth: 65,
            leading: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Chat", style: AmityTextStyle.headline(theme.baseColor)),
                ],
              ),
            ),
            backgroundColor: theme.backgroundColor,
            elevation: 0,
            actions: [AmityCreateChatMenuComponent()],
            iconTheme: const IconThemeData(color: Colors.black),
          );
        },
      ),
    );
  }
}

class AmityCreateChatMenuComponent extends NewBaseComponent {
  AmityCreateChatMenuComponent({Key? key, String? pageId})
      : super(key: key, pageId: pageId, componentId: 'chat_create_menu');

  @override
  Widget buildComponent(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: theme.secondaryColor.blend(ColorBlendingOption.shade4),
            shape: BoxShape.circle,
          ),
          child: PopupMenuButton<int>(
            color: theme.backgroundColor,
            surfaceTintColor: theme.backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 3,
            offset: const Offset(0, 36),
            icon: SvgPicture.asset(
              "assets/Icons/amity_ic_post_creation_button.svg",
              package: 'amity_uikit_beta_service',
              colorFilter: ColorFilter.mode(
                theme.secondaryColor,
                BlendMode.srcIn,
              ),
            ),
            padding: const EdgeInsets.all(5),
            onSelected: (int result) {
              if (result == 1) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      fullscreenDialog: true,
                      builder: (context) =>
                          AmityChannelCreateConversationPage()),
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
              PopupMenuItem<int>(
                value: 1,
                padding: EdgeInsets.zero,
                child: getMenu(
                    text: "New conversation",
                    iconPath: "amity_ic_chat_create_button.svg"),
              ),
            ],
          ),
        ),
        const SizedBox(
          width: 16,
        ),
      ],
    );
  }

  Widget getMenu({required String text, required String iconPath}) {
    return SizedBox(
      width: 200,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: SvgPicture.asset(
              "assets/Icons/$iconPath",
              package: 'amity_uikit_beta_service',
              width: 20,
              height: 20,
              colorFilter:
                  ColorFilter.mode(theme.secondaryColor, BlendMode.srcIn),
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          Text(text, style: AmityTextStyle.bodyBold(theme.baseColor)),
        ],
      ),
    );
  }
}
