import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/chat/group_message/amity_group_chat_page.dart';
import 'package:amity_uikit_beta_service/v4/chat/home/base_chat_list_component.dart';
import 'package:amity_uikit_beta_service/v4/chat/message/chat_page.dart';
import 'package:amity_uikit_beta_service/v4/chat/search/bloc/amity_search_channel_cubit.dart';
import 'package:amity_uikit_beta_service/v4/chat/search/bloc/search_channel_archive_cubit.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/utils/amity_dialog.dart';
import 'package:amity_uikit_beta_service/v4/utils/config_provider.dart';
import 'package:amity_uikit_beta_service/v4/utils/shimmer_widget.dart';
import 'package:amity_uikit_beta_service/v4/utils/skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SearchChannelResults extends StatelessWidget {
  final List<AmityChannel> channels;
  final ScrollController scrollController;
  final AmityThemeColor theme;
  final String searchQuery;
  final List<String> archivedChannelIds;
  final Map<int, AmityMessage> indexToMessageMap;
  final Map<String, AmityChannelMember?> channelMembers; // Added channelMembers parameter
  final SearchTab activeTab;
  final ConfigProvider configProvider; // Add ConfigProvider parameter
  final Function(String channelId, bool isArchiving)?
      onChannelArchiveStatusChanged; // Updated callback with channelId and action

  const SearchChannelResults({
    Key? key,
    required this.channels,
    required this.scrollController,
    required this.theme,
    required this.searchQuery,
    required this.archivedChannelIds,
    required this.indexToMessageMap,
    required this.channelMembers, // Added required channelMembers
    required this.activeTab,
    required this.configProvider, // Add required configProvider
    this.onChannelArchiveStatusChanged,
  }) : super(key: key);

  // Helper method to navigate to chat
  void _navigateToChat(BuildContext context, AmityChannel channel,
      AmityChannelMember? channelMember, int index) {
    // Get the message ID for jump functionality when in message search tab
    String? jumpToMessageId;
    if (activeTab == SearchTab.message && indexToMessageMap.containsKey(index)) {
      jumpToMessageId = indexToMessageMap[index]?.messageId;
    }

    if (channel.amityChannelType == AmityChannelType.CONVERSATION) {
      // For direct chat, use channelMember if available
      if (channelMember != null) {
        final userId = channelMember.userId;
        final userDisplayName = channelMember.user?.displayName ?? "";
        final avatarUrl = channelMember.user?.avatarUrl ?? "";

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AmityChatPage(
              key: Key("${channel.channelId ?? ""}_$userId"),
              channelId: channel.channelId,
              userId: userId ?? "",
              userDisplayName: userDisplayName,
              avatarUrl: avatarUrl,
              jumpToMessageId: jumpToMessageId,
            ),
          ),
        );
      } else {
        // Fallback: Load channel to get metadata about the other user
        AmityChatClient.newChannelRepository()
            .getChannel(channel.channelId!)
            .then((AmityChannel updatedChannel) {
          final metadata = updatedChannel.metadata;
          String? userId = "";
          String? userDisplayName = "";
          String? avatarUrl = "";

          // Extract user info from metadata if available
          if (metadata != null && metadata.containsKey("userId")) {
            userId = metadata["userId"] as String;
            userDisplayName = metadata["displayName"] as String? ?? "";
            avatarUrl = metadata["avatarUrl"] as String? ?? "";
          }

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AmityChatPage(
                key: Key("${channel.channelId ?? ""}_$userId"),
                channelId: channel.channelId,
                userId: userId,
                userDisplayName: userDisplayName,
                avatarUrl: avatarUrl,
                jumpToMessageId: jumpToMessageId,
              ),
            ),
          );
        }).catchError((error) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AmityChatPage(
                channelId: channel.channelId,
                jumpToMessageId: jumpToMessageId,
              ),
            ),
          );
        });
      }
    } else if (channel.amityChannelType == AmityChannelType.COMMUNITY) {
      // Navigate to group chat
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AmityGroupChatPage(
            channelId: channel.channelId!,
            jumpToMessageId: jumpToMessageId,
          ),
        ),
      );
    }
  }

  // Helper method to create a dismissible item for archive/unarchive
  Widget _buildDismissibleItem(
      BuildContext context,
      AmityChannel channel,
      AmityChannelMember? channelMember,
      String assetIcon,
      String actionText,
      Function(DismissDirection) onDismissed,
      int index) {
    return Dismissible(
      key: Key("search_item_${channel.channelId ?? ""}"),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        onDismissed(direction);
        return false;
      },
      background: Container(
        color: theme.baseColorShade2,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              assetIcon,
              package: 'amity_uikit_beta_service',
              width: 28,
              height: 28,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              actionText,
              style: AmityTextStyle.captionBold(Colors.white),
            ),
          ],
        ),
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => _navigateToChat(context, channel, channelMember, index),
        child: ChatListItem(
          channel: channel,
          channelMember: channelMember,
          searchQuery: searchQuery,
          isArchived: archivedChannelIds.contains(channel.channelId ?? ''),
          searchMessage: activeTab == SearchTab.message 
              ? indexToMessageMap[index] 
              : null,
        ),
      ),
    );
  }

  // Helper method to build skeleton items with shimmer effect
  Widget _buildSkeletonItem(ConfigProvider configProvider) {
    return ShimmerLoading(
      isLoading: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 21),
        child: const Row(
          children: [
            SkeletonImage(width: 40, height: 40, borderRadius: 20),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonText(width: 140, height: 10),
                SizedBox(height: 12),
                SkeletonText(width: 200, height: 10),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatSearchArchiveCubit(
        toastBloc: BlocProvider.of<AmityToastBloc>(context),
      ),
      child: BlocConsumer<ChatSearchArchiveCubit, ChatSearchArchiveState>(
        listener: (context, state) {
          if (state.showArchiveErrorDialog) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              AmityV4Dialog().showAlertErrorDialog(
                title: state.errorTitle ?? 'Error',
                message: state.errorMessage ?? 'An error occurred',
                closeText: 'OK',
              );
              context.read<ChatSearchArchiveCubit>().resetDialogState();
            });
          }
        },
        builder: (context, state) {
          return BlocBuilder<AmityChatSearchCubit, AmitySearchChannelState>(
            builder: (context, searchState) {
              // Calculate item count: channels + skeleton items if loading more
              final skeletonCount = searchState.isLoadingMore ? 3 : 0;
              final totalItemCount = channels.length + skeletonCount;
              
              return Shimmer(
                linearGradient: configProvider.getShimmerGradient(),
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: totalItemCount,
                  itemBuilder: (context, index) {
                    // Show skeleton items at the bottom when loading more
                    if (index >= channels.length) {
                      return _buildSkeletonItem(configProvider);
                    }
                    
                    final channel = channels[index];
                    final channelMember = channelMembers[channel.channelId]; // Get channelMember from the map

              // Enable archive/unarchive for both CONVERSATION and COMMUNITY channels
              if (channel.amityChannelType == AmityChannelType.CONVERSATION || 
                  channel.amityChannelType == AmityChannelType.COMMUNITY) {
                // Check if the channel is already archived
                final isArchived =
                    archivedChannelIds.contains(channel.channelId ?? '');

                if (isArchived) {
                  // Show unarchive option for archived channels
                  return _buildDismissibleItem(
                    context,
                    channel,
                    channelMember,
                    "assets/Icons/amity_ic_channel_unarchive.svg",
                    "Unarchive",
                    (direction) {
                      // Prevent multiple simultaneous operations
                      if (state.isArchiving) return;
                      
                      context
                          .read<ChatSearchArchiveCubit>()
                          .unarchiveChannel(channel.channelId!)
                          .then((success) {
                        if (success && onChannelArchiveStatusChanged != null) {
                          onChannelArchiveStatusChanged!(
                              channel.channelId!, false);
                        }
                      });
                    },
                    index,
                  );
                } else {
                  // Show archive option for non-archived channels
                  return _buildDismissibleItem(
                    context,
                    channel,
                    channelMember,
                    "assets/Icons/amity_ic_channel_archive.svg",
                    "Archive",
                    (direction) {
                      // Prevent multiple simultaneous operations
                      if (state.isArchiving) return;
                      
                      context
                          .read<ChatSearchArchiveCubit>()
                          .archiveChannel(channel.channelId!)
                          .then((success) {
                        if (success && onChannelArchiveStatusChanged != null) {
                          onChannelArchiveStatusChanged!(
                              channel.channelId!, true);
                        }
                      });
                    },
                    index,
                  );
                }
              } else {
                return GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => _navigateToChat(context, channel, channelMember, index),
                  child: ChatListItem(
                    channel: channel,
                    channelMember: channelMember,
                    searchQuery: searchQuery,
                    isArchived:
                        archivedChannelIds.contains(channel.channelId ?? ''),
                    searchMessage: activeTab == SearchTab.message 
                        ? indexToMessageMap[index] 
                        : null,
                  ),
                );
              }
            },
          ),
        );
      },
    );
  },
  ));
  }
}
