import 'dart:developer';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/view/social/imag_viewer.dart';
import 'package:any_link_preview/any_link_preview.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:flutter_link_previewer/flutter_link_previewer.dart';
import 'package:http/http.dart' as http;
import 'package:linkify/linkify.dart';
import 'package:linkwell/linkwell.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../components/video_player.dart';
import 'image_viewer.dart';

class AmityPostWidget extends StatefulWidget {
  final List<AmityPost> posts;
  final bool isChildrenPost;
  final bool isCornerRadiusEnabled;
  final bool haveChildrenPost;
  final bool shouldShowTextPost;

  const AmityPostWidget(
      this.posts, this.isChildrenPost, this.isCornerRadiusEnabled,
      {super.key,
      this.haveChildrenPost = false,
      this.shouldShowTextPost = true});
  @override
  AmityPostWidgetState createState() => AmityPostWidgetState();
}

class AmityPostWidgetState extends State<AmityPostWidget> {
  List<String> imageURLs = [];
  String? videoUrl;
  bool isLoading = true;
  Map<String, PreviewData> datas = {};
  @override
  void initState() {
    super.initState();
    if (!widget.isChildrenPost) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      checkPostType();
    }
  }

  Future<void> checkPostType() async {
    switch (widget.posts[0].type) {
      case AmityDataType.IMAGE:
        await getImagePost();
        break;
      case AmityDataType.VIDEO:
        await getVideoPost();
        break;
      default:
        break;
    }
  }

  Future<void> getVideoPost() async {
    // final videoData = widget.posts[0].data as VideoData;

    // await videoData.getVideo(AmityVideoQuality.HIGH).then((AmityVideo video) {
    //   if (this.mounted) {
    //     setState(() {
    //       isLoading = false;
    //       videoUrl = video.fileUrl;
    //       log(">>>>>>>>>>>>>>>>>>>>>>>>${videoUrl}");
    //     });
    //   }
    // });
  }

  Future<void> getImagePost() async {
    List<String> imageUrlList = [];

    for (var post in widget.posts) {
      final imageData = post.data as ImageData;
      final largeImageUrl = imageData.getUrl(AmityImageSize.LARGE);

      imageUrlList.add(largeImageUrl);
    }
    if (mounted) {
      setState(() {
        isLoading = false;
        imageURLs = imageUrlList;
      });
    }
  }

  bool urlValidation(AmityPost post) {
    final url = extractLink(post); //urlExtraction(post);
    log("checking url validation $url");
    return AnyLinkPreview.isValidLink(url);
  }

  String extractLink(AmityPost post) {
    final textdata = post.data as TextData;
    final text = textdata.text ?? "";
    var elements = linkify(text,
        options: const LinkifyOptions(
          humanize: false,
          defaultToHttps: true,
        ));
    for (var e in elements) {
      if (e is LinkableElement) {
        return e.url;
      }
    }
    return "";
  }

  Widget generateURLWidget(String url) {
    const style = TextStyle(
      color: Colors.black,
      fontSize: 16,
      fontWeight: FontWeight.w500,
      height: 1.375,
    );

    return LinkPreview(
      enableAnimation: true,
      onPreviewDataFetched: (data) {
        setState(() {
          datas = {
            ...datas,
            url: data,
          };
        });
      },
      previewData: datas[url],
      padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
      imageBuilder: ((imageUrl) {
        return
            // OptimizedCacheImage(
            //   imageUrl: url,
            //   fit: BoxFit.fill,
            //   placeholder: (context, url) => Container(
            //     color: Colors.grey,
            //   ),
            //   errorWidget: (context, url, error) => const Icon(Icons.error),
            // );
            Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(0, 5, 0, 0),
          height: 150,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(imageUrl),
            ),
          ),
        );
      }),
      metadataTextStyle: style.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      animationDuration: const Duration(milliseconds: 300),
      metadataTitleStyle: style.copyWith(
        fontWeight: FontWeight.w800,
      ),
      textWidget: const SizedBox(
        height: 0,
      ),
      text: url,
      width: MediaQuery.of(context).size.width,
      onLinkPressed: ((url) {
        _launchUrl(url);
      }),
      openOnPreviewImageTap: true,
      openOnPreviewTitleTap: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isChildrenPost) {
      if (widget.haveChildrenPost || !urlValidation(widget.posts[0])) {
        return TextPost(post: widget.posts[0]);
      } else {
        String url =
            extractLink(widget.posts[0]); //urlExtraction(widget.posts[0]);

        return Column(
          children: [
            // Text(url),
            widget.shouldShowTextPost
                ? TextPost(post: widget.posts[0])
                : Container(),
            generateURLWidget(url.toLowerCase())
            // AnyLinkPreview(
            //   link: url.toLowerCase(),
            //   displayDirection: UIDirection.uiDirectionVertical,
            //   // showMultimedia: false,
            //   bodyMaxLines: 5,
            //   bodyTextOverflow: TextOverflow.ellipsis,
            //   titleStyle: TextStyle(
            //     color: Colors.black,
            //     fontWeight: FontWeight.bold,
            //     fontSize: 15,
            //   ),
            //   bodyStyle: TextStyle(color: Colors.grey, fontSize: 12),
            //   errorBody: 'Error getting body',
            //   errorTitle: 'Error getting title',
            //   errorWidget: Container(
            //     color: Colors.grey[300],
            //     child: Text('Oops!'),
            //   ),
            //   // errorImage: "https://google.com/",
            //   cache: const Duration(days: 0),
            //   backgroundColor: Colors.grey[100],
            //   borderRadius: 0,
            //   removeElevation: true,
            //   boxShadow: null, //[BoxShadow(blurRadius: 3, color: Colors.grey)],
            //   onTap: () {}, // This disables tap event
            // )
          ],
        );
      }
    } else {
      switch (widget.posts[0].type) {
        case AmityDataType.IMAGE:
          return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0), // Add border radius
              ),
              child: _buildMediaGrid(widget.posts));
        case AmityDataType.VIDEO:
          return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0), // Add border radius
              ),
              child: _buildVideoGrid(widget.posts));
        // return MyVideoPlayer2(
        //     post: widget.posts[0],
        //     url: videoUrl ?? "",
        //     isInFeed: widget.isCornerRadiusEnabled,
        //     isEnableVideoTools: false);
        case AmityDataType.FILE:
          return _listMediaGrid(widget.posts);
        default:
          return Container();
      }
    }
  }

  // Future<void> _playVideo(AmityPost post) async {
  //   if (post.data is VideoData) {
  //     var data = post.data as VideoData;
  //     var video = await data.getVideo(AmityVideoQuality.MEDIUM);
  //     var videoURL = video.fileUrl;
  //     // Logic to play the video, e.g., navigate to a video player widget
  //     log(videoURL);
  //     Navigator.of(context).push(MaterialPageRoute(
  //       builder: (_) => MyVideoPlayer2(
  //         url: videoURL!,
  //         post: post,
  //         isInFeed: true, // set accordingly
  //         isEnableVideoTools: true, // set accordingly
  //       ),
  //     ));
  //   }
  // }

  Widget _buildVideoGrid(List<AmityPost> files) {
    if (files.isEmpty) return Container();

    Widget backgroundThumbnail(String fileUrl, int index,
        {BorderRadius? borderRadius}) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoPlayerScreen(files: files),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: borderRadius,
                  image: DecorationImage(
                    image: NetworkImage(fileUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const Align(
                alignment: Alignment.center,
                child: Icon(
                  Icons.play_arrow,
                  size: 70.0,
                  color: Colors.white,
                ),
              ),
            ],
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

    switch (files.length) {
      case 1:
        return AspectRatio(
          aspectRatio: 1,
          child: backgroundThumbnail(getURL(files[0].data!), 0,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8))),
        );

      case 2:
        return AspectRatio(
          aspectRatio: 1,
          child: Row(children: [
            Expanded(
                child: backgroundThumbnail(getURL(files[0].data!), 0,
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        bottomLeft: Radius.circular(8)))),
            Expanded(
                child: backgroundThumbnail(getURL(files[1].data!), 1,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    )))
          ]),
        );

      case 3:
        return AspectRatio(
          aspectRatio: 1,
          child: Column(
            children: [
              Expanded(
                  child: backgroundThumbnail(getURL(files[0].data!), 0,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ))),
              Row(
                children: [
                  Expanded(
                      child: backgroundThumbnail(getURL(files[1].data!), 1,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                          ))),
                  Expanded(
                      child: backgroundThumbnail(getURL(files[2].data!), 2,
                          borderRadius: const BorderRadius.only(
                              bottomRight: Radius.circular(8)))),
                ],
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
                  child: backgroundThumbnail(getURL(files[0].data!), 0,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                      ))),
              Row(
                children: [
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: backgroundThumbnail(getURL(files[1].data!), 1,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                          )),
                    ),
                  ),
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: backgroundThumbnail(getURL(files[2].data!), 2),
                    ),
                  ),
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: backgroundThumbnail(getURL(files[3].data!), 3,
                          borderRadius: const BorderRadius.only(
                              bottomRight: Radius.circular(8))),
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
                  child: backgroundThumbnail(getURL(files[0].data!), 0,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ))),
              Row(
                children: [
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: backgroundThumbnail(getURL(files[1].data!), 1,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                          )),
                    ),
                  ),
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: backgroundThumbnail(getURL(files[2].data!), 2),
                    ),
                  ),
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Stack(
                        children: [
                          backgroundThumbnail(getURL(files[3].data!), 3,
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
                              "${files.length - 3}+",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24, // Adjust the font size as needed
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
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

  Widget _buildMediaGrid(List<AmityPost> files) {
    if (files.isEmpty) return Container();

    Widget backgroundImage(String fileUrl, int index,
        {BorderRadius? borderRadius}) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ImageViewerScreen(files: files),
            ),
          );
        },
        child: Padding(
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

    switch (files.length) {
      case 1:
        return AspectRatio(
          aspectRatio: 1,
          child: backgroundImage(getURL(files[0].data!), 0,
              borderRadius: BorderRadius.circular(8)),
        );

      case 2:
        return AspectRatio(
          aspectRatio: 1,
          child: Row(children: [
            Expanded(
                child: backgroundImage(getURL(files[0].data!), 0,
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        bottomLeft: Radius.circular(8)))),
            Expanded(
                child: backgroundImage(getURL(files[1].data!), 1,
                    borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomRight: Radius.circular(8))))
          ]),
        );

      case 3:
        return AspectRatio(
          aspectRatio: 1,
          child: Column(
            children: [
              Expanded(
                  child: backgroundImage(getURL(files[0].data!), 0,
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8)))),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                        child: backgroundImage(getURL(files[1].data!), 1,
                            borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(8)))),
                    Expanded(
                        child: backgroundImage(getURL(files[2].data!), 2,
                            borderRadius: const BorderRadius.only(
                                bottomRight: Radius.circular(8)))),
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
                  child: backgroundImage(getURL(files[0].data!), 0,
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8)))),
              Row(
                children: [
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: backgroundImage(getURL(files[1].data!), 1,
                          borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(8))),
                    ),
                  ),
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: backgroundImage(getURL(files[2].data!), 2),
                    ),
                  ),
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: backgroundImage(getURL(files[3].data!), 3,
                          borderRadius: const BorderRadius.only(
                              bottomRight: Radius.circular(8))),
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
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                  8.0), // Border radius for the entire grid
              // Add other properties like a border or shadow if needed
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Expanded(
                    child: backgroundImage(getURL(files[0].data!), 0,
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8)))),
                Row(
                  children: [
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: backgroundImage(getURL(files[1].data!), 1,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(8),
                            )),
                      ),
                    ),
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: backgroundImage(getURL(files[2].data!), 2),
                      ),
                    ),
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Stack(
                          children: [
                            backgroundImage(getURL(files[3].data!), 3,
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
                                "${files.length - 3}+",
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
                  ],
                ),
              ],
            ),
          ),
        );
    }
  }
}

String _getFileImage(String filePath) {
  String extension = filePath.split('.').last;
  switch (extension) {
    case 'audio':
      return 'assets/images/fileType/audio_small.png';
    case 'avi':
      return 'assets/images/fileType/avi_large.png';
    case 'csv':
      return 'assets/images/fileType/csv_large.png';
    case 'doc':
      return 'assets/images/fileType/doc_large.png';
    case 'exe':
      return 'assets/images/fileType/exe_large.png';
    case 'html':
      return 'assets/images/fileType/html_large.png';
    case 'img':
      return 'assets/images/fileType/img_large.png';
    case 'mov':
      return 'assets/images/fileType/mov_large.png';
    case 'mp3':
      return 'assets/images/fileType/mp3_large.png';
    case 'mp4':
      return 'assets/images/fileType/mp4_large.png';
    case 'pdf':
      return 'assets/images/fileType/pdf_large.png';
    case 'ppx':
      return 'assets/images/fileType/ppx_large.png';
    case 'rar':
      return 'assets/images/fileType/rar_large.png';
    case 'txt':
      return 'assets/images/fileType/txt_large.png';
    case 'xls':
      return 'assets/images/fileType/xls_large.png';
    case 'zip':
      return 'assets/images/fileType/zip_large.png';
    default:
      return 'assets/images/fileType/default.png';
  }
}

Widget _listMediaGrid(List<AmityPost> files) {
  return ListView.builder(
    padding: EdgeInsets.zero,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: files.length,
    shrinkWrap: true,
    itemBuilder: (context, index) {
      String fileImage = _getFileImage(files[index].data!.fileInfo.fileName!);

      return Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(4.0),
          border: Border.all(
            color: const Color(0xffEBECEF),
            width: 1.0,
          ),
        ),
        margin: const EdgeInsets.all(8.0),
        child: Stack(
          children: [
            ListTile(
              onTap: () {
                _launchUrl(
                  files[index].data!.fileInfo.fileUrl!,
                );
              },
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 8, horizontal: 14), // Reduced padding
              tileColor: Colors.white.withOpacity(0.0),
              leading: Container(
                height: 100, // Reduced height to make it slimmer
                width: 40, // Added width to align the image
                alignment:
                    Alignment.centerLeft, // Center alignment for the image
                child: Image(
                  image: AssetImage(fileImage,
                      package: 'amity_uikit_beta_service'),
                ),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // Reduce extra space
                children: [
                  Text(
                    "${files[index].data!.fileInfo.fileName}",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    '${(files[index].data!.fileInfo.fileSize)} KB',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      );
    },
  );
}

class TextPost extends StatelessWidget {
  final AmityPost post;
  const TextPost({Key? key, required this.post}) : super(key: key);

  Widget buildURLWidget(String text) {
    return LinkWell(text);
  }

  @override
  Widget build(BuildContext context) {
    final textdata = post.data as TextData;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Wrap(
                alignment: WrapAlignment.start,
                children: [
                  GestureDetector(
                      onTap: () {
                        // Navigator.of(context).push(MaterialPageRoute(
                        //     builder: (context) => CommentScreen(
                        //           amityPost: post,
                        //           theme: Theme.of(context),
                        //           isFromFeed: true,
                        //           onSharePost: (post) {},
                        //         )));
                      },
                      child: post.type == AmityDataType.TEXT
                          ? textdata.text == null
                              ? const SizedBox()
                              : textdata.text!.isEmpty
                                  ? const SizedBox()
                                  : Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 16),
                                      child: Container(
                                        child: buildURLWidget(
                                            textdata.text.toString()),
                                      )
                                      // Text(
                                      //   textdata.text.toString(),
                                      //   style:
                                      //       const TextStyle(fontSize: 18),
                                      // ),
                                      )
                          : Container()),
                ],
              ),
            )
          ],
        ),
      ],
    );
  }
}

class ImagePost extends StatelessWidget {
  final List<AmityPost> posts;
  final List<String> imageURLs;
  final bool isCornerRadiusEnabled;
  const ImagePost(
      {Key? key,
      required this.posts,
      required this.imageURLs,
      required this.isCornerRadiusEnabled})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 250.0,
        disableCenter: false,
        enableInfiniteScroll: imageURLs.length > 1,
        viewportFraction: imageURLs.length > 1 ? 0.9 : 1.0,
      ),
      items: imageURLs.map((url) {
        return Builder(
          builder: (BuildContext context) {
            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(_goToImageViewer(url));
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.symmetric(
                    horizontal: imageURLs.length > 1 ? 5.0 : 0.0),
                decoration: const BoxDecoration(color: Colors.transparent),
                child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(isCornerRadiusEnabled ? 10 : 0),
                    child: FadeInImage(
                      image: NetworkImage(url),
                      fit: BoxFit.cover,
                      placeholder: const AssetImage(
                          'assets/images/placeholder.png'), // Local asset for placeholder
                    )),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Route _goToImageViewer(String url) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => ImageViewer(
          imageURLs: imageURLs, initialIndex: imageURLs.indexOf(url)),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}

Future<Uint8List?> downloadFile(String url) async {
  try {
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      log('Failed to download file: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    log('Error occurred while downloading file: $e');
    return null;
  }
}

Future<void> _launchUrl(String url) async {
  if (!await launchUrl(Uri.parse(url))) {
    throw Exception('Could not launch $url');
  }
}
