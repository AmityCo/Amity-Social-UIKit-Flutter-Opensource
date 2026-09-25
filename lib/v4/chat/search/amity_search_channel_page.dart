import 'package:amity_uikit_beta_service/v4/core/base_page.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/core/theme/amity_color_token.dart';
import 'package:amity_uikit_beta_service/v4/core/ui/atoms/amity_empty_state.dart';
import 'package:amity_uikit_beta_service/v4/chat/search/bloc/amity_search_channel_cubit.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/top_search_bar/top_search_bar.dart';
import 'package:amity_uikit_beta_service/v4/utils/debouncer.dart';
import 'package:amity_uikit_beta_service/v4/chat/search/widgets/search_channel_results.dart';
import 'package:flutter/material.dart';
import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:amity_uikit_beta_service/v4/chat/home/chat_list_skeleton.dart';

class AmitySearchChannelPage extends NewBasePage {
  AmitySearchChannelPage({Key? key}) : super(key: key, pageId: 'search_channel_page');

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
            backgroundColor: token(AmityColorToken.surfacePageBackgroundDefault),
            body: SafeArea(
              child: Column(
                children: [
                  AmityTopSearchBarComponent(
                    pageId: pageId,
                    textcontroller: textController,
                    hintText: context.l10n.general_search_hint,
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
                        labelColor: token(AmityColorToken.textTabUnderlinedActive),
                        labelStyle: AmityTextStyle.titleBold(token(AmityColorToken.textTabUnderlinedActive)),
                        unselectedLabelColor: token(AmityColorToken.textTabUnderlinedDefault),
                        unselectedLabelStyle: AmityTextStyle.titleBold(token(AmityColorToken.textTabUnderlinedDefault)),
                        indicatorColor: token(AmityColorToken.lineTabUnderlinedActive),
                        dividerColor: token(AmityColorToken.lineDividerContentDefault),
                        dividerHeight: 1.0,
                        splashFactory: NoSplash.splashFactory,
                        overlayColor: MaterialStateProperty.all(Colors.transparent),
                        onTap: (index) {
                          context.read<AmityChatSearchCubit>().changeTab(
                                index == 0 ? SearchTab.chat : SearchTab.message,
                              );
                        },
                        tabs: [
                          Tab(text: context.l10n.chat_search_tab_chats),
                          Tab(text: context.l10n.chat_search_tab_messages),
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
                          return AmityEmptyState(
                            variant: AmityEmptyStateVariant.icon,
                            asset: 'assets/Icons/amity_ic_start_search_chat.svg',
                            title: context.l10n.search_minimum_chars,
                          );
                        }

                        if (state.channels.isEmpty && state.query.length >= 3) {
                          return Align(
                            alignment: Alignment.topCenter,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 114),
                              child: AmityEmptyState(
                                variant: AmityEmptyStateVariant.icon,
                                asset: 'assets/Icons/amity_ic_search_chat_error.svg',
                                title: context.l10n.search_no_results,
                              ),
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
