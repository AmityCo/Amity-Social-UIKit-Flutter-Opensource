import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:amity_uikit_beta_service/v4/chat/full_text_message.dart';
import 'package:amity_uikit_beta_service/v4/chat/message/bloc/chat_page_bloc.dart';
import 'package:amity_uikit_beta_service/v4/chat/message/components/amity_conversation_chat_user_action_component.dart';
import 'package:amity_uikit_beta_service/v4/chat/message/message_bubble_view.dart';
import 'package:amity_uikit_beta_service/v4/chat/message_composer/message_composer.dart';
import 'package:amity_uikit_beta_service/v4/chat/message_composer/message_composer_action.dart';
import 'package:amity_uikit_beta_service/v4/core/base_page.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/amity_uikit_toast.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/core/ui/animation/bounce_animator.dart';
import 'package:amity_uikit_beta_service/v4/core/ui/animation/simple_ticker_provider.dart';
import 'package:amity_uikit_beta_service/v4/core/user_avatar.dart';
import 'package:amity_uikit_beta_service/v4/utils/amity_dialog.dart';
import 'package:amity_uikit_beta_service/v4/utils/amity_image_viewer.dart';
import 'package:amity_uikit_beta_service/v4/utils/shimmer_widget.dart';
import 'package:amity_uikit_beta_service/v4/utils/skeleton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

part 'widgets/chat_page_helpers.dart';

// Page for showing one-on-one chat messages
class AmityChatPage extends NewBasePage {
  static double toastBottomPadding = 56;

  final String? channelId;
  final String? userId;
  final String? userDisplayName;
  final String? avatarUrl;
  late BounceAnimator bounceAnimator;
  late Function bounceLatestMessage;

  AmityChatPage(
      {super.key,
      this.channelId,
      this.userId,
      this.userDisplayName,
      this.avatarUrl})
      : super(pageId: 'chat_page');

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
            key: Key("${channelId ?? ""}_${userId ?? ""}"),
            create: (context) => ChatPageBloc(
                channelId,
                userId,
                userDisplayName,
                avatarUrl,
                context.read<AmityToastBloc>(),
                context),
            child: BlocBuilder<ChatPageBloc, ChatPageState>(
              key: Key("${channelId ?? ""}_${userId ?? ""}"),
              builder: (context, state) {
                if (state is ChatPageStateInitial) {
                  context.read<AmityToastBloc>().add(AmityToastLoading(
                      message: context.l10n.chat_loading,
                      icon: AmityToastIcon.loading,
                      bottomPadding: toastBottomPadding));
                }

                if (!state.isFetching && state is! ChatPageStateInitial) {
                  context.read<AmityToastBloc>().add(AmityToastDismiss());
                }

                final isLoadingUserAvatar =
                    state.avatarUrl == null && state.userDisplayName == null;

                final List<GlobalKey> itemKeys = List.generate(
                    state.messages.length, (index) => GlobalKey());

                final isScrollable = state.scrollController.hasClients &&
                    state.scrollController.position.maxScrollExtent > 0;

                final newMessage = state.newMessage;
                return Scaffold(
                  appBar: AppBar(
                    titleSpacing: -5,
                    surfaceTintColor: theme.backgroundColor,
                    title: Row(
                      children: [
                        if (isLoadingUserAvatar)
                          skeletonHeader()
                        else ...[
                          GestureDetector(
                            onTap: () {
                              final avatarUrl = state.avatarUrl;
                              if (avatarUrl != null && avatarUrl.isNotEmpty) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AmityImageViewer(
                                      imageUrl: "$avatarUrl?size=large",
                                    ),
                                  ),
                                );
                              }
                            },
                            child: AmityUserAvatar.withChannelMember(
                                channelMember: state.channelMember),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  state.userDisplayName ?? "",
                                  style: TextStyle(
                                    color: theme.baseColor,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
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
                                        context.l10n.chat_waiting_for_network,
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
                        ],
                      ],
                    ),
                    actions: [
                      if (!isLoadingUserAvatar) ...[
                        IconButton(
                          icon: SvgPicture.asset(
                            'assets/Icons/amity_ic_three_dot_vertical.svg',
                            package: 'amity_uikit_beta_service',
                            width: 24,
                            height: 24,
                            colorFilter: ColorFilter.mode(
                                theme.secondaryColor, BlendMode.srcIn),
                          ),
                          onPressed: () {
                            HapticFeedback.heavyImpact();
                            _showChatUserActionBottomSheet(context, state);
                          },
                        ),
                        const SizedBox(width: 8),
                      ]
                    ],
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
                                  context.read<ChatPageBloc>().add(
                                      ChatPageEventMarkReadMessage(
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
                                            context.read<ChatPageBloc>().add(
                                                ChatPageEventFetchLocalVideoThumbnail(
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
                                            context.read<ChatPageBloc>().add(
                                                ChatPageEventFetchLocalVideoThumbnail(
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
                                                  return MessageBubbleView(
                                                    key: message.uniqueId !=
                                                            null
                                                        ? Key(message.uniqueId!)
                                                        : itemKeys[index],
                                                    pageId: pageId,
                                                    message: message,
                                                    channelMember:
                                                        state.channelMember,
                                                    isModerator: false,
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
                                                                ? state.userDisplayName ??
                                                                    ""
                                                                : "Replied message",
                                                            theme: theme,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    onResend: (message) {
                                                      context
                                                          .read<ChatPageBloc>()
                                                          .add(
                                                              ChatPageEventResendMessage(
                                                                  message:
                                                                      message));
                                                    },
                                                    onReplyMessage:
                                                        (replyingMessage) {
                                                      context
                                                          .read<ChatPageBloc>()
                                                          .add(ChatPageReplyEvent(
                                                              message:
                                                                  replyingMessage));
                                                    },
                                                    onEditMessage: (message) {
                                                      context
                                                          .read<ChatPageBloc>()
                                                          .add(
                                                              ChatPageEditEvent(
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
                                _buildNewMessageNotification(
                                    context, state, newMessage),
                              if (state.showScrollButton &&
                                  isScrollable &&
                                  newMessage == null)
                                _buildScrollToLatestButton(state, isScrollable),
                            ],
                          ),
                        ),
                        // Show blocked message if current user is blocking the other user
                        if (state.isUserBlocked)
                          SafeArea(
                            top: false,
                            child: Container(
                              height: 42,
                              padding: const EdgeInsets.only(
                                  top: 12.0,
                                  bottom: 12.0,
                                  left: 16.0,
                                  right: 16.0),
                              decoration: BoxDecoration(
                                color: theme.backgroundShade1Color,
                              ),
                              child: Center(
                                child: Text(
                                  context.l10n.chat_blocked_message,
                                  style: AmityTextStyle.caption(
                                      theme.baseColorShade1),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          )
                        else
                          AmityMessageComposer(
                            key: Key('${state.channelId}'),
                            pageId: pageId,
                            replyingMessage: state.replyingMessage,
                            editingMessage: state.editingMessage,
                            subChannelId: state.channelId,
                            avatarUrl: avatarUrl,
                            action: MessageComposerAction(
                              onDissmiss: () {
                                context
                                    .read<ChatPageBloc>()
                                    .add(const ChatPageRemoveReplyEvent());
                              },
                              onMessageCreated: () {
                                context
                                    .read<ChatPageBloc>()
                                    .add(const ChatPageRemoveReplyEvent());
                                state.scrollController.animateTo(
                                  0.0,
                                  curve: Curves.easeOut,
                                  duration: const Duration(milliseconds: 300),
                                );
                              },
                            ),
                          ),
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
}
