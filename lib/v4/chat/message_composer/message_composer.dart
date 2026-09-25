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
import 'package:amity_uikit_beta_service/v4/core/theme/amity_color_token.dart';
import 'package:amity_uikit_beta_service/v4/core/theme/amity_token_context.dart';
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
  final int mediaAttachmentLimit;
  AmityThemeColor? localTheme;
  FileType? selectedMediaType;
  ReplyingMesage? replyingMessage;
  AmityMessage? editingMessage;

  late GlobalKey composerKey;

  late MentionTextEditingController controller;
  late ScrollController scrollController;
  late FocusNode focusNode;
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
    this.mediaAttachmentLimit = 10,
  }) : super(componentId: "message_composer");

  @override
  Widget buildComponent(BuildContext context) {
    toastBloc = context.read<AmityToastBloc>();
    return _MessageComposerStateful(composer: this);
  }

  Widget buildComposerContent(BuildContext context,
      {required MentionTextEditingController controller,
      required ScrollController scrollController,
      required FocusNode focusNode,
      required GlobalKey composerKey}) {
    this.controller = controller;
    this.scrollController = scrollController;
    this.focusNode = focusNode;
    this.composerKey = composerKey;

    return BlocProvider(
      key: ValueKey("$subChannelId$avatarUrl}"),
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
          // Sync reply state from parent into BLoC
          final expectedReplyTo = replyingMessage?.message;
          if (state.replyTo != expectedReplyTo) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                context
                    .read<MessageComposerBloc>()
                    .add(MessageComposerReplyChanged(replyTo: expectedReplyTo));
              }
            });
          }

          context
              .read<MessageComposerBloc>()
              .add(MessageComposerTextChange(text: controller.text));
          return Column(
            children: [
              // The divider belongs above the whole composer block, reply panel
              // included: Android orders it divider -> reply preview -> input
              // row (AmityMessageComposer.kt), and the Figma reply-bar frame
              // draws it there. It used to be the input row's own top border,
              // which put the line *below* the reply panel (PDT-5046). The
              // colour is unchanged — it was never the problem.
              Container(
                height: 1,
                color: token(AmityColorToken.lineDividerPostDefault),
              ),
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

  /// A 32dp filled icon button: tokenised disc, tinted glyph.
  ///
  /// Android draws these with `AmityButton(variant = ICON, style = FILLED)`,
  /// which resolves `Surface/IconButton/Filled/<hierarchy>/Enabled` for the
  /// disc and `Icon/IconButton/Filled/<hierarchy>/Default` for the glyph
  /// (AmityButton.kt:290-294). Flutter's old assets drew the disc *inside* the
  /// SVG, so it stayed light-mode grey on a dark composer with no fill to
  /// re-colour. The glyphs here are Android's own, converted from its vector
  /// drawables — the path grammar is shared, so it is a container swap.
  Widget _composerIconButton({
    required String glyph,
    required Color surface,
    required Color tint,
    double size = 32,
  }) =>
      Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: surface, shape: BoxShape.circle),
        child: Center(
          child: SvgPicture.asset(
            glyph,
            package: 'amity_uikit_beta_service',
            width: size * 0.625,
            height: size * 0.625,
            colorFilter: ColorFilter.mode(tint, BlendMode.srcIn),
          ),
        ),
      );

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
          // No top border here: the divider is drawn once above the whole
          // composer block in buildComposerContent, so a reply panel sits below
          // the line rather than above it.
          decoration: BoxDecoration(
            color: token(AmityColorToken.surfacePageBackgroundDefault),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                          child: _composerIconButton(
                            glyph: (state.showMediaSection)
                                ? 'assets/Icons/amity_ic_cross_r.svg'
                                : 'assets/Icons/amity_ic_plus_r.svg',
                            surface: token(AmityColorToken
                                .surfaceIconButtonFilledSecondaryEnabled),
                            tint: token(AmityColorToken
                                .iconIconButtonFilledSecondaryDefault),
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
                          color: token(AmityColorToken.surfaceInputBoxedInputDefault),
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                                color: token(AmityColorToken
                                    .surfacePageBackgroundDefault)),
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: MediaQuery.removePadding(
                          context: context,
                          removeTop: true,
                          removeBottom: true,
                          // No colors-v2 token backs the Figma "Scroll Bar"
                          // layer, so each framework picks the thumb colour
                          // itself, and both pick a light-mode one over the
                          // dark compose box (PDT-5100 case 1). Material reads
                          // the light ThemeData the UIKit hands MaterialApp;
                          // `Scrollbar` on iOS is a CupertinoScrollbar, which
                          // resolves its thumb against the *system* brightness
                          // and ignores ScrollbarThemeData altogether. Raw is
                          // the only one of the three that takes a colour, so
                          // it is the only fix that holds on both platforms;
                          // Metrics are the design's, read off the Figma
                          // "Scroll Bar" layer (10848:54585): 4 wide, radius
                          // 10, right edge 4 from the boxed input's border,
                          // track running the input's vertical content band —
                          // which is the same 14 as the contentPadding below.
                          // The margins are not decoration: the input's border
                          // radius is 24, so a bar sitting closer than ~11 to
                          // the border rides over the corner arc, which is
                          // what Raw's own 0/0 margins did. Colour is the
                          // compose box's placeholder grey, the same value in
                          // both modes, and identical to the layer's own fill
                          // (rgb(137,142,158)) — decision recorded in the
                          // cleverden spec
                          // (UIKIT/components/AmityMessageComposer/v2.md).
                          child: RawScrollbar(
                              thumbColor: token(AmityColorToken
                                  .textInputTextInputPlaceholderEnabled),
                              thickness: 4,
                              radius: const Radius.circular(10),
                              mainAxisMargin: 14,
                              crossAxisMargin: 4,
                              minThumbLength: 36,
                              controller: scrollController,
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  focusNode.requestFocus();
                                },
                                child: MentionTextField(
                                  theme: theme,
                                  // The iOS keyboard is system chrome: without
                                  // this it stays light over the dark composer.
                                  keyboardAppearance: context.amityBrightness,
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
                                    final RenderBox? composerBox = composerKey
                                        .currentContext
                                        ?.findRenderObject() as RenderBox?;
                                    if (composerBox != null) {
                                      final localPos = composerBox
                                          .globalToLocal(event.position);
                                      final isInsideComposer = localPos.dx >= 0 &&
                                          localPos.dx <= composerBox.size.width &&
                                          localPos.dy >= 0 &&
                                          localPos.dy <= composerBox.size.height;
                                      if (isInsideComposer) {
                                        return; // Tap is on send button or composer area, keep focus
                                      }
                                    }
                                    if (!controller.isMentioning()) {
                                      MessageComposerCache().shouldFocus = false;
                                      FocusScope.of(context).unfocus();
                                    }
                                  },
                                  cursorColor: token(AmityColorToken
                                      .textInputTextInputTextCursorDefault),
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
                                    color: token(AmityColorToken
                                        .textInputTextInputPlaceholderEnabledFilled),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: -0.24,
                                  ),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 14),
                                    hintText: context.l10n.message_placeholder,
                                    border: InputBorder.none,
                                    prefixIconColor:
                                        token(AmityColorToken.iconInputTextInputDefault),
                                    suffixIconColor:
                                        token(AmityColorToken.iconInputTextInputDefault),
                                    hoverColor:
                                        token(AmityColorToken.iconInputTextInputDefault),
                                    hintStyle: TextStyle(
                                      color: token(AmityColorToken
                                          .textInputTextInputPlaceholderEnabled),
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
                                // FocusNode persists across rebuilds, so just keep focus
                                focusNode.requestFocus();
                              }
                            },
                            child: Container(
                              padding:
                                  const EdgeInsets.only(bottom: 6, left: 12),
                              // `isSendable` reads inverted upstream — it is true
                              // when there is nothing to send. Naming it here
                              // rather than renaming the field, which the tap
                              // handler above also reads.
                              //
                              // Nothing to send switches the whole *hierarchy*
                              // to Secondary, not just the state to Disabled:
                              // `hierarchy = if (enabled) PRIMARY else SECONDARY`
                              // (AmityMessageComposer.kt:373). Primary/Disabled
                              // is a dim blue; Android draws a grey disc.
                              child: _composerIconButton(
                                glyph: 'assets/Icons/amity_ic_arrow_up_r.svg',
                                surface: token(isSendable
                                    ? AmityColorToken
                                        .surfaceIconButtonFilledSecondaryDisabled
                                    : AmityColorToken
                                        .surfaceIconButtonFilledPrimaryEnabled),
                                tint: token(isSendable
                                    ? AmityColorToken
                                        .iconIconButtonFilledSecondaryDisabled
                                    : AmityColorToken
                                        .iconIconButtonFilledPrimaryDefault),
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

  Widget renderSendButton({required bool disabled}) {
    return SizedBox(
      width: 32,
      height: 32,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // The arrow is knocked out of the disc asset, so the glyph colour has
          // to be painted behind it and show through the cut-out.
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: token(disabled
                  ? AmityColorToken.iconIconButtonFilledSecondaryDisabled
                  : AmityColorToken.iconIconButtonFilledPrimaryDefault),
            ),
          ),
          SvgPicture.asset(
            "assets/Icons/amity_ic_sent_message_button.svg",
            colorFilter: ColorFilter.mode(
              token(disabled
                  ? AmityColorToken.surfaceIconButtonFilledSecondaryDisabled
                  : AmityColorToken.surfaceIconButtonFilledPrimaryEnabled),
              BlendMode.srcIn,
            ),
            package: 'amity_uikit_beta_service',
          ),
        ],
      ),
    );
  }

  Widget renderEditPanel(
      BuildContext context, AmityMessage? message, MessageComposerState state) {
    return Container(
      width: double.infinity,
      height: 58,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
          color: token(AmityColorToken.surfaceBannerSubdueGeneral)),
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
                        style: AmityTextStyle.captionBold(
                            token(AmityColorToken.textBannerSubdueOverlineGeneral)),
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
            width: 16,
          ),
          GestureDetector(
            onTap: () {
              controller.clear();
              action.onDissmiss();
            },
            child: SizedBox(
              width: 16,
              height: 16,
              child: SvgPicture.asset(
                "assets/Icons/amity_ic_gray_close.svg",
                colorFilter: ColorFilter.mode(
                  token(AmityColorToken.iconIconButtonGhostSecondaryDefault),
                  BlendMode.srcIn,
                ),
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
            width: 32,
            height: 32,
            fit: BoxFit.cover,
          ),
          if (message.data is MessageVideoData) ...[
            Container(
              width: 32,
              height: 32,
              color: Colors.black.withAlpha((0.4 * 255).toInt()),
            ),
            SizedBox(
              width: 16,
              height: 16,
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
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: token(AmityColorToken.surfaceBannerSubdueGeneral)),
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
                          style: AmityTextStyle.captionBold(
                            token(AmityColorToken.textBannerSubdueOverlineGeneral)),
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
                                AmityTextStyle.caption(token(AmityColorToken
                                    .textBannerSubdueTextDescriptionGeneral)),
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
                                AmityTextStyle.caption(token(AmityColorToken
                                    .textBannerSubdueTextDescriptionGeneral)),
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
                          style: AmityTextStyle.caption(token(AmityColorToken
                                    .textBannerSubdueTextDescriptionGeneral)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  if (message.data is MessageVideoData)
                    Text(
                      context.l10n.general_video,
                      style: AmityTextStyle.caption(token(AmityColorToken
                                    .textBannerSubdueTextDescriptionGeneral)),
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
              width: 16,
            ),
            GestureDetector(
              onTap: () {
                action.onDissmiss();
              },
              child: SizedBox(
                width: 16,
                height: 16,
                child: SvgPicture.asset(
                  "assets/Icons/amity_ic_gray_close.svg",
                  colorFilter: ColorFilter.mode(
                    token(AmityColorToken.iconIconButtonGhostSecondaryDefault),
                    BlendMode.srcIn,
                  ),
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
          color: token(AmityColorToken.surfaceSheetsBackgroundGeneral)),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          renderMediaButton(
            "assets/Icons/amity_ic_camera_r.svg",
            context.l10n.general_camera,
            () {
              onCameraTap(context);
            },
          ),
          const SizedBox(
            width: 56,
          ),
          renderMediaButton(
            "assets/Icons/amity_ic_image_r.svg",
            context.l10n.message_media,
            () {
              pickMultipleFiles(context, appName, FileType.any, maxFiles: mediaAttachmentLimit);
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
          // Same AmityButton(ICON/FILLED/SECONDARY) grammar as the composer's
          // own +/x, at SIZE40 (AmityMessageComposer.kt:489-496) — so the disc
          // is a token and only the glyph lives in the asset. The old
          // amity_ic_*_button.svg files baked the disc in, which is why these
          // two stayed light-grey on a dark sheet and their glyphs never
          // flipped: both modes measured #292B32 on device.
          _composerIconButton(
            glyph: assetPath,
            size: 40,
            surface:
                token(AmityColorToken.surfaceIconButtonFilledSecondaryEnabled),
            tint: token(AmityColorToken.iconIconButtonFilledSecondaryDefault),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: token(AmityColorToken.textIconButtonLabelGeneral),
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

class _MessageComposerStateful extends StatefulWidget {
  final AmityMessageComposer composer;

  const _MessageComposerStateful({required this.composer});

  @override
  State<_MessageComposerStateful> createState() =>
      _MessageComposerStatefulState();
}

class _MessageComposerStatefulState extends State<_MessageComposerStateful> {
  late MentionTextEditingController controller;
  late ScrollController scrollController;
  late FocusNode focusNode;
  final GlobalKey composerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    controller = MentionTextEditingController();
    scrollController = ScrollController();
    focusNode = FocusNode();

    // Restore cached text if available
    if (widget.composer.editingMessage != null) {
      _populateEditingMessage(widget.composer.editingMessage!);
      _requestFocusAfterBuild();
    } else if (MessageComposerCache().savedText.isNotEmpty) {
      controller.text = MessageComposerCache().savedText;
    }

    if (widget.composer.replyingMessage != null) {
      _requestFocusAfterBuild();
    }

    if (MessageComposerCache().shouldFocus) {
      _requestFocusAfterBuild();
    }
  }

  @override
  void didUpdateWidget(covariant _MessageComposerStateful oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldEditing = oldWidget.composer.editingMessage;
    final newEditing = widget.composer.editingMessage;

    // Entering edit mode
    if (oldEditing == null && newEditing != null) {
      _populateEditingMessage(newEditing);
      _requestFocusAfterBuild();
    }
    // Leaving edit mode
    if (oldEditing != null && newEditing == null) {
      controller.clear();
    }

    // Entering reply mode
    final oldReply = oldWidget.composer.replyingMessage;
    final newReply = widget.composer.replyingMessage;
    if (oldReply == null && newReply != null) {
      _requestFocusAfterBuild();
    }
  }

  void _populateEditingMessage(AmityMessage editingMessage) {
    final currentText = (editingMessage.data as MessageTextData).text ?? "";
    try {
      if (editingMessage.metadata != null &&
          editingMessage.metadata!.containsKey('mentioned')) {
        final mentionsData =
            editingMessage.metadata!['mentioned'] as List<dynamic>;

        List<AmityUserMentionMetadata> mentionMetadataList = [];
        for (var mention in mentionsData) {
          if (mention is Map<String, dynamic>) {
            try {
              final userId = mention['userId'] as String;
              final index = mention['index'] as int;
              final length = mention['length'] as int;

              mentionMetadataList.add(AmityUserMentionMetadata(
                userId: userId,
                index: index,
                length: length,
              ));
            } catch (e) {}
          }
        }

        if (mentionMetadataList.isNotEmpty) {
          controller.populate(currentText, mentionMetadataList);
        } else {
          controller.text = currentText;
        }
      } else {
        controller.text = currentText;
      }
    } catch (e) {
      controller.text = currentText;
    }
  }

  void _requestFocusAfterBuild() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.composer.buildComposerContent(
      context,
      controller: controller,
      scrollController: scrollController,
      focusNode: focusNode,
      composerKey: composerKey,
    );
  }
}

class MessageComposerCache {
  MessageComposerCache._privateConstructor();
  static final MessageComposerCache _instance =
      MessageComposerCache._privateConstructor();
  factory MessageComposerCache() => _instance;

  String savedText = "";
  bool shouldFocus = false;

  void updateText(String text) {
    savedText = text;
  }

  void requestFocus() {
    shouldFocus = true;
  }
}
