import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/chat/archive/archived_chat_list_empty_state.dart';
import 'package:amity_uikit_beta_service/v4/chat/group_message/amity_group_chat_page.dart';
import 'package:amity_uikit_beta_service/v4/chat/home/bloc/chat_list_bloc.dart';
import 'package:amity_uikit_beta_service/v4/chat/home/chat_list_empty_state.dart';
import 'package:amity_uikit_beta_service/v4/chat/home/chat_list_skeleton.dart';
import 'package:amity_uikit_beta_service/v4/chat/message/chat_page.dart';
import 'package:amity_uikit_beta_service/v4/core/base_component.dart';
import 'package:amity_uikit_beta_service/v4/core/base_element.dart';
import 'package:amity_uikit_beta_service/v4/core/channel_avatar.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/utils/amity_dialog.dart';
import 'package:amity_uikit_beta_service/v4/utils/bloc_extension.dart';
import 'package:amity_uikit_beta_service/v4/utils/compact_string_converter.dart';
import 'package:amity_uikit_beta_service/v4/utils/date_time_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BaseChatListComponent extends NewBaseComponent {
  BaseChatListComponent(
      {super.key,
      super.pageId,
      required super.componentId,
      required this.chatListType});

  final scrollController = ScrollController();
  final ChatListType chatListType;

  @override
  Widget buildComponent(BuildContext context) {
    return BlocBuilder<ChatListBloc, ChatListState>(
      builder: (context, state) {
        scrollController.addListener(() {
          if (scrollController.position.pixels ==
              scrollController.position.maxScrollExtent) {
            context.read<ChatListBloc>().addEvent(ChatListLoadNextPage());
          }
        });

        if (state.showArchiveErrorDialog) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showArchiveErrorDialog(context, state.error?.title ?? "Error",
                state.error?.message ?? "An error occurred");
            context
                .read<ChatListBloc>()
                .addEvent(ChatListEventResetDialogState());
          });
        }

        if (state.isLoading && state.channels.isEmpty) {
          return ChatListSkeletonLoadingView();
        } else if (!state.isLoading && state.channels.isEmpty) {
          if (chatListType == ChatListType.ARCHIVED) {
            return ArchivedChatListEmptyState(theme: theme);
          } else {
            return ChatListEmptyState(theme: theme);
          }
        } else {
          return Column(
            children: [
              if (!state.isPushNotificationEnabled)
                Container(
                  color: theme.backgroundShade1Color,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/Icons/amity_ic_chat_mute.svg',
                        package: 'amity_uikit_beta_service',
                        width: 12,
                        height: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "You have disabled notifications for chat",
                        style: TextStyle(
                            color: theme.baseColorShade1,
                            fontSize: 13,
                            fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: state.channels.length,
                  itemBuilder: (context, index) {
                    final channel = state.channels[index];
                    final channelMember = state
                        .channelMembers[channel.channelId]; // Other participant

                    return GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          if (channel.amityChannelType ==
                              AmityChannelType.COMMUNITY) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => AmityGroupChatPage(
                                        channelId: channel.channelId ?? "",
                                      )),
                            );
                          } else {
                            final channelId = channel.channelId;
                            final userId = channelMember?.userId;
                            final displayName =
                                channelMember?.user?.displayName;
                            final avatarUrl = channelMember?.user?.avatarUrl;

                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => AmityChatPage(
                                  key:
                                      Key("${channelId ?? ""}_${userId ?? ""}"),
                                  channelId: channelId,
                                  userId: userId ?? "",
                                  userDisplayName: displayName ?? "",
                                  avatarUrl: avatarUrl ?? "",
                                ),
                              ),
                            );
                          }
                        },
                        child: renderChatListItem(
                            context, chatListType, channel, channelMember));
                  },
                ),
              ),
            ],
          );
        }
      },
    );
  }

  void _showArchiveErrorDialog(
      BuildContext context, String errorTitle, String errorMessage) {
    AmityV4Dialog().showAlertErrorDialog(
      title: errorTitle,
      message: errorMessage,
      closeText: 'OK',
    );
  }

  Widget renderChatListItem(BuildContext context, ChatListType chatListType,
      AmityChannel channel, AmityChannelMember? channelMember) {
    if (chatListType == ChatListType.CONVERSATION) {
      return renderDismissibleListItem(chatListType, channel, channelMember,
          "assets/Icons/amity_ic_channel_archive.svg", "Archive", (direction) {
        context.read<ChatListBloc>().addEvent(
            ChatListEventChannelArchive(channelId: channel.channelId!));
      });
    } else if (chatListType == ChatListType.ARCHIVED) {
      return renderDismissibleListItem(
          chatListType,
          channel,
          channelMember,
          "assets/Icons/amity_ic_channel_unarchive.svg",
          "Unarchive", (direction) {
        context.read<ChatListBloc>().addEvent(
            ChatListEventChannelUnarchive(channelId: channel.channelId!));
      });
    } else {
      return ChatListItem(channel: channel, channelMember: channelMember);
    }
  }

  Widget renderDismissibleListItem(
      ChatListType chatListType,
      AmityChannel channel,
      AmityChannelMember? channelMember,
      String assetIcon,
      String actionText,
      void Function(DismissDirection)? onDismissed) {
    final channelId = channel.channelId;
    final userId = channelMember?.userId;
    return Dismissible(
        key: Key("item_${channelId ?? ""}_${userId ?? ""}"),
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) async {
          if (onDismissed != null) {
            onDismissed(direction);
          }
          return false;
        },
        background: Builder(builder: (context) {
          return Container(
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
          );
        }),
        child: ChatListItem(channel: channel, channelMember: channelMember));
  }
}

class ChatListItem extends BaseElement {
  final AmityChannel channel;
  final AmityChannelMember? channelMember; // Other member

  ChatListItem({
    Key? key,
    String? pageId,
    String? componentId,
    required this.channel,
    required this.channelMember,
  }) : super(
          key: key,
          pageId: pageId,
          componentId: componentId,
          elementId: 'chat-list-item',
        );

  @override
  Widget buildElement(BuildContext context) {
    Widget displayNameWidget;

    String? previewText;
    Widget? previewIcon;
    if (channel.messagePreview?.isDeleted == true) {
      previewText = "This message was deleted";
      previewIcon = SvgPicture.asset(
        'assets/Icons/amity_ic_preview_deleted_message.svg',
        package: 'amity_uikit_beta_service',
        width: 18,
        height: 18,
        color: theme.baseColorShade2,
      );
    } else {
      final previewMessage = channel.messagePreview?.data;

      if (previewMessage is MessageTextData) {
        previewText = previewMessage.text;
      } else if (previewMessage is MessageImageData) {
        previewText = "Sent a photo";
        previewIcon = SvgPicture.asset(
          'assets/Icons/amity_ic_preview_image_message.svg',
          package: 'amity_uikit_beta_service',
          width: 18,
          height: 20,
          color: theme.baseColorShade2,
        );
      } else if (previewMessage is MessageVideoData) {
        previewText = "Sent a video";
        previewIcon = SvgPicture.asset(
          'assets/Icons/amity_ic_preview_video_message.svg',
          package: 'amity_uikit_beta_service',
          width: 18,
          height: 20,
          color: theme.baseColorShade2,
        );
      } else if (previewMessage is MessageFileData ||
          previewMessage is MessageAudioData ||
          previewMessage is MessageCustomData) {
        // To be implement
        previewText = "No preview supported for this message type";
      } else {
        previewText = "No message yet";
      }
    }
    if (channel.amityChannelType == AmityChannelType.COMMUNITY) {
      displayNameWidget = Row(
        children: [
          Flexible(
            child: Text(
              channel.displayName ?? "",
              style: AmityTextStyle.titleBold(theme.baseColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 2),
          Text(
            "(${(channel.memberCount ?? 0).formattedCompactString()})",
            style: AmityTextStyle.caption(theme.baseColorShade2),
          ),
        ],
      );
    } else {
      var displayName = channelMember?.user?.displayName;

      if (channelMember?.user?.isDeleted == true ||
          displayName == null ||
          displayName.isEmpty) {
        displayName = "Unknown User";
      }

      displayNameWidget = Text(
        displayName,
        style: AmityTextStyle.titleBold(theme.baseColor),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    return Container(
      height: 82,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (channel.amityChannelType == AmityChannelType.COMMUNITY)
            AmityChannelAvatar.withChannel(
              channel: channel,
              avatarSize: const Size(40, 40),
              showPrivateBadge: (channel.isPublic == false),
            )
          else
            AmityChatAvatar(channelMember: channelMember),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                displayNameWidget,
                Row(
                  children: [
                    if (previewIcon != null) ...[
                      previewIcon,
                      const SizedBox(width: 4),
                    ],
                    Expanded(
                      child: Text(
                        previewText ?? "",
                        style: AmityTextStyle.body(theme.baseColorShade2),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              Text(channel.lastActivity?.toChatTimestamp() ?? "",
                  style: AmityTextStyle.caption(theme.baseColorShade2)),
              const SizedBox(height: 10),
              unreadCountWidget(channel.unreadCount ?? 0)
            ],
          ),
        ],
      ),
    );
  }

  Widget unreadCountWidget(int unreadCount) {
    if (unreadCount == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.alertColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        unreadCount > 99 ? '99+' : unreadCount.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class AmityChatAvatar extends BaseElement {
  final AmityChannelMember? channelMember;
  final String avatarPlaceholder =
      "assets/Icons/amity_ic_user_avatar_placeholder.svg";

  late final String? avatarUrl;
  late final bool isDeletedUser;
  late final String displayName;

  AmityChatAvatar(
      {required this.channelMember,
      super.key,
      super.pageId = "",
      super.componentId = "",
      super.elementId = "chat-avatar"}) {
    avatarUrl = channelMember?.user?.avatarUrl;
    isDeletedUser = channelMember?.isDeleted ?? true;
    displayName = channelMember?.user?.displayName ?? "";
  }

  @override
  Widget buildElement(BuildContext context) {
    if (isDeletedUser) {
      return SvgPicture.asset(
        "assets/Icons/amity_ic_chat_deleted_user_avatar.svg",
        package: 'amity_uikit_beta_service',
      );
    } else {
      final isAvatarAvailable = avatarUrl != null && avatarUrl!.isNotEmpty;
      if (isAvatarAvailable) {
        return SizedBox(
          width: 40,
          height: 40,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              avatarUrl!,
              fit: BoxFit.cover,
              loadingBuilder: (BuildContext context, Widget child,
                  ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                } else {
                  return SvgPicture.asset(
                    avatarPlaceholder,
                    package: 'amity_uikit_beta_service',
                  );
                }
              },
              errorBuilder:
                  (BuildContext context, Object error, StackTrace? stackTrace) {
                return avatarCharacter();
              },
            ),
          ),
        );
      } else {
        return avatarCharacter();
      }
    }
  }

  Widget avatarCharacter() {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        color: theme.primaryColor.blend(ColorBlendingOption.shade2),
        shape: BoxShape.circle,
      ),
      child: Center(
          child: Text(
        displayName.isEmpty ? "" : displayName[0].toUpperCase(),
        style: AmityTextStyle.custom(20, FontWeight.w400, Colors.white),
      )),
    );
  }
}

enum ChatListType {
  CONVERSATION,
  ARCHIVED,
}
