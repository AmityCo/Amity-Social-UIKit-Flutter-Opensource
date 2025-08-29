import 'package:flutter/material.dart';

class FreedomViewStoryPageBehavior {
  final bool handleNoStoriesState = false;
  final bool handleNoCommentsState = false;

  Widget buildNoStoriesWidget() => const SizedBox.shrink();

  Widget buildNoCommentsWidget() => const SizedBox.shrink();
}
