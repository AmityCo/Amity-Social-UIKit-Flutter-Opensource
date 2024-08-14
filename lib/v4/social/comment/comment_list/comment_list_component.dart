import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/base_component.dart';
import 'package:amity_uikit_beta_service/v4/social/comment/comment_item/comment_action.dart';
import 'package:amity_uikit_beta_service/v4/social/comment/comment_list/bloc/comment_list_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/comment/comment_list/comment_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AmityCommentTrayComponent extends NewBaseComponent {
  final String referenceId;
  final AmityCommentReferenceType referenceType;
  final ScrollController parentScrollController;
  final CommentAction commentAction;

  AmityCommentTrayComponent({
    Key? key,
    String? pageId,
    required this.referenceId,
    required this.referenceType,
    required this.parentScrollController,
    required this.commentAction,
  }) : super(key: key, pageId: pageId, componentId: "comment_tray_component");

  @override
  Widget buildComponent(BuildContext context) {
    return BlocProvider(
      create: (context) => CommentListBloc(referenceId, referenceType, null),
      child: CommentList(
        scrollController: parentScrollController,
        commentAction: commentAction,
      ),
    );
  }
  
}
