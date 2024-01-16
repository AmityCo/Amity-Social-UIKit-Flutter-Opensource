import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/viewmodel/configuration_viewmodel.dart';
import 'package:amity_uikit_beta_service/viewmodel/user_feed_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MediaGalleryPage extends StatelessWidget {
  const MediaGalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 12,
        ),
        Row(
          children: [
            const SizedBox(
              width: 12,
            ),
            _mediaButton(context, "Photos", MediaType.photos),
            const SizedBox(
              width: 6,
            ),
            _mediaButton(context, "Videos", MediaType.videos),
          ],
        ),
        const SizedBox(
          height: 12,
        ),
        Expanded(
          child: Consumer<UserFeedVM>(
            builder: (context, vm, child) {
              return vm.getMediaType() == MediaType.photos
                  ? _buildMediaGrid(vm.amityImagePosts)
                  : _buildVideoGrid(vm.amityVideoPosts);
            },
          ),
        ),
      ],
    );
  }

  Widget _mediaButton(BuildContext context, String text, MediaType type) {
    return TextButton(
      onPressed: () {
        print(type);
        Provider.of<UserFeedVM>(context, listen: false).doSelectMedieType(type);
      },
      style: TextButton.styleFrom(
        foregroundColor: Provider.of<UserFeedVM>(context).getMediaType() == type
            ? Colors.white
            : const Color(0xff636878),
        backgroundColor: Provider.of<UserFeedVM>(context).getMediaType() == type
            ? Provider.of<AmityUIConfiguration>(context).primaryColor
            : const Color(0xffEBECEF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      ),
      child: Text(text),
    );
  }

  Widget _buildMediaGrid(List<AmityPost> amityPosts) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
      ),
      itemCount: amityPosts.length,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        String imageUrl = amityPosts[index].data!.fileInfo.fileUrl!;
        return GridTile(
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }

  Widget _buildVideoGrid(List<AmityPost> amityPosts) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
      ),
      itemCount: amityPosts.length,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        VideoData videoData = amityPosts[index].data as VideoData;
        String thumbnailUrl =
            videoData.thumbnail!.getUrl(AmityImageSize.MEDIUM);

        return GridTile(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(
                        thumbnailUrl,
                      )),
                  color: Colors.black38,
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  color: Colors.black38,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 50.0, // Adjust the size as needed
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
