import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/base_element.dart';
import 'package:flutter/widgets.dart';

class AmityCommunityName extends BaseElement {
  final AmityCommunity? community;

  AmityCommunityName({super.key, required this.community})
      : super(elementId: "community_name");

  @override
  Widget buildElement(BuildContext context) {
    return Text(
      community?.displayName ?? "",
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: theme.baseColor,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      softWrap: false,
    );
  }
}
