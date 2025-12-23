import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:amity_uikit_beta_service/v4/chat/full_text_message.dart';
import 'package:amity_uikit_beta_service/v4/chat/message/message_bubble_view.dart';
import 'package:amity_uikit_beta_service/v4/chat/message/replying_message.dart';
import 'package:amity_uikit_beta_service/v4/chat/message_composer/bloc/message_composer_bloc.dart';
import 'package:amity_uikit_beta_service/v4/chat/message_composer/message_composer_action.dart';
import 'package:amity_uikit_beta_service/v4/chat/message_composer/message_composer_file_picker.dart';
import 'package:amity_uikit_beta_service/v4/chat/message_composer/message_composer_with_camera.dart';
import 'package:amity_uikit_beta_service/v4/core/base_component.dart';
import 'package:amity_uikit_beta_service/v4/core/single_video_player/pager/video_message_player.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/core/ui/mention/mention_field.dart';
import 'package:amity_uikit_beta_service/v4/core/ui/mention/mention_text_editing_controller.dart';
import 'package:amity_uikit_beta_service/v4/social/post_composer_page/post_composer_model.dart';
import 'package:amity_uikit_beta_service/v4/utils/amity_image_viewer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';

class AmityMessageComposer extends NewBaseComponent {
  final String subChannelId;
  final String? avatarUrl;
  final MessageComposerAction action;
  final bool enableMention;
  AmityThemeColor? localTheme;
  FileType? selectedMediaType;
  ReplyingMesage? replyingMessage;
  AmityMessage? editingMessage;

  final GlobalKey composerKey = GlobalKey();

  MentionTextEditingController controller = MentionTextEditingController();
  ScrollController scrollController = ScrollController();
  final focusNode = FocusNode();
  ImagePicker imagePicker = ImagePicker();
  Map<String, AmityFileInfoWithUploadStatus> selectedFiles = {};
  late AmityToastBloc toastBloc;

  AmityMessageComposer({
    super.key,
    super.pageId,
    required this.subChannelId,
    required this.avatarUrl,
    this.replyingMessage,
    this.editingMessage,
    required this.action,
    this.localTheme,
    this.enableMention = true,
  }) : super(componentId: "message_composer");

  @override
  Widget buildComponent(BuildContext context) {
    toastBloc = context.read<AmityToastBloc>();
    if (replyingMessage != null) {
      // focusNode.requestFocus();
    }
    if (editingMessage != null) {
      final currentText = (editingMessage?.data as MessageTextData).text ?? "";
      // Check for mentions in the editing message
      try {
        if (editingMessage!.metadata != null &&
            editingMessage!.metadata!.containsKey('mentioned')) {
          // Get mention metadata from message metadata
          final mentionsData =
              editingMessage!.metadata!['mentioned'] as List<dynamic>;
          
          List<AmityUserMentionMetadata> mentionMetadataList = [];
          for (var mention in mentionsData) {
            if (mention is Map<String, dynamic>) {
              try {
                // Extract mention data properly
                final userId = mention['userId'] as String;
                final index = mention['index'] as int;
                final length = mention['length'] as int;
                                
                mentionMetadataList.add(AmityUserMentionMetadata(
                  userId: userId,
                  index: index,
                  length: length,
                ));
              } catch (e) {
              }
            }
          }

          if (mentionMetadataList.isNotEmpty) {
            // Populate the controller with text and mentions
            controller.populate(currentText, mentionMetadataList);
          } else {
            // No valid mentions found
            controller.text = currentText;
          }
        } else {
          // No mentions, just set the text
          controller.text = currentText;
        }
      } catch (e) {
        // Fallback in case of any errors
        controller.text = currentText;
      }
      // focusNode.requestFocus();
    } else {
      if (MessageComposerCache().savedText != "") {
        controller.text = MessageComposerCache().savedText;
        // focusNode.requestFocus();
      }
    }

    return BlocProvider(
      key: ValueKey(
          "$subChannelId$avatarUrl${replyingMessage?.message.messageId ?? ""}}"),
      create: (context) => MessageComposerBloc(
        subChannelId: subChannelId,
        controller: controller,
        scrollController: scrollController,
        replyTo: replyingMessage?.message,
        editingMessage: editingMessage,
        toastBloc: toastBloc,
      ),
      child: BlocBuilder<MessageComposerBloc, MessageComposerState>(
        builder: (context, state) {
          context
              .read<MessageComposerBloc>()
              .add(MessageComposerTextChange(text: controller.text));
          return Column(
            children: [
              if (editingMessage != null)
                renderEditPanel(context, editingMessage, state),
              if (state.replyTo != null)
                renderReplyPanel(state.replyTo!, context),
              SafeArea(
                top: false,
                child: renderComposer(context, state, subChannelId),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget renderComposer(
      BuildContext context, MessageComposerState state, String subChannelId) {
    bool isSendable = false;

    if (state.text.trim().isEmpty) {
      isSendable = true;
    } else {
      if (editingMessage != null) {
        final currentText = (editingMessage!.data as MessageTextData).text;
        if (state.text.trim() == currentText) {
          isSendable = true;
        }
      } else {
        isSendable = false;
      }
    }
    return Column(
      children: [
        Container(
          key: composerKey,
          decoration: BoxDecoration(
            color: theme.backgroundColor,
            border: Border(
              top: BorderSide(width: 1, color: theme.baseColorShade4),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (editingMessage == null)
                      Container(
                        padding: const EdgeInsets.only(bottom: 6, right: 12),
                        child: GestureDetector(
                          onTap: () {
                            if (state.showMediaSection) {
                              focusNode.requestFocus();
                              context
                                  .read<MessageComposerBloc>()
                                  .add(MessageComposerMediaCollapsed());
                            } else {
                              focusNode.unfocus();
                              context
                                  .read<MessageComposerBloc>()
                                  .add(MessageComposerMediaExpanded());
                            }
                          },
                          child: SizedBox(
                            width: 32,
                            height: 32,
                            child: SvgPicture.asset(
                              (state.showMediaSection)
                                  ? "assets/Icons/amity_ic_close_message_media_section.svg"
                                  : "assets/Icons/amity_ic_open_message_media_section.svg",
                              package: 'amity_uikit_beta_service',
                            ),
                          ),
                        ),
                      ),
                    Expanded(
                      child: Container(
                        constraints:
                            const BoxConstraints(minHeight: 45, maxHeight: 120),
                        // alignment: Alignment.centerLeft,
                        // padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: ShapeDecoration(
                          color: theme.baseColorShade4,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: theme.backgroundColor),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: MediaQuery.removePadding(
                          context: context,
                          removeTop: true,
                          removeBottom: true,
                          child: Scrollbar(
                            controller: scrollController,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                focusNode.requestFocus();
                              },
                              child: MentionTextField(
                                theme: theme,
                                controller: controller,
                                scrollController: scrollController,
                                focusNode: focusNode,
                                channelId: subChannelId,
                                enableMention: enableMention,
                                suggestionOverlayBottomPaddingWhenKeyboardOpen:
                                    80.0,
                                suggestionOverlayBottomPaddingWhenKeyboardClosed:
                                    80.0,
                                onTap: () {
                                  context
                                      .read<MessageComposerBloc>()
                                      .add(MessageComposerMediaCollapsed());
                                },
                                onTapOutside: (event) {
                                  if (!controller.isMentioning()) {
                                    FocusScope.of(context).unfocus();
                                  }
                                },
                                cursorColor: theme.primaryColor,
                                onChanged: (value) {
                                  context.read<MessageComposerBloc>().add(
                                      MessageComposerTextChange(text: value));
                                  FocusScope.of(context)
                                      .requestFocus(focusNode);
                                  context
                                      .read<MessageComposerBloc>()
                                      .add(MessageComposerMediaCollapsed());
                                },
                                keyboardType: TextInputType.multiline,
                                maxLines: null,
                                minLines: 1,
                                textAlignVertical: TextAlignVertical.bottom,
                                suggestionMaxRow: 2,
                                suggestionDisplayMode:
                                    SuggestionDisplayMode.bottom,
                                mentionContentType: MentionContentType.general,
                                style: TextStyle(
                                  color: theme.baseColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: -0.24,
                                ),
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                  hintText: context.l10n.message_placeholder,
                                  border: InputBorder.none,
                                  prefixIconColor: theme.primaryColor,
                                  suffixIconColor: theme.primaryColor,
                                  hoverColor: theme.primaryColor,
                                  hintStyle: TextStyle(
                                    color: theme.baseColorShade2,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: -0.24,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (!state.showMediaSection)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (!isSendable) {
                                if (editingMessage != null) {
                                  context
                                      .read<MessageComposerBloc>()
                                      .add(MessageComposerUpdateTextMessage(
                                        text: controller.text,
                                        messageId: editingMessage!.messageId!,
                                        mentionUserIds:
                                            controller.getMentionUserIds(),
                                        mentionMetadataList: controller
                                            .getAmityMentionMetadata(),
                                      ));
                                  action.onMessageCreated();
                                } else {
                                  context
                                      .read<MessageComposerBloc>()
                                      .add(MessageComposerCreateTextMessage(
                                        text: controller.text,
                                        parentId:
                                            replyingMessage?.message.messageId,
                                        mentionUserIds:
                                            controller.getMentionUserIds(),
                                        mentionMetadataList: controller
                                            .getAmityMentionMetadata(),
                                      ));
                                  action.onMessageCreated();
                                }

                                controller.clear();
                              }
                            },
                            child: Container(
                              padding:
                                  const EdgeInsets.only(bottom: 6, left: 12),
                              child: SizedBox(
                                width: 32,
                                height: 32,
                                child: (isSendable)
                                    ? SvgPicture.asset(
                                        "assets/Icons/amity_ic_sent_message_button_disable.svg",
                                        package: 'amity_uikit_beta_service',
                                      )
                                    : SvgPicture.asset(
                                        "assets/Icons/amity_ic_sent_message_button.svg",
                                        colorFilter: ColorFilter.mode(
                                          theme.primaryColor,
                                          BlendMode.srcIn,
                                        ),
                                        package: 'amity_uikit_beta_service',
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        (state.showMediaSection)
            ? renderMediaSection(context, state.appName)
            : const SizedBox(),
      ],
    );
  }

  Widget renderEditPanel(
      BuildContext context, AmityMessage? message, MessageComposerState state) {
    return Container(
      width: double.infinity,
      height: 48,
      padding: const EdgeInsets.only(top: 10, left: 16, right: 12, bottom: 10),
      decoration: BoxDecoration(color: theme.baseColorShade4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: context.l10n.message_editing_message,
                        style: AmityTextStyle.captionBold(theme.baseColor),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 12,
          ),
          GestureDetector(
            onTap: () {
              controller.clear();
              action.onDissmiss();
            },
            child: SizedBox(
              width: 20,
              height: 20,
              child: SvgPicture.asset(
                "assets/Icons/amity_ic_gray_close.svg",
                package: 'amity_uikit_beta_service',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget renderReplyPanel(AmityMessage message, BuildContext context) {
    final userDisplayName = message.user?.userId == AmityCoreClient.getUserId()
        ? context.l10n.message_replying_yourself
        : message.user?.displayName ?? "";

    Stack? imagePreview;

    if (replyingMessage?.previewImage != null) {
      imagePreview = Stack(
        alignment: Alignment.center,
        children: [
          Image(
            image: replyingMessage!.previewImage!.image,
            width: 38,
            height: 38,
            fit: BoxFit.cover,
          ),
          if (message.data is MessageVideoData) ...[
            Container(
              width: 38,
              height: 38,
              color: Colors.black.withAlpha((0.4 * 255).toInt()),
            ),
            SizedBox(
              width: 14,
              height: 14,
              child: SvgPicture.asset(
                'assets/Icons/amity_ic_video_reply_play.svg',
                package: 'amity_uikit_beta_service',
              ),
            ),
          ]
        ],
      );
    }
    return GestureDetector(
      onTap: () {
        // TODO Remove this condition when jump to replied message is implemented
        if (message.data is MessageTextData) {
          final parentTextMessage =
              (message.data as MessageTextData).text ?? "";
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FullTextScreen(
                fullText: parentTextMessage,
                displayName: context.l10n.message_replied_message,
                theme: theme,
              ),
            ),
          );
        } else if (message.data is MessageImageData) {
          final image = (message.data as MessageImageData).image;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AmityImageViewer(
                imageUrl: image?.getUrl(AmityImageSize.LARGE) ?? "",
                showDeleteButton: message.userId == AmityCoreClient.getUserId(),
                showSaveButton: true,
                onSave: () async {
                  await saveImageMessage(context, message);
                },
              ),
            ),
          );
        } else if (message.data is MessageVideoData) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoMessagePlayer(
                message: message,
                onDelete: () {},
              ),
            ),
          );
        }
      },
      child: Container(
        width: double.infinity,
        height: 62,
        padding:
            const EdgeInsets.only(top: 10, left: 16, right: 12, bottom: 10),
        decoration: BoxDecoration(color: theme.baseColorShade4),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text:
                              context.l10n.message_replying_to(userDisplayName),
                          style: AmityTextStyle.captionBold(theme.baseColor),
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (message.data is MessageTextData)
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: (message.data as MessageTextData).text,
                            style:
                                AmityTextStyle.caption(theme.baseColorShade1),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (message.data is MessageCustomData)
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: (message.data as MessageCustomData)
                                    .rawData
                                    ?.toString() ??
                                "",
                            style:
                                AmityTextStyle.caption(theme.baseColorShade1),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (message.data is MessageImageData)
                    Row(
                      children: [
                        Text(
                          context.l10n.general_photo,
                          style: AmityTextStyle.caption(theme.baseColorShade1),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  if (message.data is MessageVideoData)
                    Text(
                      context.l10n.general_video,
                      style: AmityTextStyle.caption(theme.baseColorShade1),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            if (message.data is MessageVideoData ||
                message.data is MessageImageData) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: imagePreview,
              ),
              const SizedBox(width: 8),
            ],
            const SizedBox(
              width: 12,
            ),
            GestureDetector(
              onTap: () {
                action.onDissmiss();
              },
              child: SizedBox(
                width: 20,
                height: 20,
                child: SvgPicture.asset(
                  "assets/Icons/amity_ic_gray_close.svg",
                  package: 'amity_uikit_beta_service',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget renderMediaSection(BuildContext context, String appName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: theme.backgroundColor),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          renderMediaButton(
            "assets/Icons/amity_ic_camera_button.svg",
            context.l10n.general_camera,
            () {
              onCameraTap(context);
            },
          ),
          const SizedBox(
            width: 72,
          ),
          renderMediaButton(
            "assets/Icons/amity_ic_image_button.svg",
            context.l10n.message_media,
            () {
              pickMultipleFiles(context, appName, FileType.any);
            },
          ),
        ],
      ),
    );
  }

  Widget renderMediaButton(String assetPath, String label, Function() onClick) {
    return GestureDetector(
      onTap: () {
        onClick();
      },
      child: Column(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: SvgPicture.asset(
              assetPath,
              package: 'amity_uikit_beta_service',
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.baseColorShade1,
              fontSize: 13,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.10,
            ),
          )
        ],
      ),
    );
  }
}

class MessageComposerCache {
  MessageComposerCache._privateConstructor();
  static final MessageComposerCache _instance =
      MessageComposerCache._privateConstructor();
  factory MessageComposerCache() => _instance;

  String savedText = "";

  void updateText(String text) {
    savedText = text;
  }
}
