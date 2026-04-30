import 'dart:typed_data';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/core/video_post_player/pager/video_post_player.dart';
import 'package:amity_uikit_beta_service/v4/social/post_composer_page/post_video_thumbnail_cache.dart';
import 'package:flutter/material.dart';

class PostContentVideo extends StatelessWidget {
  final List<AmityPost> posts;
  final AmityThemeColor theme;

  const PostContentVideo({super.key, required this.posts, required this.theme});

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) return Container();

    Widget backgroundThumbnail(String fileUrl, int index,
        {BorderRadius? borderRadius, String? postId}) {
      final hasNetworkUrl = fileUrl.isNotEmpty;
      Uint8List? localThumbnail;
      if (!hasNetworkUrl && postId != null) {
        localThumbnail = PostVideoThumbnailCache.instance.get(postId);
      } else if (hasNetworkUrl && postId != null) {
        // Server thumbnail is available, clean up cache
        PostVideoThumbnailCache.instance.remove(postId);
      }
      return Padding(
        padding: const EdgeInsets.all(2.0),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: theme.baseColorShade4,
                borderRadius: borderRadius,
                image: hasNetworkUrl
                    ? DecorationImage(
                        image: NetworkImage(fileUrl),
                        fit: BoxFit.cover,
                      )
                    : (localThumbnail != null
                        ? DecorationImage(
                            image: MemoryImage(localThumbnail),
                            fit: BoxFit.cover,
                          )
                        : null),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 40,
                height: 40,
                decoration: const ShapeDecoration(
                  color: Color(0x40000000),
                  shape:
                      OvalBorder(side: BorderSide(color: Colors.transparent)),
                ),
                child: const Icon(
                  Icons.play_arrow,
                  size: 25.0,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    }

    String getURL(AmityPostData postData) {
      if (postData is VideoData) {
        var data = postData;
        return data.thumbnail?.getUrl(AmityImageSize.MEDIUM) ?? "";
      } else if (postData is ImageData) {
        var data = postData;
        return data.image?.getUrl(AmityImageSize.MEDIUM) ?? "";
      } else {
        return "";
      }
    }

    switch (posts.length) {
      case 1:
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VideoPostPlayerPager(
                  posts: posts,
                  initialIndex: 0,
                ),
              ),
            );
          },
          child: AspectRatio(
            aspectRatio: 1,
            child: backgroundThumbnail(getURL(posts[0].data!), 0,
                postId: posts[0].postId,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8))),
          ),
        );

      case 2:
        return AspectRatio(
          aspectRatio: 1,
          child: Row(children: [
            Expanded(
                child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VideoPostPlayerPager(
                      posts: posts,
                      initialIndex: 0,
                    ),
                  ),
                );
              },
              child: backgroundThumbnail(getURL(posts[0].data!), 0,
                  postId: posts[0].postId,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8))),
            )),
            Expanded(
                child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VideoPostPlayerPager(
                      posts: posts,
                      initialIndex: 1,
                    ),
                  ),
                );
              },
              child: backgroundThumbnail(getURL(posts[1].data!), 1,
                  postId: posts[1].postId,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  )),
            ))
          ]),
        );

      case 3:
        return AspectRatio(
          aspectRatio: 1,
          child: Column(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoPostPlayerPager(
                          posts: posts,
                          initialIndex: 0,
                        ),
                      ),
                    );
                  },
                  child: backgroundThumbnail(getURL(posts[0].data!), 0,
                      postId: posts[0].postId,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      )),
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                        child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VideoPostPlayerPager(
                              posts: posts,
                              initialIndex: 1,
                            ),
                          ),
                        );
                      },
                      child: backgroundThumbnail(getURL(posts[1].data!), 1,
                          postId: posts[1].postId,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                          )),
                    )),
                    Expanded(
                        child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VideoPostPlayerPager(
                              posts: posts,
                              initialIndex: 2,
                            ),
                          ),
                        );
                      },
                      child: backgroundThumbnail(getURL(posts[2].data!), 2,
                          postId: posts[2].postId,
                          borderRadius: const BorderRadius.only(
                              bottomRight: Radius.circular(8))),
                    )),
                  ],
                ),
              ),
            ],
          ),
        );

      case 4:
        return AspectRatio(
          aspectRatio: 1,
          child: Column(
            children: [
              Expanded(
                  child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoPostPlayerPager(
                        posts: posts,
                        initialIndex: 0,
                      ),
                    ),
                  );
                },
                child: backgroundThumbnail(getURL(posts[0].data!), 0,
                    postId: posts[0].postId,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                    )),
              )),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VideoPostPlayerPager(
                              posts: posts,
                              initialIndex: 1,
                            ),
                          ),
                        );
                      },
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: backgroundThumbnail(getURL(posts[1].data!), 1,
                            postId: posts[1].postId,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(8),
                            )),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VideoPostPlayerPager(
                              posts: posts,
                              initialIndex: 2,
                            ),
                          ),
                        );
                      },
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: backgroundThumbnail(getURL(posts[2].data!), 2,
                            postId: posts[2].postId),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VideoPostPlayerPager(
                              posts: posts,
                              initialIndex: 3,
                            ),
                          ),
                        );
                      },
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: backgroundThumbnail(getURL(posts[3].data!), 3,
                            postId: posts[3].postId,
                            borderRadius: const BorderRadius.only(
                                bottomRight: Radius.circular(8))),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

      default:
        return AspectRatio(
          aspectRatio: 1,
          child: Column(
            children: [
              Expanded(
                  child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoPostPlayerPager(
                        posts: posts,
                        initialIndex: 0,
                      ),
                    ),
                  );
                },
                child: backgroundThumbnail(getURL(posts[0].data!), 0,
                    postId: posts[0].postId,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    )),
              )),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VideoPostPlayerPager(
                              posts: posts,
                              initialIndex: 1,
                            ),
                          ),
                        );
                      },
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: backgroundThumbnail(getURL(posts[1].data!), 1,
                            postId: posts[1].postId,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(8),
                            )),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VideoPostPlayerPager(
                              posts: posts,
                              initialIndex: 2,
                            ),
                          ),
                        );
                      },
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: backgroundThumbnail(getURL(posts[2].data!), 2,
                            postId: posts[2].postId),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VideoPostPlayerPager(
                              posts: posts,
                              initialIndex: 3,
                            ),
                          ),
                        );
                      },
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Stack(
                          children: [
                            backgroundThumbnail(getURL(posts[3].data!), 3,
                                postId: posts[3].postId,
                                borderRadius: const BorderRadius.only(
                                    bottomRight: Radius.circular(8))),
                            // Black filter overlay
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black
                                    .withOpacity(0.3), // Semi-transparent black
                              ),
                            ),
                            // Centered Text "6+"
                            Center(
                              child: Text(
                                "+${posts.length - 3}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize:
                                      24, // Adjust the font size as needed
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
    }
  }
}
