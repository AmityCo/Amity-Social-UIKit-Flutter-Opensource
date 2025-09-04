import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/amity_uikit.dart';
import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/core/ui/bottom_sheet_menu.dart';
import 'package:amity_uikit_beta_service/v4/core/user_avatar.dart';
import 'package:amity_uikit_beta_service/v4/social/post/amity_post_content_component.dart';
import 'package:amity_uikit_beta_service/v4/social/post/common/post_action.dart';
import 'package:amity_uikit_beta_service/v4/social/post/common/post_display_name.dart';
import 'package:amity_uikit_beta_service/v4/social/post/featured_badge.dart';
import 'package:amity_uikit_beta_service/v4/social/post/post_item/bloc/post_item_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/post_composer_page/post_composer_model.dart';
import 'package:amity_uikit_beta_service/v4/social/post_composer_page/post_composer_page.dart';
import 'package:amity_uikit_beta_service/viewmodel/edit_post_viewmodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../../core/toast/amity_uikit_toast.dart';

class AmityPostHeader extends StatelessWidget {
  final AmityPost post;
  final bool isShowOption;
  final AmityThemeColor theme;
  final AmityPostCategory category;
  final bool hideTarget;
  final AmityPostAction? action;

  const AmityPostHeader({
    super.key,
    required this.post,
    this.isShowOption = true,
    required this.theme,
    required this.category,
    required this.hideTarget,
    this.action,
  });

  void _showToast(BuildContext context, String message, AmityToastIcon icon) {
    context
        .read<AmityToastBloc>()
        .add(AmityToastShort(message: message, icon: icon));
  }

  bool showClosePollOption(AmityPost post) {
    if (post.feedType == AmityFeedType.PUBLISHED &&
        post.type == AmityDataType.TEXT) {
      final firstChild =
          post.children?.isNotEmpty == true ? post.children!.first : null;

      if (firstChild != null) {
        final data = firstChild.data;

        if (data != null && data is PollData && data.poll?.isClose == false) {
          return true;
        }
      }
    }
    return false;
  }

  Widget build(BuildContext context) {
    final localizations = context.l10n;
    return Column(
      children: [
        if (category == AmityPostCategory.announcement ||
            category == AmityPostCategory.announcementAndPin ||
            category == AmityPostCategory.globalFeatured)
          Row(
            children: [
              FeaturedBadge(text: localizations.general_featured),
            ],
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                if (post.postedUserId?.isNotEmpty ?? false) {
                  AmityUIKit4Manager.behavior.postContentComponentBehavior
                      .goToUserProfilePage(
                    context,
                    post.postedUserId!,
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.only(
                    top: 8, left: 12, right: 4, bottom: 8),
                child: AmityUserAvatar(
                  avatarUrl: post.postedUser?.avatarUrl,
                  displayName: post.postedUser?.displayName ?? "",
                  isDeletedUser: post.postedUser?.isDeleted ?? false,
                  characterTextStyle: AmityTextStyle.titleBold(Colors.white),
                  avatarSize: const Size(32, 32),
                ),
              ),
            ),
            Expanded(
                child: PostDisplayName(
                    post: post, theme: theme, hideTarget: hideTarget)),
            if (category == AmityPostCategory.pin ||
                category == AmityPostCategory.announcementAndPin) ...[
              Container(
                  width: 33,
                  height: 33,
                  padding: const EdgeInsets.only(
                      top: 4, left: 2, right: 2, bottom: 8),
                  child: SizedBox(
                      width: 20,
                      child: SvgPicture.asset(
                        'assets/Icons/amity_ic_pin_badge.svg',
                        package: 'amity_uikit_beta_service',
                        width: 20,
                        height: 20,
                      )))
            ],
            GestureDetector(
              onTap: () => showPostAction(context, post),
              child: Container(
                width: 44,
                height: 44,
                padding: const EdgeInsets.only(
                    top: 8, left: 4, right: 16, bottom: 8),
                child: isShowOption ? getPostOptionIcon() : Container(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget getPostOptionIcon() {
    return Container(
      width: 16,
      height: 16,
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: SvgPicture.asset(
        'assets/Icons/amity_ic_post_item_option.svg',
        package: 'amity_uikit_beta_service',
        colorFilter: ColorFilter.mode(theme.baseColor, BlendMode.srcIn),
        width: 16,
        height: 12,
      ),
    );
  }

  void showPostAction(BuildContext context, AmityPost post) async {
    final currentUserId = AmityCoreClient.getUserId();

    var isModerator = false;

    var postTarget = post.target;
    if (postTarget is CommunityTarget) {
      var roles = await AmitySocialClient.newCommunityRepository()
          .getCurrentUserRoles(postTarget.targetCommunityId ?? "");

      if (roles != null &&
          (roles.contains("moderator") ||
              roles.contains("community-moderator"))) {
        isModerator = true;
      }
    }

    if (post.postedUserId == currentUserId) {
      showBottomSheetForOwner(context, post, isModerator);
    } else {
      showBottomSheetForGeneralActions(context, post, isModerator);
    }
  }

  void showBottomSheetForGeneralActions(
    BuildContext context,
    AmityPost post,
    bool isModerator,
  ) {
    List<BottomSheetMenuOption> userActions = [];

    onReport() => {
          context.read<PostItemBloc>().add(PostItemFlag(
              post: post, toastBloc: context.read<AmityToastBloc>()))
        };
    onUnReport() => {
          context.read<PostItemBloc>().add(PostItemUnFlag(
              post: post, toastBloc: context.read<AmityToastBloc>()))
        };

    onDelete() => {
          context
              .read<PostItemBloc>()
              .add(PostItemDelete(post: post, action: action))
        };

    final reportOption = BottomSheetMenuOption(
        title: context.l10n.post_report,
        icon: "assets/Icons/amity_ic_flag.svg",
        onTap: () {
          Navigator.of(context).pop();
          onReport();
        });

    final unreportOption = BottomSheetMenuOption(
        title: context.l10n.post_unreport,
        icon: "assets/Icons/amity_ic_flag.svg",
        onTap: () {
          Navigator.of(context).pop();
          onUnReport();
        });

    final deleteOption = BottomSheetMenuOption(
        title: context.l10n.post_delete,
        icon: "assets/Icons/amity_ic_delete.svg",
        textStyle: AmityTextStyle.bodyBold(theme.alertColor),
        colorFilter: ColorFilter.mode(theme.alertColor, BlendMode.srcIn),
        onTap: () {
          Navigator.of(context).pop();

          showConfirmationAlert(
              context,
              context.l10n.post_delete,
              context.l10n.post_delete_description,
              context.l10n.general_delete,
              onDelete);
        });

    if (!post.isFlaggedByMe) {
      userActions.add(reportOption);
    } else {
      userActions.add(unreportOption);
    }

    if (isModerator) {
      userActions.add(deleteOption);
    }

    BottomSheetMenu(options: userActions).show(context, theme);
  }

  void showBottomSheetForOwner(
      BuildContext context, AmityPost post, bool isModerator) {
    final editOption = AmityPostComposerOptions.editOptions(post: post);
    final localizations = context.l10n;

    onEdit() => {
          Navigator.of(context).push(MaterialPageRoute(
              fullscreenDialog: true,
              builder: (context) => ChangeNotifierProvider<EditPostVM>(
                  create: (context) => EditPostVM(),
                  child: AmityPostComposerPage(options: editOption))))
        };

    onClosePoll(String pollId) => {
          AmitySocialClient.newPollRepository()
              .closePoll(pollId: pollId)
              .then((value) {
            //success
          }).onError((error, stackTrace) {
            _showToast(
                context, localizations.general_error, AmityToastIcon.warning);
          })
        };

    onDelete() {
      AmitySocialClient.newPostRepository()
          .deletePost(postId: post.postId!)
          .then((value) {
        context
            .read<PostItemBloc>()
            .add(PostItemDelete(post: post, action: action));
        //success
      }).onError((error, stackTrace) {
        _showToast(
            context, localizations.error_delete_post, AmityToastIcon.warning);
      });
    }

    List<BottomSheetMenuOption> userActions = [];

    final editMenuOption = BottomSheetMenuOption(
        title: context.l10n.post_edit,
        icon: "assets/Icons/amity_ic_edit_comment.svg",
        onTap: () {
          if (category == AmityPostCategory.globalFeatured) {
            Navigator.pop(context);
            showConfirmationAlert(
                context,
                localizations.post_edit_globally_featured,
                localizations.post_edit_globally_featured_description,
                localizations.general_edit, () {
              onEdit();
            });
          } else {
            Navigator.pop(context);
            onEdit();
          }
        });

    final deleteOption = BottomSheetMenuOption(
        title: context.l10n.post_delete,
        icon: "assets/Icons/amity_ic_delete.svg",
        textStyle: AmityTextStyle.bodyBold(theme.alertColor),
        colorFilter: ColorFilter.mode(theme.alertColor, BlendMode.srcIn),
        onTap: () {
          Navigator.of(context).pop();

          showConfirmationAlert(
              context,
              context.l10n.post_delete,
              context.l10n.post_delete_description,
              context.l10n.general_delete,
              onDelete);
        });

    if (post.type == AmityDataType.TEXT &&
        (post.children == null ||
            post.children!.first.type != AmityDataType.POLL)) {
      userActions.add(editMenuOption);
    }

    if (showClosePollOption(post)) {
      final pollId = (post.children!.first.data as PollData).pollId;

      final closePollOption = BottomSheetMenuOption(
          title: context.l10n.post_delete,
          icon: "assets/Icons/amity_ic_create_poll_button.svg",
          onTap: () {
            Navigator.pop(context);

            showConfirmationAlert(
                context,
                localizations.poll_close,
                localizations.poll_close_description,
                localizations.poll_close, () {
              onClosePoll(pollId);
            });
          });

      userActions.add(closePollOption);
    }

    userActions.add(deleteOption);

    BottomSheetMenu(options: userActions).show(context, theme);
  }

  void showConfirmationAlert(
    BuildContext context,
    String title,
    String content,
    String actionButtonTitle,
    Function action,
  ) {
    final localizations = context.l10n;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            CupertinoDialogAction(
              child: Text(
                localizations.general_cancel,
                style: AmityTextStyle.title(theme.primaryColor),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: Text(
                actionButtonTitle,
                style: AmityTextStyle.titleBold(theme.alertColor),
              ),
              onPressed: () {
                Navigator.of(context).pop();

                action();
              },
            ),
          ],
        );
      },
    );
  }
}
