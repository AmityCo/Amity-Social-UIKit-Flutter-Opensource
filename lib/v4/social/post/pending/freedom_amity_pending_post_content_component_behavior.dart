import 'package:flutter/material.dart';

class FreedomAmityPendingPostContentComponentBehavior {
  Widget Function(
    BuildContext context, {
    VoidCallback? onPressed,
    required bool isApprovingPost,
  })? buildPostAcceptButton;

  Widget Function(
    BuildContext context, {
    VoidCallback? onPressed,
    required bool isDecliningPost,
  })? buildPostDeclineButton;
}
