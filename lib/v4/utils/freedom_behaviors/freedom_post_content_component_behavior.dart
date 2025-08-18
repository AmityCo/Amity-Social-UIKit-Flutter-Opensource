import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/social/post/post_item/bloc/post_item_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FreedomPostContentComponentBehavior {
  bool getIsCreatedByAdmin(AmityPost post) => false;

  String? getCommunityAvatarUrl(AmityPost post) => null;

  String getCommunityDisplayName(AmityPost post) => '';

  bool getIsCommunityDeleted(AmityPost post) => false;

  String? getUserPublicProfile(AmityPost post) => null;

  List<Widget> buildTitleWidget(
    AmityPost post,
    Widget targetWidget,
    Widget verifiedWidget,
  ) =>
      [const SizedBox.shrink()];

  void onModulatorPostDelete(
    BuildContext context, {
    post,
    action,
    required Function onError,
  }) {
    context
        .read<PostItemBloc>()
        .add(PostItemDelete(post: post, action: action));
  }
}
