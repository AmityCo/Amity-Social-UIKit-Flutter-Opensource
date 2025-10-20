import 'package:amity_uikit_beta_service/v4/core/base_page.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/chat/search/bloc/amity_search_channel_cubit.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/top_search_bar/top_search_bar.dart';
import 'package:amity_uikit_beta_service/v4/utils/debouncer.dart';
import 'package:amity_uikit_beta_service/v4/chat/search/widgets/search_channel_results.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:amity_uikit_beta_service/v4/chat/home/chat_list_skeleton.dart';

class AmitySearchChannelhPage extends NewBasePage {
  AmitySearchChannelhPage({Key? key}) : super(key: key, pageId: 'search_channel_page');

  final scrollController = ScrollController();
  final textController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 300);

  @override
  Widget buildPage(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AmityChatSearchCubit()),
      ],
      child: Builder(builder: (context) {
        // Setup scroll listener for pagination
        scrollController.addListener(() {
          if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 200) {
            context.read<AmityChatSearchCubit>().loadMore();
          }
        });
        
        // Add listener to text controller to handle clear button
        textController.addListener(() {
          // This ensures the UI rebuilds when text is cleared via the clear button
          final trimmedText = textController.text.trim();
          if (trimmedText.isEmpty) {
            _debouncer.run(() {
              context.read<AmityChatSearchCubit>().searchChats('');
            });
          }
        });
        
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: theme.backgroundColor,
            body: SafeArea(
              child: Column(
                children: [
                  AmityTopSearchBarComponent(
                    pageId: pageId,
                    textcontroller: textController,
                    hintText: 'Search',
                    onTextChanged: (value) {
                      final trimmedValue = value.trim();
                      _debouncer.run(() {
                        context.read<AmityChatSearchCubit>().searchChats(trimmedValue);
                      });
                    },
                  ),
                  BlocBuilder<AmityChatSearchCubit, AmitySearchChannelState>(
                    builder: (context, state) {
                      return TabBar(
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        indicatorSize: TabBarIndicatorSize.label,
                        labelColor: theme.primaryColor,
                        labelStyle: AmityTextStyle.titleBold(theme.primaryColor),
                        unselectedLabelColor: theme.baseColorShade2,
                        unselectedLabelStyle: AmityTextStyle.titleBold(theme.baseColorShade2),
                        indicatorColor: theme.primaryColor,
                        dividerColor: theme.baseColorShade4,
                        dividerHeight: 1.0,
                        splashFactory: NoSplash.splashFactory,
                        overlayColor: MaterialStateProperty.all(Colors.transparent),
                        onTap: (index) {
                          context.read<AmityChatSearchCubit>().changeTab(
                                index == 0 ? SearchTab.chat : SearchTab.message,
                              );
                        },
                        tabs: const [
                          Tab(text: 'Chats'),
                          Tab(text: 'Messages'),
                        ],
                      );
                    }
                  ),
                  Expanded(
                    child: BlocBuilder<AmityChatSearchCubit, AmitySearchChannelState>(
                      builder: (context, state) {
                        if (state.isLoading && state.channels.isEmpty) {
                          return ChatListSkeletonLoadingView();
                        }

                        if (state.query.length < 3 && state.channels.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  'assets/Icons/amity_ic_start_search_chat.svg',
                                  package: 'amity_uikit_beta_service',
                                  width: 60,
                                  height: 60,
                                  colorFilter: ColorFilter.mode(
                                    theme.secondaryColor.blend(ColorBlendingOption.shade4),
                                    BlendMode.srcIn,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Start your search by typing\nat least 3 letters',
                                  style: AmityTextStyle.title(theme.baseColorShade3),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        }

                        if (state.channels.isEmpty && state.query.length >= 3) {
                          return Container(
                            margin: const EdgeInsets.only(top: 114),
                            child: Column(
                              children: [
                                SvgPicture.asset(
                                  'assets/Icons/amity_ic_search_chat_error.svg',
                                  package: 'amity_uikit_beta_service',
                                  width: 60,
                                  height: 60,
                                  colorFilter: ColorFilter.mode(
                                    theme.secondaryColor
                                        .blend(ColorBlendingOption.shade4),
                                    BlendMode.srcIn,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No results found',
                                  style: AmityTextStyle.titleBold(theme.baseColorShade3),
                                ),
                              ],
                            ),
                          );
                        }
                        
                        // Display different content based on active tab
                        if (state.activeTab == SearchTab.chat) {
                          return SearchChannelResults(
                            channels: state.channels,
                            scrollController: scrollController,
                            theme: theme,
                            searchQuery: textController.text.trim().length >= 3 
                                ? textController.text.trim() 
                                : state.lastValidSearchText,
                            archivedChannelIds: state.archivedChannelIds,
                            indexToMessageMap: state.indexToMessageMap,
                            channelMembers: state.channelMembers, // Added channelMembers
                            activeTab: state.activeTab,
                            configProvider: configProvider, // Add configProvider
                            onChannelArchiveStatusChanged: (String channelId, bool isArchiving) {
                              // Update our local list of archived channel IDs
                              if (isArchiving) {
                                context.read<AmityChatSearchCubit>().markChannelAsArchived(channelId);
                              } else {
                                context.read<AmityChatSearchCubit>().markChannelAsUnarchived(channelId);
                              }
                            },
                          );
                        } else {
                          // Display message search results
                          return SearchChannelResults(
                            channels: state.channels,
                            scrollController: scrollController,
                            theme: theme,
                            searchQuery: textController.text.trim().length >= 3 
                                ? textController.text.trim() 
                                : state.lastValidSearchText,
                            archivedChannelIds: state.archivedChannelIds,
                            indexToMessageMap: state.indexToMessageMap,
                            channelMembers: state.channelMembers,
                            activeTab: state.activeTab,
                            configProvider: configProvider, // Add configProvider
                            onChannelArchiveStatusChanged: (String channelId, bool isArchiving) {
                              if (isArchiving) {
                                context.read<AmityChatSearchCubit>().markChannelAsArchived(channelId);
                              } else {
                                context.read<AmityChatSearchCubit>().markChannelAsUnarchived(channelId);
                              }
                            },
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
