import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/image_viewer.dart';
import 'package:flutter/material.dart';

class PostContentImage extends StatelessWidget {
  final List<AmityPost> posts;
  const PostContentImage({super.key, required this.posts});

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) return Container();

    Widget backgroundImage(String fileUrl, int index,
        {BorderRadius? borderRadius}) {
      return Padding(
        padding: const EdgeInsets.all(2.0),
        child: Container(
          padding: const EdgeInsets.all(2.0),
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            image: DecorationImage(
              image: NetworkImage(fileUrl),
              fit: BoxFit.cover,
            ),
          ),
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

    Widget buildSingleImage(List<AmityPost> posts) {
      return AspectRatio(
        aspectRatio: 1,
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ImagePostViewer(
                  posts: posts,
                  initialIndex: 0,
                ),
              ),
            );
          },
          child: backgroundImage(getURL(posts[0].data!), 0,
              borderRadius: BorderRadius.circular(8)),
        ),
      );
    }

    Widget buildTwoImages(List<AmityPost> posts) {
      return AspectRatio(
        aspectRatio: 1,
        child: Row(children: [
          Expanded(
              child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ImagePostViewer(
                    posts: posts,
                    initialIndex: 0,
                  ),
                ),
              );
            },
            child: backgroundImage(getURL(posts[0].data!), 0,
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
                  builder: (context) => ImagePostViewer(
                    posts: posts,
                    initialIndex: 1,
                  ),
                ),
              );
            },
            child: backgroundImage(getURL(posts[1].data!), 1,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(8))),
          ))
        ]),
      );
    }

    Widget buildThreeImages(List<AmityPost> posts) {
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
                    builder: (context) => ImagePostViewer(
                      posts: posts,
                      initialIndex: 0,
                    ),
                  ),
                );
              },
              child: backgroundImage(getURL(posts[0].data!), 0,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8))),
            )),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                      child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ImagePostViewer(
                            posts: posts,
                            initialIndex: 1,
                          ),
                        ),
                      );
                    },
                    child: backgroundImage(getURL(posts[1].data!), 1,
                        borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(8))),
                  )),
                  Expanded(
                      child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ImagePostViewer(
                            posts: posts,
                            initialIndex: 2,
                          ),
                        ),
                      );
                    },
                    child: backgroundImage(getURL(posts[2].data!), 2,
                        borderRadius: const BorderRadius.only(
                            bottomRight: Radius.circular(8))),
                  )),
                ],
              ),
            ),
          ],
        ),
      );
    }

    Widget buildFourImages(List<AmityPost> posts) {
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
                    builder: (context) => ImagePostViewer(
                      posts: posts,
                      initialIndex: 0,
                    ),
                  ),
                );
              },
              child: backgroundImage(getURL(posts[0].data!), 0,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8))),
            )),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ImagePostViewer(
                            posts: posts,
                            initialIndex: 1,
                          ),
                        ),
                      );
                    },
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: backgroundImage(getURL(posts[1].data!), 1,
                          borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(8))),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ImagePostViewer(
                            posts: posts,
                            initialIndex: 2,
                          ),
                        ),
                      );
                    },
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: backgroundImage(getURL(posts[2].data!), 2),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ImagePostViewer(
                            posts: posts,
                            initialIndex: 3,
                          ),
                        ),
                      );
                    },
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: backgroundImage(getURL(posts[3].data!), 3,
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
    }

    Widget buildDefaultImage(List<AmityPost> posts) {
      return AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(8.0), // Border radius for the entire grid
            // Add other properties like a border or shadow if needed
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Expanded(
                  child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ImagePostViewer(
                        posts: posts,
                        initialIndex: 0,
                      ),
                    ),
                  );
                },
                child: backgroundImage(getURL(posts[0].data!), 0,
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8))),
              )),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImagePostViewer(
                              posts: posts,
                              initialIndex: 1,
                            ),
                          ),
                        );
                      },
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: backgroundImage(getURL(posts[1].data!), 1,
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
                            builder: (context) => ImagePostViewer(
                              posts: posts,
                              initialIndex: 2,
                            ),
                          ),
                        );
                      },
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: backgroundImage(getURL(posts[2].data!), 2),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImagePostViewer(
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
                            backgroundImage(getURL(posts[3].data!), 3,
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
        ),
      );
    }

    switch (posts.length) {
      case 1:
        return buildSingleImage(posts);
      case 2:
        return buildTwoImages(posts);
      case 3:
        return buildThreeImages(posts);
      case 4:
        return buildFourImages(posts);
      default:
        return buildDefaultImage(posts);
    }
  }
}