import 'package:amity_sdk/amity_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FreedomPostComposerPageBehavior {
  Cubit<int>? postAsCubit;

  void addIsCreateByAdminMetadata(Map<String, dynamic> currentMetadata) {}

  Widget buildPostAsButton(AmityCommunity community) => const SizedBox.shrink();
}
