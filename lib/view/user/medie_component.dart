import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/viewmodel/community_feed_viewmodel.dart';
import 'package:amity_uikit_beta_service/viewmodel/configuration_viewmodel.dart';
import 'package:amity_uikit_beta_service/viewmodel/user_feed_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum MediaType { photos, videos }

enum GalleryFeed { user, community }

class MediaGalleryPage extends StatelessWidget {
  final GalleryFeed galleryFeed;
  const MediaGalleryPage({super.key, required this.galleryFeed});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
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
            child: galleryFeed == GalleryFeed.community
                ? Consumer<CommuFeedVM>(
                    builder: (context, vm, child) {
                      return vm.getMediaType() == MediaType.photos
                          ? _buildMediaGrid(vm.getCommunityImagePosts())
                          : _buildVideoGrid(vm.getCommunityVideoPosts());
                    },
                  )
                : Consumer<UserFeedVM>(
                    builder: (context, vm, child) {
                      return vm.getMediaType() == MediaType.photos
                          ? _buildMediaGrid(vm.amityImagePosts)
                          : _buildVideoGrid(vm.amityVideoPosts);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _mediaButton(BuildContext context, String text, MediaType type) {
    return TextButton(
      onPressed: () {
        print(type);
        if (galleryFeed == GalleryFeed.user) {
          Provider.of<UserFeedVM>(context, listen: false)
              .doSelectMedieType(type);
        } else {
          Provider.of<CommuFeedVM>(context, listen: false)
              .doSelectMedieType(type);
        }
      },
      style: TextButton.styleFrom(
        foregroundColor: galleryFeed == GalleryFeed.community
            ? Provider.of<CommuFeedVM>(context).getMediaType() == type
                ? Colors.white
                : const Color(0xff636878)
            : Provider.of<UserFeedVM>(context).getMediaType() == type
                ? Colors.white
                : const Color(0xff636878),
        backgroundColor: galleryFeed == GalleryFeed.community
            ? Provider.of<CommuFeedVM>(context).getMediaType() == type
                ? Provider.of<AmityUIConfiguration>(context).primaryColor
                : const Color(0xffEBECEF)
            : Provider.of<UserFeedVM>(context).getMediaType() == type
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

  Widget buildPrivateAccountWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          "assets/images/privateIcon.png",
          package: "amity_uikit_beta_service",
        ),
        const SizedBox(height: 12),
        const Text(
          "This account is private",
          style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Color(0xff292B32)),
        ),
        const Text(
          "Follow this user to see all posts",
          style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Color(0xffA5A9B5)),
        ),
      ],
    );
  }

  Widget _buildMediaGrid(List<AmityPost> amityPosts) {
    Widget noPostWidget = SingleChildScrollView(
      child: SizedBox(
        height: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/Icon name.png",
              package: "amity_uikit_beta_service",
            ),
            const SizedBox(height: 12),
            const Text(
              "No photos yet",
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Color(0xffA5A9B5)),
            ),
          ],
        ),
      ),
    );
    Widget gridView = GridView.builder(
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
        var imageData = amityPosts[index].data as ImageData;
        var url = imageData.getUrl(AmityImageSize.MEDIUM);
        // return Text(url);

        return GridTile(
          child: Image.network(
            url,
            fit: BoxFit.cover,
          ),
        );
      },
    );

    if (galleryFeed == GalleryFeed.user) {
      return Consumer<UserFeedVM>(
        builder: (context, vm, child) {
          if (vm.amityMyFollowInfo.status != AmityFollowStatus.ACCEPTED &&
              vm.amityUser!.userId != AmityCoreClient.getUserId()) {
            return buildPrivateAccountWidget();
          } else if (vm.amityImagePosts.isEmpty) {
            return noPostWidget;
          } else {
            return gridView; // Placeholder for tab bar can be integrated here
          }
        },
      );
    } else {
      print("galleryFeed == GalleryFeed.community === CommuFeedVM");
      return Consumer<CommuFeedVM>(
        builder: (context, vm, child) {
          if (vm.getCommunityImagePosts().isEmpty) {
            print("empty");
            return noPostWidget;
          } else {
            print("not Empty");
            return gridView; // Placeholder for tab bar can be integrated here
          }
        },
      );
    }
  }

  Widget _buildVideoGrid(List<AmityPost> amityPosts) {
    var noPostWidget = SingleChildScrollView(
      child: SizedBox(
        height: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/noVideo.png",
              package: "amity_uikit_beta_service",
            ),
            const SizedBox(height: 12),
            const Text(
              "No videos yet",
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Color(0xffA5A9B5)),
            ),
          ],
        ),
      ),
    );
    var gridView = GridView.builder(
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
    if (galleryFeed == GalleryFeed.user) {
      return Consumer<UserFeedVM>(
        builder: (context, vm, child) {
          if (vm.amityMyFollowInfo.status != AmityFollowStatus.ACCEPTED &&
              vm.amityUser!.userId != AmityCoreClient.getUserId()) {
            return buildPrivateAccountWidget();
          } else if (vm.amityVideoPosts.isEmpty) {
            return noPostWidget;
          } else {
            return gridView; // Placeholder for tab bar can be integrated here
          }
        },
      );
    } else {
      return Consumer<CommuFeedVM>(
        builder: (context, vm, child) {
          if (vm.getCommunityVideoPosts().isEmpty) {
            return noPostWidget;
          } else {
            return gridView; // Placeholder for tab bar can be integrated here
          }
        },
      );
    }
  }
}
