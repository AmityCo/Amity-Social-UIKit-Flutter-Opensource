import 'package:amity_sdk/amity_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ImagePostViewer extends StatefulWidget {
  final List<AmityPost> posts;
  final int initialIndex;

  const ImagePostViewer(
      {Key? key, required this.posts, required this.initialIndex})
      : super(key: key);

  @override
  _ImagePostViewerState createState() => _ImagePostViewerState();
}

class _ImagePostViewerState extends State<ImagePostViewer> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(
            '${_currentIndex + 1}/${widget.posts.length}',
            style: const TextStyle(color: Colors.white),
          ),
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w400,
          ),
          centerTitle: true,
          leading: Container(
              padding: EdgeInsets.only(left: 16),
              child: IconButton(
                icon: SvgPicture.asset(
                  'assets/Icons/amity_ic_close_viewer.svg',
                  package: 'amity_uikit_beta_service',
                  width: 32,
                  height: 32,
                ),
                color: Colors.white,
                onPressed: () => Navigator.of(context).pop(),
              )),
        ),
        body: PageView.builder(
          controller: PageController(initialPage: widget.initialIndex),
          itemCount: widget.posts.length,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          itemBuilder: (context, index) {
            var imageData = widget.posts[index].data as ImageData;
            return GestureDetector(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                            imageData.image!.getUrl(AmityImageSize.LARGE)),
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ));
  }
}

