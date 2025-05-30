import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/chat/full_text_message.dart';
import 'package:amity_uikit_beta_service/v4/chat/group_message/bloc/group_chat_page_bloc.dart';
import 'package:amity_uikit_beta_service/v4/chat/group_message/group_setting_page.dart';
import 'package:amity_uikit_beta_service/v4/chat/message/bloc/chat_page_bloc.dart';
import 'package:amity_uikit_beta_service/v4/chat/message/message_bubble_view.dart';
import 'package:amity_uikit_beta_service/v4/chat/message_composer/message_composer.dart';
import 'package:amity_uikit_beta_service/v4/chat/message_composer/message_composer_action.dart';
import 'package:amity_uikit_beta_service/v4/core/base_page.dart';
import 'package:amity_uikit_beta_service/v4/core/channel_avatar.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/amity_uikit_toast.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/core/ui/animation/bounce_animator.dart';
import 'package:amity_uikit_beta_service/v4/core/ui/animation/simple_ticker_provider.dart';
import 'package:amity_uikit_beta_service/v4/core/user_avatar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

part 'widgets/group_chat_page_helpers.dart';

class GroupChatPage extends NewBasePage {
  static double toastBottomPadding = 56;

  final String? channelId;
  late BounceAnimator bounceAnimator;
  late Function bounceLatestMessage;
  final bool isJustCreated;

  GroupChatPage({
    super.key,
    this.channelId,
    this.isJustCreated = false,
  }) : super(pageId: 'group_chat_page');

  @override
  Widget buildPage(BuildContext context) {
    MessageComposerCache().updateText("");

    return SimpleTickerProvider(
      onInit: (vsync) {
        bounceAnimator = BounceAnimator(vsync);
        bounceLatestMessage = () {
          bounceAnimator.animateItem(0);
        };
      },
      child: Stack(
        children: [
          BlocProvider(
            key: Key("$channelId"),
            create: (context) =>
                GroupChatPageBloc(channelId, context.read<AmityToastBloc>()),
            child: BlocBuilder<GroupChatPageBloc, GroupChatPageState>(
              key: Key("$channelId"),
              builder: (context, state) {
                if (state is GroupChatPageStateInitial && !isJustCreated) {
                  context.read<AmityToastBloc>().add(AmityToastLoading(
                      message: "Loading chat...",
                      icon: AmityToastIcon.loading,
                      bottomPadding: toastBottomPadding));
                }

                if (!state.isFetching && state is! GroupChatPageStateInitial) {
                  context.read<AmityToastBloc>().add(AmityToastDismissIfLoading());
                }

                final List<GlobalKey> itemKeys = List.generate(
                    state.messages.length, (index) => GlobalKey());

                final isScrollable = state.scrollController.hasClients &&
                    state.scrollController.position.maxScrollExtent > 0;

                final newMessage = state.newMessage;
                return Scaffold(
                  appBar: AppBar(
                    titleSpacing: -5,
                    surfaceTintColor: theme.backgroundColor,
                    title: GestureDetector(
                      onTap: () async {
                        final channel = state.channel;
                        if (channel != null) {
                          final updatedChannel = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GroupSettingPage(
                                channel: channel,
                                isModerator: state.isModerator,
                              ),
                            ),
                          );

                          if (updatedChannel is AmityChannel) {

                            context.read<GroupChatPageBloc>().add(
                                GroupChatPageHeaderEventChanged(
                                    channel: updatedChannel));
                          }
                        }
                      },
                      child: Row(
                        children: [
                          AmityChannelAvatar.withChannel(
                            channel: state.channel,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(state.channelDisplayName ?? "",
                                    style: AmityTextStyle.titleBold(
                                        theme.baseColor)),
                                Visibility(
                                  visible: !state.isConnected,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const CupertinoActivityIndicator(
                                        radius: 8,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        "Waiting for network...",
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: theme.baseColorShade1,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                      ),
                    ),
                    backgroundColor: theme.backgroundColor,
                    elevation: 0,
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(0),
                      child: Container(
                        height: 1,
                        color: theme.baseColorShade4,
                      ),
                    ),
                  ),
                  body: Container(
                    color: theme.backgroundColor,
                    child: Column(
                      children: [
                        Visibility(
                          visible:
                              state.isFetching && state.messages.isNotEmpty,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            width: 24.0,
                            height: 24.0,
                            child: const CupertinoActivityIndicator(),
                          ),
                        ),
                        Expanded(
                          child: Stack(
                            children: [
                              Visibility(
                                visible: state.isFetching &&
                                    state.messages.isNotEmpty,
                                child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  width: 24.0,
                                  height: 24.0,
                                  child: const CupertinoActivityIndicator(),
                                ),
                              ),
                              LayoutBuilder(builder: (context, constraints) {
                                final firstItem =
                                    state.messages.firstOrNull?.message;
                                if (firstItem != null) {
                                  context.read<GroupChatPageBloc>().add(
                                      GroupChatPageEventMarkReadMessage(
                                          message: firstItem));
                                }
                                return ListView.builder(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  controller: state.scrollController,
                                  reverse: state.scrollController.hasClients &&
                                      state.scrollController.position
                                              .maxScrollExtent >
                                          0,
                                  cacheExtent: 1000,
                                  itemCount: state.messages.length,
                                  itemBuilder: (context, index) {
                                    ChatItem item;
                                    if (state.scrollController.hasClients &&
                                        state.scrollController.position
                                                .maxScrollExtent >
                                            0) {
                                      item = state.messages[index];
                                    } else {
                                      final messageIndex =
                                          state.messages.length - 1 - index;
                                      item = state.messages[messageIndex];
                                    }
                                    final message = item.message;
                                    if (message != null) {
                                      if (message.data is MessageVideoData &&
                                          message.syncState !=
                                              AmityMessageSyncState.SYNCED &&
                                          !state.localThumbnails
                                              .containsKey(message.uniqueId)) {
                                        try {
                                          final filePath =
                                              (message.data as MessageVideoData)
                                                  .getVideo()
                                                  .getFilePath;
                                          if (filePath != null) {
                                            context.read<GroupChatPageBloc>().add(
                                                GroupChatPageEventFetchLocalVideoThumbnail(
                                                    uniqueId: message.uniqueId!,
                                                    videoPath: filePath));
                                          }
                                        } catch (e) {}
                                      } else if (message.data
                                              is MessageVideoData &&
                                          message.syncState ==
                                              AmityMessageSyncState.SYNCED &&
                                          !state.localThumbnails
                                              .containsKey(message.uniqueId) &&
                                          (message.data as MessageVideoData)
                                                  .thumbnailImageFile ==
                                              null) {
                                        try {
                                          final filePath =
                                              (message.data as MessageVideoData)
                                                  .getVideo()
                                                  .fileProperties
                                                  .fileUrl;
                                          if (filePath != null) {
                                            context.read<GroupChatPageBloc>().add(
                                                GroupChatPageEventFetchLocalVideoThumbnail(
                                                    uniqueId: message.uniqueId!,
                                                    videoPath: filePath));
                                          }
                                        } catch (e) {}
                                      }
                                      return ValueListenableBuilder<int?>(
                                          valueListenable:
                                              bounceAnimator.animatedIndex,
                                          builder: (context, animatedIndex, _) {
                                            return AnimatedBuilder(
                                                animation:
                                                    bounceAnimator.animation,
                                                builder: (context, _) {
                                                  final bounce =
                                                      (animatedIndex == index)
                                                          ? (1.0 +
                                                              (0.1 *
                                                                  bounceAnimator
                                                                      .animation
                                                                      .value))
                                                          : 1.0;
                                                  final isModerator = message
                                                              .user?.userId !=
                                                          null &&
                                                      state.memberRoles[message
                                                                  .user!.userId]
                                                              ?.any((role) =>
                                                                  role.contains(
                                                                      'channel-moderator')) ==
                                                          true;

                                                  return MessageBubbleView(
                                                    key: message.uniqueId !=
                                                            null
                                                        ? Key(message.uniqueId!)
                                                        : itemKeys[index],
                                                    pageId: pageId,
                                                    isGroupChat: true,
                                                    message: message,
                                                    isModerator: isModerator,
                                                    bounceAnimator:
                                                        bounceAnimator,
                                                    bounce: bounce,
                                                    onSeeMoreTap: (text,
                                                        {isReplied = false}) {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              FullTextScreen(
                                                            fullText: text,
                                                            displayName: (!isReplied)
                                                                ? message.user
                                                                        ?.displayName ??
                                                                    ""
                                                                : "Replied message",
                                                            theme: theme,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    onResend: (message) {
                                                      context
                                                          .read<
                                                              GroupChatPageBloc>()
                                                          .add(
                                                              GroupChatPageEventResendMessage(
                                                                  message:
                                                                      message));
                                                    },
                                                    onReplyMessage:
                                                        (replyingMessage) {
                                                      context
                                                          .read<
                                                              GroupChatPageBloc>()
                                                          .add(GroupChatPageReplyEvent(
                                                              message:
                                                                  replyingMessage));
                                                    },
                                                    onEditMessage: (message) {
                                                      context
                                                          .read<
                                                              GroupChatPageBloc>()
                                                          .add(
                                                              GroupChatPageEditEvent(
                                                                  message:
                                                                      message));
                                                    },
                                                    thumbnail: state
                                                            .localThumbnails[
                                                        item.message!.uniqueId],
                                                  );
                                                });
                                          });
                                    } else {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 4.0,
                                              horizontal: 8.0,
                                            ),
                                            decoration: BoxDecoration(
                                              color: theme.backgroundColor,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.1),
                                                  blurRadius: 4.0,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Text(
                                              item.date ?? "",
                                              style: TextStyle(
                                                  color: theme.baseColorShade1,
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 13),
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                );
                              }),
                              if (newMessage != null)
                                _buildNewMessageNotification(state, newMessage),
                              if (state.showScrollButton &&
                                  isScrollable &&
                                  newMessage == null)
                                _buildScrollToLatestButton(state, isScrollable)
                            ],
                          ),
                        ),
                        // Check if current user is a channel moderator or if the channel is not muted
                        _buildMessageComposer(context, state),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          AmityToast(pageId: pageId, elementId: "toast"),
        ],
      ),
    );
  }

  Widget _buildMessageComposer(BuildContext context, GroupChatPageState state) {
    // Check if the channel is available
    if (state.channel == null) return const SizedBox();

    final isMuted = state.channel!.isMuted ?? false;
    final isChannelModerator = state.isModerator;
    bool shouldShowMessageComposer;
    if (isMuted) {
      if (isChannelModerator) {
        shouldShowMessageComposer = true;
      } else {
        shouldShowMessageComposer = false;
      }
    } else {
      shouldShowMessageComposer = true;
    }

    if (shouldShowMessageComposer) {
      return AmityMessageComposer(
        key: Key('${state.channelId}'),
        pageId: pageId,
        replyingMessage: state.replyingMessage,
        editingMessage: state.editingMessage,
        subChannelId: state.channelId,
        avatarUrl: null,
        action: MessageComposerAction(
          onDissmiss: () {
            context
                .read<GroupChatPageBloc>()
                .add(const GroupChatPageRemoveReplyEvent());
          },
          onMessageCreated: () {
            context
                .read<GroupChatPageBloc>()
                .add(const GroupChatPageRemoveReplyEvent());
            state.scrollController.animateTo(
              0.0,
              curve: Curves.easeOut,
              duration: const Duration(milliseconds: 300),
            );
          },
        ),
      );
    } else {
      return Container(
        padding:
            const EdgeInsets.only(bottom: 16, top: 16, left: 16, right: 16),
        decoration: BoxDecoration(
          color: theme.backgroundShade1Color,
        ),
        child: Center(
          child: Text(
            "Members that are not moderators can read but not send any messages.",
            style: AmityTextStyle.caption(theme.baseColorShade1),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }
}
