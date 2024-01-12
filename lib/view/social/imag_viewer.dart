import 'package:amity_sdk/amity_sdk.dart';
import 'package:flutter/material.dart';

class ImageViewerScreen extends StatefulWidget {
  final List<AmityPost> files;

  const ImageViewerScreen({Key? key, required this.files}) : super(key: key);

  @override
  _ImageViewerScreenState createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text('${_currentIndex + 1}/${widget.files.length}'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: PageView.builder(
          controller: _pageController,
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
        ));
  }
}
