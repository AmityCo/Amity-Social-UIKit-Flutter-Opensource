import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/components/theme_config.dart';
import 'package:flutter/material.dart';

class ImageViewerScreen extends StatefulWidget {
  final List<AmityPost> files;
  final int initialIndex;

  const ImageViewerScreen(
      {Key? key, required this.files, required this.initialIndex})
      : super(key: key);

  @override
  _ImageViewerScreenState createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
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
    return ThemeConfig(
      child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            title: Text(
              '${_currentIndex + 1}/${widget.files.length}',
              style: const TextStyle(color: Colors.white),
            ),
            leading: IconButton(
              icon: const Icon(Icons.close),
              color: Colors.white,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: PageView.builder(
            controller: PageController(initialPage: widget.initialIndex),
            itemCount: widget.files.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              var imageData = widget.files[index].data as ImageData;
              return GestureDetector(
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
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
                ),
              );
            },
          )),
    );
  }
}
