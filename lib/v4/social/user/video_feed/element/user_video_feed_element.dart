import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/base_element.dart';
import 'package:amity_uikit_beta_service/v4/core/video_post_player/pager/video_post_player.dart';
import 'package:amity_uikit_beta_service/v4/utils/network_image.dart';
import 'package:flutter/material.dart';

class UserVideoFeedElement extends BaseElement {
  final AmityPost post;

  UserVideoFeedElement({super.key, required this.post})
      : super(elementId: "video-feed-element");

  @override
  Widget buildElement(BuildContext context) {
    final imageUrl = (post.data as VideoData).thumbnail?.fileUrl ?? "";

    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoPostPlayerPager(
                posts: [post],
                initialIndex: 0,
              ),
            ),
          );
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            AmityNetworkImage(
                imageUrl: imageUrl,
                placeHolderPath:
                    "assets/Icons/amity_ic_video_thumbnail_placeholder.svg",
                fit: BoxFit.cover),

            // Note: Video Duration View. We don't have it yet on sdk
            // Positioned(
            //   left: 8,
            //   bottom: 8,
            //   child: Container(
            //       padding: const EdgeInsets.symmetric(
            //           horizontal: 4, vertical: 1),
            //       decoration: ShapeDecoration(
            //         color: Colors.black.withOpacity(0.50),
            //         shape: const RoundedRectangleBorder(
            //           borderRadius: BorderRadius.all(Radius.circular(4)),
            //         ),
            //       ),
            //       child: Wrap(
            //         children: [
            //           Text(
            //             "12:24",
            //             style: AmityTextStyle.caption(Colors.white),
            //           )
            //         ],
            //       )),
            // ),
          ],
        ),
      ),
    );
  }
}
