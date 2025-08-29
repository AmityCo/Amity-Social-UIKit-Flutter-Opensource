import 'package:amity_uikit_beta_service/v4/core/toast/amity_uikit_toast.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FreedomViewStoryPageBehavior {
  final bool handleNoStoriesState = false;
  final bool handleNoCommentsState = false;

  Widget buildNoStoriesWidget() => const SizedBox.shrink();

  Widget buildNoCommentsWidget() => const SizedBox.shrink();

  void showStorySuccessToast(BuildContext context) {
    context.read<AmityToastBloc>().add(
          const AmityToastShort(
            message: "Successfully shared story",
            icon: AmityToastIcon.success,
          ),
        );
  }
}
