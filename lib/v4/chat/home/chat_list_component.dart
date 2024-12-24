import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/chat/home/bloc/chat_list_bloc.dart';
import 'package:amity_uikit_beta_service/v4/chat/home/chat_list_empty_state.dart';
import 'package:amity_uikit_beta_service/v4/chat/message/chat_page.dart';
import 'package:amity_uikit_beta_service/v4/core/base_component.dart';
import 'package:amity_uikit_beta_service/v4/core/base_element.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/utils/bloc_extension.dart';
import 'package:amity_uikit_beta_service/v4/utils/date_time_extension.dart';
import 'package:amity_uikit_beta_service/v4/utils/shimmer_widget.dart';
import 'package:amity_uikit_beta_service/v4/utils/skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Fetch channel type
class ChatListComponent extends NewBaseComponent {
  ChatListComponent({super.key, super.pageId}) : super(componentId: "chat_list");

  final scrollController = ScrollController();

  @override
  Widget buildComponent(BuildContext context) {
    return BlocProvider<ChatListBloc>(
      create: (context) =>
          ChatListBloc(channelType: AmityChannelType.CONVERSATION),
      child: BlocBuilder<ChatListBloc, ChatListState>(
        builder: (context, state) {
          scrollController.addListener(() {
            if (scrollController.position.pixels ==
                scrollController.position.maxScrollExtent) {
              context.read<ChatListBloc>().addEvent(ChatListLoadNextPage());
            }
          });

          if (state.isLoading && state.channels.isEmpty) {
            return userSkeletonList();
          } else if (!state.isLoading && state.channels.isEmpty) {
            return ChatListEmptyState(theme: theme);
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
                      final channelMember = state.channelMembers[
                          channel.channelId]; // Other participant

                      return GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          final channelId = channel.channelId;
                          final userId = channelMember?.userId;
                          final displayName = channelMember?.user?.displayName;
                          final avatarUrl = channelMember?.user?.avatarUrl;

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => AmityChatPage(
                                key: Key("${channelId ?? ""}_${userId ?? ""}"),
                                channelId: channelId,
                                userId: userId ?? "",
                                userDisplayName: displayName ?? "",
                                avatarUrl: avatarUrl ?? "",
                              ),
                            ),
                          );
                        },
                        child: ChatListItem(
                            channel: channel, channelMember: channelMember),
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget userSkeletonList() {
    return Container(
      decoration: BoxDecoration(color: theme.backgroundColor),
      child: Column(children: [
        Divider(
          color: theme.baseColorShade4,
          thickness: 0.5,
          height: 0,
        ),
        Expanded(
          child: Container(
            alignment: Alignment.topCenter,
            child: Shimmer(
              linearGradient: configProvider.getShimmerGradient(),
              child: ListView(
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  skeletonItem(),
                  skeletonItem(),
                  skeletonItem(),
                  skeletonItem(),
                  skeletonItem(),
                  skeletonItem(),
                  skeletonItem(),
                  skeletonItem(),
                ],
              ),
            ),
          ),
        )
      ]),
    );
  }

  Widget skeletonItem() {
    return ShimmerLoading(
      isLoading: true,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: const Row(
          children: [
            SkeletonImage(width: 40, height: 40, borderRadius: 20),
            SizedBox(width: 12),
            SkeletonText(width: 180, height: 10),
          ],
        ),
      ),
    );
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
    String? displayName = channelMember?.user?.displayName;
    if (channelMember?.user?.isDeleted == true || displayName == null || displayName.isEmpty) {
      displayName = "Unknown User";
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          AmityChatAvatar(channelMember: channelMember),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              displayName,
              style: AmityTextStyle.titleBold(theme.baseColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            channel.lastActivity?.toChatTimestamp() ?? "",
            style: AmityTextStyle.caption(theme.baseColorShade2)
          ),
        ],
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
