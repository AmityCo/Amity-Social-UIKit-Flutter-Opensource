import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/core/video_post_player/pager/video_post_player.dart';
import 'package:amity_uikit_beta_service/v4/utils/network_image.dart';
import 'package:flutter/material.dart';

class UserVideoFeedElement extends StatefulWidget {
  final AmityPost post;
  final AmityThemeColor theme;
  
  UserVideoFeedElement({Key? key, required this.post, required this.theme}) : super(key: key);

  @override
  State<UserVideoFeedElement> createState() => _UserVideoFeedElementState();
}

class _UserVideoFeedElementState extends State<UserVideoFeedElement> {
  String? videoDuration;

  @override
  void initState() {
    super.initState();
    _loadVideoData();
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = (widget.post.data as VideoData).thumbnail?.fileUrl ?? "";

    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoPostPlayerPager(
                posts: [widget.post],
                initialIndex: 0,
                autoPlay: false,
              ),
            ),
          );
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                color: widget.theme.baseColorShade4,
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            if (videoDuration != null)
              Positioned(
                left: 8,
                bottom: 8,
                child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: ShapeDecoration(
                      color: Colors.black.withOpacity(0.50),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                    ),
                    child: Wrap(
                      children: [
                        Text(
                          videoDuration ?? '',
                          style: AmityTextStyle.caption(Colors.white),
                        )
                      ],
                    )),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadVideoData() async {
    final AmityVideo video =
        await (widget.post.data as VideoData).getVideo(AmityVideoQuality.LOW);
    final properties = video.getFileProperties;
    final videoMetadata =
        properties?.rawFile?["attributes"]["metadata"]["video"];
    final duration = videoMetadata?["duration"];

    setState(() {
      videoDuration = formatDuration(duration);
    });
  }

  String formatDuration(double seconds) {
    int totalSeconds = seconds.round();
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int remainingSeconds = totalSeconds % 60;

    // Format with leading zeros
    String twoDigits(int n) => n.toString().padLeft(2, '0');

    if (hours > 0) {
      return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(remainingSeconds)}';
    } else {
      return '${twoDigits(minutes)}:${twoDigits(remainingSeconds)}';
    }
  }
}
