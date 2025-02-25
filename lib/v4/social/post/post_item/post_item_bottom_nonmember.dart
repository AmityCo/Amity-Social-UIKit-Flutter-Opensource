import 'package:amity_uikit_beta_service/v4/core/base_element.dart';
import 'package:flutter/material.dart';

class PostBottomNonMember extends BaseElement {
  PostBottomNonMember({super.key}) : super(elementId: 'post_bottom_nonmember');

  @override
  Widget buildElement(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 7),
          child: Container(
            width: double.infinity,
            height: 1,
            color: theme.baseColorShade4,
          ),
        ),
        Container(
          width: double.infinity,
          height: 36,
          padding: const EdgeInsets.only(
            top: 4,
            left: 16,
            right: 82,
            bottom: 12,
          ),
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(color: Colors.white),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Join community to interact with all posts',
                style: TextStyle(
                  color: Color(0xFF898E9E),
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
