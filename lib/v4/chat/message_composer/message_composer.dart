import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/chat/message_composer/bloc/message_composer_bloc.dart';
import 'package:amity_uikit_beta_service/v4/chat/message_composer/message_composer_action.dart';
import 'package:amity_uikit_beta_service/v4/chat/message_composer/message_composer_file_picker.dart';
import 'package:amity_uikit_beta_service/v4/chat/message_composer/message_composer_with_camera.dart';
import 'package:amity_uikit_beta_service/v4/core/base_component.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/post_composer_page/post_composer_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';

class AmityMessageComposer extends NewBaseComponent {
  final String subChannelId;
  final AmityMessage? replyTo;
  final String? avatarUrl;
  final MessageComposerAction action;
  AmityThemeColor? localTheme;
  FileType? selectedMediaType = null;

  TextEditingController controller = TextEditingController();
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
    this.replyTo,
    required this.action,
    this.localTheme,
  }) : super(componentId: "message_composer");

  @override
  Widget buildComponent(BuildContext context) {
    toastBloc = context.read<AmityToastBloc>();
    return BlocProvider(
      key: ValueKey("$subChannelId$avatarUrl${replyTo?.messageId ?? ""}"),
      create: (context) => MessageComposerBloc(
        subChannelId: subChannelId,
        controller: controller,
        scrollController: scrollController,
        replyTo: replyTo,
        toastBloc: toastBloc,
      ),
      child: BlocBuilder<MessageComposerBloc, MessageComposerState>(
        builder: (context, state) {
          return Column(
            children: [
              if (state.replyTo != null) renderReplyPanel(state.replyTo!),
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
    String? avatarUrl = AmityCoreClient.getCurrentUser().avatarUrl;
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(width: 1, color: Color(0xFFEBECEE)),
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
                              child: TextField(
                                controller: controller,
                                scrollController: scrollController,
                                focusNode: focusNode,
                                onTapOutside: (e) =>
                                    FocusScope.of(context).unfocus(),
                                onTap: () => context
                                    .read<MessageComposerBloc>()
                                    .add(MessageComposerMediaCollapsed()),
                                onChanged: (value) {
                                  context.read<MessageComposerBloc>().add(
                                      MessageComposerTextChage(text: value));
                                },
                                keyboardType: TextInputType.multiline,
                                maxLines: null,
                                minLines: 1,
                                textAlignVertical: TextAlignVertical.bottom,
                                cursorColor: theme.primaryColor,
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
                                  hintText: 'Write a message',
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
                              if (state.text.trim().isNotEmpty) {
                                context
                                    .read<MessageComposerBloc>()
                                    .add(MessageComposerCreateTextMessage(
                                      text: controller.text,
                                    ));
                                action.onMessageCreated();

                                controller.clear();
                              }
                            },
                            child: Container(
                              padding:
                                  const EdgeInsets.only(bottom: 6, left: 12),
                              child: SizedBox(
                                width: 32,
                                height: 32,
                                child: (state.text.trim().isEmpty)
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

  Widget renderReplyPanel(AmityMessage message) {
    final MessageComposer = message.user?.displayName ?? "";
    return Container(
      width: double.infinity,
      height: 40,
      padding: const EdgeInsets.only(top: 10, left: 16, right: 12, bottom: 10),
      decoration: BoxDecoration(color: theme.baseColorShade4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SizedBox(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Replying to ',
                      style: TextStyle(
                        color: theme.baseColorShade1,
                        fontSize: 15,
                        fontFamily: 'SF Pro Text',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    TextSpan(
                      text: MessageComposer,
                      style: TextStyle(
                        color: theme.baseColorShade1,
                        fontSize: 15,
                        fontFamily: 'SF Pro Text',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
            "Camera",
            () {
              onCameraTap(context);
            },
          ),
          const SizedBox(
            width: 72,
          ),
          renderMediaButton(
            "assets/Icons/amity_ic_image_button.svg",
            "Media",
            () {
              pickMultipleFiles(context, appName, FileType.video);
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
