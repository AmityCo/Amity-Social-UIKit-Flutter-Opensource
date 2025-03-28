import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:amity_uikit_beta_service/v4/core/base_element.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/core/ui/mention/mention_field.dart';
import 'package:amity_uikit_beta_service/v4/social/comment/comment_creator/bloc/comment_creator_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/comment/comment_creator/comment_creator_action.dart';
import 'package:amity_uikit_beta_service/v4/utils/user_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/ui/mention/mention_text_editing_controller.dart';

class AmityCommentCreator extends BaseElement {
  final String referenceId;
  final AmityCommentReferenceType referenceType;
  final AmityComment? replyTo;
  final CommentCreatorAction action;
  final String? communityId;
  AmityThemeColor? localTheme;
  AmityCommentCreator({
    Key? key,
    required this.referenceId,
    this.replyTo,
    required this.action,
    this.localTheme,
    required this.referenceType,
    this.communityId,
    elementId = "comment_creator",
  }) : super(key: key, elementId: elementId);

  @override
  Widget buildElement(BuildContext context) {
    return AmityCommentCreatorInternal(
      referenceId: referenceId,
      referenceType: referenceType,
      replyTo: replyTo,
      communityId: communityId,
      action: action,
      theme: localTheme ?? theme,
    );
  }
}

class AmityCommentCreatorInternal extends StatefulWidget {
  final String referenceId;
  final AmityCommentReferenceType referenceType;
  final AmityComment? replyTo;
  final CommentCreatorAction action;
  final AmityThemeColor theme;
  final String? communityId;

  const AmityCommentCreatorInternal({
    Key? key,
    required this.referenceId,
    required this.referenceType,
    this.replyTo,
    this.communityId,
    required this.action,
    required this.theme,
  }) : super(key: key);

  @override
  _AmityCommentCreatorInternalState createState() =>
      _AmityCommentCreatorInternalState();
}

class _AmityCommentCreatorInternalState
    extends State<AmityCommentCreatorInternal> {
  late MentionTextEditingController controller;
  late ScrollController scrollController;
  final focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    controller = MentionTextEditingController();
    scrollController = ScrollController();
  }

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return BlocProvider(
      key: ValueKey(widget.replyTo?.commentId ?? ""),
      create: (context) => CommentCreatorBloc(replyTo: widget.replyTo),
      child: BlocBuilder<CommentCreatorBloc, CommentCreatorState>(
        builder: (context, state) {
          return Column(
            children: [
              if (state.replyTo != null) renderReplyPanel(state.replyTo!),
              SafeArea(
                top: false,
                child: renderComposer(
                    context, state, widget.referenceId, widget.referenceType, widget.communityId),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget renderComposer(BuildContext context,
      CommentCreatorState state,
      String referenceId,
      AmityCommentReferenceType referenceType,
      String? communityId) {
    AmityUser user = AmityCoreClient.getCurrentUser();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.only(
                top: 0, left: 12, right: 8, bottom: 8),
            child: SizedBox(
              width: 32,
              height: 32,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AmityUserImage(
                  user: user,
                  theme: widget.theme,
                  size: 32,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 135),
              height: state.currentHeight,
              alignment: Alignment.centerLeft,
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              decoration: ShapeDecoration(
                color: widget.theme.baseColorShade4,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: widget.theme.backgroundColor),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                removeBottom: true,
                child: Scrollbar(
                  controller: scrollController,
                  child: MentionTextField(
                    theme: widget.theme,
                    suggestionMaxRow: 2,
                    suggestionDisplayMode: SuggestionDisplayMode.bottom,
                    mentionContentType: MentionContentType.comment,
                    communityId: communityId,
                    controller: controller,
                    scrollController: scrollController,
                    onChanged: (value) {
                      context
                          .read<CommentCreatorBloc>()
                          .add(CommentCreatorTextChage(text: value.trim()));
                    },
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    minLines: 1,
                    textAlignVertical: TextAlignVertical.bottom,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 0),
                      hintText: context.l10n.comment_create_hint,
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: widget.theme.baseColorShade2,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    suggestionOverlayBottomPaddingWhenKeyboardClosed: state.currentHeight + 16.0 + (state.replyTo != null ? 40.0 : 0.0),
                    suggestionOverlayBottomPaddingWhenKeyboardOpen:  state.currentHeight + 16.0 + (state.replyTo != null ? 40.0 : 0.0),
                  ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                context.read<CommentCreatorBloc>().add(CommentCreatorCreated(
                  referenceId: referenceId,
                  referenceType: referenceType,
                  text: controller.text,
                  mentionMetadataList: controller.getAmityMentionMetadata(),
                  mentionUserIds: controller.getMentionUserIds(),
                  toastBloc: context.read<AmityToastBloc>(),
                ));
                controller.clear();
              },
              child: Container(
                padding:
                const EdgeInsets.only(bottom: 12, right: 12, left: 8),
                clipBehavior: Clip.antiAlias,
                decoration:
                BoxDecoration(color: widget.theme.backgroundColor),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      context.l10n.general_post,
                      style: TextStyle(
                        color: (state.text.isEmpty)
                            ? const Color(0xFFA0BDF8)
                            : widget.theme.primaryColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ],
          ),
        ],
      ),
    );
  }

  Widget renderReplyPanel(AmityComment comment) {
    final commentCreator = comment.user?.displayName ?? "";
    return Container(
      width: double.infinity,
      height: 40,
      padding: const EdgeInsets.only(top: 10, left: 16, right: 12, bottom: 10),
      decoration: BoxDecoration(color: widget.theme.baseColorShade4),
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
                      text: context.l10n.comment_reply_to,
                      style: TextStyle(
                        color: widget.theme.baseColorShade1,
                        fontSize: 15,
                        fontFamily: 'SF Pro Text',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    TextSpan(
                      text: commentCreator,
                      style: TextStyle(
                        color: widget.theme.baseColorShade1,
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
              widget.action.onDissmiss();
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
}
