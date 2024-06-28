import 'package:amity_sdk/amity_sdk.dart';
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
  final TransformationController _transformationController =
      TransformationController();
  final double _baseScale = 1.0;
  final double _maxScale = 3.0;
  ValueNotifier<bool> isZoomed = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _transformationController.addListener(() {
      var scale = _transformationController.value.getMaxScaleOnAxis();
      isZoomed.value = scale > _baseScale;
    });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    isZoomed.dispose();
    super.dispose();
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    final position = details.localPosition;
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localPosition = box.globalToLocal(position);
    final size = box.size;
    final scale = _transformationController.value.getMaxScaleOnAxis();

    if (scale > _baseScale) {
      // If already zoomed in, double tapping will zoom out
      _transformationController.value = Matrix4.identity();
    } else {
      // Zoom in
      _transformationController.value = Matrix4.identity()
        ..translate(-localPosition.dx * (_maxScale - 1),
            -localPosition.dy * (_maxScale - 1))
        ..scale(_maxScale);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: ValueListenableBuilder<bool>(
        valueListenable: isZoomed,
        builder: (context, isZoomedIn, child) {
          return GestureDetector(
            onDoubleTapDown: _handleDoubleTapDown,
            child: PageView.builder(
              physics: isZoomedIn
                  ? const NeverScrollableScrollPhysics()
                  : const AlwaysScrollableScrollPhysics(),
              controller: PageController(initialPage: widget.initialIndex),
              itemCount: widget.files.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                var imageData = widget.files[index].data as ImageData;
                return Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: InteractiveViewer(
                    transformationController: _transformationController,
                    minScale: 1,
                    maxScale: _maxScale,
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(
                              imageData.image!.getUrl(AmityImageSize.LARGE)),
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
