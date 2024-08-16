import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/base_page.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/amity_uikit_toast.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/globalfeed/bloc/global_feed_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/post_composer_page/bloc/post_composer_bloc.dart';
import 'package:amity_uikit_beta_service/v4/utils/amity_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class PostComposerPage extends NewBasePage {
  final AmityPostComposerOptions options;
  final TextEditingController _controller = TextEditingController(text: '');
  final void Function(bool shouldPopCaller)? onPopRequested;
  late String currentPostText = '';

  PostComposerPage({Key? key, required this.options, this.onPopRequested})
      : super(key: key, pageId: '');

  @override
  Widget buildPage(BuildContext context) {
    bool isButtonEnabled = false;
    if (options.mode == AmityPostComposerMode.edit &&
        options.post?.data is TextData) {
          currentPostText = (options.post!.data as TextData).text ?? '';
    }
    return BlocProvider(
      create: (context) => PostComposerBloc(),
      child: Builder(builder: (context) {
        _initializeController(context);

        return BlocBuilder<PostComposerBloc, PostComposerState>(
          builder: (context, state) {
            if (state is PostComposerTextChangeState) {
              _controller.text = state.text;
              if (currentPostText != state.text) {
                isButtonEnabled = true;
              } else {
                isButtonEnabled = false;
              }
            }
            return Scaffold(
              backgroundColor: theme.backgroundColor,
              appBar: _buildAppBar(context, isButtonEnabled),
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Flexible(
                      child: _buildTextField(),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  void _initializeController(BuildContext context) {
    if (options.mode == AmityPostComposerMode.edit &&
        options.post?.data is TextData) {
      _controller.text = (options.post!.data as TextData).text ?? '';
    }
    _controller.addListener(() {
      context
          .read<PostComposerBloc>()
          .add(PostComposerTextChangeEvent(text: _controller.text));
    });
  }

  AppBar _buildAppBar(BuildContext context, bool isButtonEnabled) {
    return AppBar(
      backgroundColor: theme.backgroundColor,
      title: Text(
        _getPageTitle(),
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
      ),
      leading: IconButton(
        icon: SvgPicture.asset(
          'assets/Icons/amity_ic_close_button.svg',
          package: 'amity_uikit_beta_service',
          width: 24,
          height: 24,
        ),
        onPressed: () => _handleClose(context),
      ),
      centerTitle: true,
      actions: [_buildActionButton(context, isButtonEnabled)],
    );
  }

  String _getPageTitle() {
    if (options.mode == AmityPostComposerMode.edit) {
      return "Edit Post";
    } else if (options.targetType == AmityPostTargetType.USER) {
      return "My Timeline";
    } else {
      return options.community?.displayName ?? '';
    }
  }

  Widget _buildActionButton(BuildContext context, bool isButtonEnabled) {
    return TextButton(
      onPressed: isButtonEnabled ? () => _handleAction(context) : null,
      child: Text(
        options.mode == AmityPostComposerMode.edit ? "Save" : "Post",
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: isButtonEnabled
              ? theme.primaryColor
              : theme.primaryColor.blend(ColorBlendingOption.shade2),
        ),
      ),
    );
  }

  void _handleClose(BuildContext context) {
    ConfirmationV4Dialog().show(
      context: context,
      title: 'Discard this post?',
      detailText: 'The post will be permanently deleted. It cannot be undone.',
      leftButtonText: 'Keep editing',
      rightButtonText: 'Discard',
      onConfirm: () {
        Navigator.pop(context);
        onPopRequested?.call(true);
      },
    );
  }

  void _handleAction(BuildContext context) {
    if (options.mode == AmityPostComposerMode.edit) {
      _editPost(context);
    } else {
      _createPost(context);
    }
  }

  void _editPost(BuildContext context) {
    options.post?.edit().text(_controller.text).build().update().then((post) {
      context
          .read<GlobalFeedBloc>()
          .add(GlobalFeedReloadThePost(post: post));
      Navigator.pop(context);
    }).onError((error, stackTrace) {
      _showToast(context, "Failed to edit a post", AmityToastIcon.warning);
    });
  }

  void _createPost(BuildContext context) {
    final targetId = options.targetId;
    final postRepo = AmitySocialClient.newPostRepository();
    context.read<AmityToastBloc>().add(const AmityToastLoading(
        message: "Posting", icon: AmityToastIcon.loading));

    if (options.targetType == AmityPostTargetType.COMMUNITY &&
        targetId != null) {
      postRepo
          .createPost()
          .targetCommunity(targetId)
          .text(_controller.text)
          .post()
          .then((post) {
        _onPostSuccess(context, post);
      }).onError((error, stackTrace) {
        _showToast(context, "Failed to create post. Please try again.",
            AmityToastIcon.warning);
      });
    } else if (targetId == null) {
      postRepo
          .createPost()
          .targetMe()
          .text(_controller.text)
          .post()
          .then((post) {
        _onPostSuccess(context, post);
      }).onError((error, stackTrace) {
        _showToast(context, "Failed to edit post. Please try again.",
            AmityToastIcon.warning);
      });
    }
  }

  void _onPostSuccess(BuildContext context, AmityPost post) {
    context.read<AmityToastBloc>().add(AmityToastDismiss());
    Future.delayed(const Duration(milliseconds: 500), () {
      context.read<GlobalFeedBloc>().add(GlobalFeedAddLocalPost(post: post));
      Navigator.pop(context);
      onPopRequested?.call(true);
    });
  }

  void _showToast(BuildContext context, String message, AmityToastIcon icon) {
    context
        .read<AmityToastBloc>()
        .add(AmityToastShort(message: message, icon: icon));
  }

  Widget _buildTextField() {
    return TextFormField(
      controller: _controller,
      maxLines: null,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        hintText: "What’s going on...",
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        hintStyle: TextStyle(color: theme.baseColorShade3),
      ),
    );
  }
}

class AmityPostComposerOptions {
  final AmityPostComposerMode mode;
  final AmityPost? post;
  final String? targetId;
  final AmityPostTargetType? targetType;
  final AmityCommunity? community;

  AmityPostComposerOptions.editOptions({
    this.mode = AmityPostComposerMode.edit,
    required this.post,
  })  : targetId = null,
        targetType = null,
        community = null;

  AmityPostComposerOptions.createOptions({
    this.mode = AmityPostComposerMode.create,
    this.targetId,
    required this.targetType,
    this.community,
  }) : post = null;
}

enum AmityPostComposerMode {
  create,
  edit,
}
