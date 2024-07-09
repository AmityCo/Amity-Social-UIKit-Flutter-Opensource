import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/comment/comment_creator/bloc/comment_creator_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/comment/comment_creator/comment_creator_action.dart';
import 'package:amity_uikit_beta_service/v4/utils/image_util.dart';
import 'package:amity_uikit_beta_service/v4/utils/network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class AmityCommentCreator extends StatelessWidget {
  final String referenceId;
  final AmityComment? replyTo;
  final CommentCreatorAction action;
  final AmityThemeColor theme;

  const AmityCommentCreator({
    Key? key,
    required this.referenceId,
    this.replyTo,
    required this.action,
    required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AmityCommentCreatorInternal(
      referenceId: referenceId,
      replyTo: replyTo,
      action: action,
      theme: theme,
    );
  }
}

class AmityCommentCreatorInternal extends StatefulWidget {
  final String referenceId;
  final AmityComment? replyTo;
  final CommentCreatorAction action;
  final AmityThemeColor theme;

  const AmityCommentCreatorInternal({
    Key? key,
    required this.referenceId,
    this.replyTo,
    required this.action,
    required this.theme,
  }) : super(key: key);

  @override
  _AmityCommentCreatorInternalState createState() =>
      _AmityCommentCreatorInternalState();
}

class _AmityCommentCreatorInternalState
    extends State<AmityCommentCreatorInternal> {
  late TextEditingController controller;
  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
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
                child: renderComposer(context, state),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget renderComposer(BuildContext context, CommentCreatorState state) {
    String? avatarUrl = AmityCoreClient.getCurrentUser().avatarUrl;
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
                    child: AmityNetworkImage(
                        imageUrl: avatarUrl,
                        placeHolderPath:
                            "assets/Icons/amity_ic_user_avatar_placeholder.svg"),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 200),
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
                      child: TextField(
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
                          hintText: 'Say something nice...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color: widget.theme.baseColorShade2,
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  context.read<CommentCreatorBloc>().add(CommentCreatorCreated(
                        referenceId: widget.referenceId,
                        text: controller.text,
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
                        'Post',
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
                      text: 'Replying to ',
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
