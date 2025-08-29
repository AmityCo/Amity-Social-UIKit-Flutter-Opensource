import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/amity_uikit_toast.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FreedomCreatePostMenuComponentBehavior {
  final int storyTargetsPageSize = 50;

  Future<List<AmityCommunity>> getStoryTargets({
    required List<AmityCommunity> communities,
  }) async {
    return communities;
  }

  void showStorySuccessToast(BuildContext context) {
    context.read<AmityToastBloc>().add(
          const AmityToastShort(
            message: "Successfully shared story",
            icon: AmityToastIcon.success,
          ),
        );
  }
}
