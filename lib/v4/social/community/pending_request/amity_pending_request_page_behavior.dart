import 'package:flutter/material.dart';

class AmityPendingRequestPageBehavior {
  ScrollController? postReviewScrollerController;

  Widget? Function(ScrollController? scroll)? buildHeaderFlexibleSpace;
  Widget? Function()? buildTitle;
}