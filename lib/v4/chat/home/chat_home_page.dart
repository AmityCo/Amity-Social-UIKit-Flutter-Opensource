import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:amity_uikit_beta_service/v4/chat/archive/archived_chat_page.dart';
import 'package:amity_uikit_beta_service/v4/chat/create/channel_create_conversation_page.dart';
import 'package:amity_uikit_beta_service/v4/chat/createGroup/ui/amity_select_group_member_page.dart';
import 'package:amity_uikit_beta_service/v4/chat/home/amity_all_chat_list_component.dart';
import 'package:amity_uikit_beta_service/v4/chat/home/amity_conversation_chat_list_component.dart';
import 'package:amity_uikit_beta_service/v4/chat/home/amity_group_chat_list_component.dart';
import 'package:amity_uikit_beta_service/v4/core/Network/network_connectivity_bloc.dart';
import 'package:amity_uikit_beta_service/v4/core/base_component.dart';
import 'package:amity_uikit_beta_service/v4/core/base_page.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/amity_uikit_toast.dart';
import 'package:amity_uikit_beta_service/v4/utils/config_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class AmityChatHomePage extends NewBasePage {
  AmityChatHomePage({super.key}) : super(pageId: 'chat_home_page');

  @override
  Widget buildPage(BuildContext context) {
    return Builder(
      builder: (context) {
        // Use Provider.of to get the config provider
        final configProvider = Provider.of<ConfigProvider>(context);
        final theme = configProvider.getTheme('chat_home_page', '');

        final allChatsWidget = AmityAllChatListComponent();
        final directChatsWidget = AmityConversationChatListComponent();
        final groupChatsWidget = AmityGroupChatListComponent();

        return DefaultTabController(
          length: 3,
          animationDuration: const Duration(milliseconds: 200),
          child: Builder(
            builder: (context) {
              final TabController tabController =
                  DefaultTabController.of(context);

              return AnimatedBuilder(
                animation: tabController,
                builder: (context, _) {
                  return Stack(
                    children: [
                      Scaffold(
                        appBar: PreferredSize(
                          preferredSize: const Size.fromHeight(kToolbarHeight),
                          child: ChatHomePageNavigationBar(),
                        ),
                        backgroundColor: theme.backgroundColor,
                        body: Column(
                          children: [
                            _ChatTabs(),
                            const SizedBox(height: 8),
                            Expanded(
                              child: IndexedStack(
                                index: tabController.index,
                                children: [
                                  allChatsWidget,
                                  directChatsWidget,
                                  groupChatsWidget,
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      AmityToast(pageId: pageId, elementId: "toast"),
                    ],
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

class _ChatTabs extends NewBaseComponent {
  _ChatTabs({Key? key})
      : super(key: key, pageId: 'chat_home_page', componentId: 'chat_tabs');

  @override
  Widget buildComponent(BuildContext context) {
    // Get the TabController from the DefaultTabController ancestor
    final TabController tabController = DefaultTabController.of(context);

    // Using AnimatedBuilder to rebuild when the tabController changes
    return AnimatedBuilder(
      animation: tabController,
      builder: (context, _) {
        return Container(
          alignment: AlignmentDirectional.centerStart,
          color: theme.backgroundColor,
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTabButton(context, 'All', 0, tabController),
                _buildTabButton(context, 'Direct', 1, tabController),
                _buildTabButton(context, 'Groups', 2, tabController),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabButton(BuildContext context, String text, int index,
      TabController tabController) {
    final isSelected = tabController.index == index;

    // Get localized text based on index
    String localizedText;
    switch (index) {
      case 0:
        localizedText = context.l10n.chat_tab_all;
        break;
      case 1:
        localizedText = context.l10n.chat_tab_direct;
        break;
      case 2:
        localizedText = context.l10n.chat_tab_groups;
        break;
      default:
        localizedText = text;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: IntrinsicWidth(
        child: ElevatedButton(
          onPressed: () => tabController.animateTo(index),
          style: ElevatedButton.styleFrom(
            foregroundColor: isSelected ? Colors.white : theme.baseColorShade1,
            backgroundColor:
                isSelected ? theme.primaryColor : Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            side: BorderSide(
              color: isSelected ? theme.primaryColor : theme.baseColorShade4,
              width: 1.0,
            ),
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            localizedText,
            style: TextStyle(
              fontSize: 17,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
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
                  Text(context.l10n.chat_waiting_for_network,
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
                  Text(context.l10n.chat_title,
                      style: AmityTextStyle.headline(theme.baseColor)),
                ],
              ),
            ),
            backgroundColor: theme.backgroundColor,
            elevation: 0,
            actions: [AmityCreateChatMenuComponent(), AmityChatMenuComponent()],
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
              } else if (result == 2) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      fullscreenDialog: true,
                      builder: (context) => AmitySelectGroupMemberPage()),
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
              PopupMenuItem<int>(
                value: 1,
                padding: EdgeInsets.zero,
                child: getMenu(
                    text: context.l10n.chat_direct_chat,
                    iconPath: "amity_ic_chat_create_button.svg"),
              ),
              PopupMenuItem<int>(
                value: 2,
                padding: EdgeInsets.zero,
                child: getMenu(
                    text: context.l10n.chat_group_chat,
                    iconPath: "amity_ic_create_group_chat_button.svg"),
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

class AmityChatMenuComponent extends NewBaseComponent {
  AmityChatMenuComponent({Key? key, String? pageId})
      : super(key: key, pageId: pageId, componentId: 'chat_menu');

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
              "assets/Icons/amity_ic_chat_home_option.svg",
              package: 'amity_uikit_beta_service',
            ),
            padding: const EdgeInsets.all(5),
            onSelected: (int result) {
              if (result == 1) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      fullscreenDialog: true,
                      builder: (context) => AmityArchivedChatPage()),
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
              PopupMenuItem<int>(
                value: 1,
                padding: EdgeInsets.zero,
                child: getMenu(
                    text: context.l10n.chat_archived,
                    iconPath: "amity_ic_archived_chat_menu.svg"),
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

// Widget to keep alive tab content for prefetching
class KeepAliveTabView extends StatefulWidget {
  final Widget child;

  const KeepAliveTabView({Key? key, required this.child}) : super(key: key);

  @override
  State<KeepAliveTabView> createState() => _KeepAliveTabViewState();
}

class _KeepAliveTabViewState extends State<KeepAliveTabView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
