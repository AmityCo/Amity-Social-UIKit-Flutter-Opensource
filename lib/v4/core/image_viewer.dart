import 'package:amity_sdk/amity_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ImagePostViewer extends StatefulWidget {
  final List<AmityPost> posts;
  final int initialIndex;

  const ImagePostViewer(
      {Key? key, required this.posts, required this.initialIndex})
      : super(key: key);

  static Route<void> route(
      {required List<AmityPost> posts, required int initialIndex}) {
    return PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.transparent,
      pageBuilder: (context, _, __) =>
          ImagePostViewer(posts: posts, initialIndex: initialIndex),
      transitionsBuilder: (context, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
    );
  }

  @override
  _ImagePostViewerState createState() => _ImagePostViewerState();
}

class _ImagePostViewerState extends State<ImagePostViewer>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isZoomed = false;
  final Map<int, TransformationController> _transformControllers = {};

  double _dragOffset = 0.0;
  late AnimationController _springController;
  Animation<double>? _springAnimation;

  static const double _dismissThreshold = 150.0;
  static const double _dismissVelocityThreshold = 500.0;

  TransformationController _controllerFor(int index) {
    return _transformControllers.putIfAbsent(index, () {
      final controller = TransformationController();
      controller.addListener(() {
        final scale = controller.value.getMaxScaleOnAxis();
        final zoomed = scale > 1.01;
        if (zoomed != _isZoomed) {
          setState(() => _isZoomed = zoomed);
        }
      });
      return controller;
    });
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _springController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _springController.addListener(() {
      if (mounted && _springAnimation != null) {
        setState(() => _dragOffset = _springAnimation!.value);
      }
    });
  }

  @override
  void dispose() {
    for (final c in _transformControllers.values) {
      c.dispose();
    }
    _springController.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    final newOffset =
        (_dragOffset + details.delta.dy).clamp(0.0, double.infinity);
    setState(() => _dragOffset = newOffset);
  }

  void _onDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0.0;
    if (_dragOffset > _dismissThreshold ||
        velocity > _dismissVelocityThreshold) {
      Navigator.of(context).pop();
    } else {
      _springBack();
    }
  }

  void _springBack() {
    _springAnimation = Tween<double>(begin: _dragOffset, end: 0.0).animate(
      CurvedAnimation(parent: _springController, curve: Curves.easeOutBack),
    );
    _springController
      ..reset()
      ..forward();
  }

  double get _backgroundOpacity =>
      (1.0 - (_dragOffset / 300.0)).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onVerticalDragUpdate: _isZoomed ? null : _onDragUpdate,
        onVerticalDragEnd: _isZoomed ? null : _onDragEnd,
        child: Stack(
          children: [
            // Fading black background — reveals content behind as user drags
            Positioned.fill(
              child: ColoredBox(
                color: Colors.black.withOpacity(_backgroundOpacity),
              ),
            ),

            // Image content that translates downward on drag
            Transform.translate(
              offset: Offset(0, _dragOffset),
              child: PageView.builder(
                physics: _isZoomed
                    ? const NeverScrollableScrollPhysics()
                    : const PageScrollPhysics(),
                controller: PageController(initialPage: widget.initialIndex),
                itemCount: widget.posts.length,
                onPageChanged: (index) {
                  _transformControllers[_currentIndex]?.value =
                      Matrix4.identity();
                  setState(() {
                    _currentIndex = index;
                    _isZoomed = false;
                  });
                },
                itemBuilder: (context, index) {
                  var imageData = widget.posts[index].data as ImageData;
                  return InteractiveViewer(
                    transformationController: _controllerFor(index),
                    panEnabled: _isZoomed,
                    minScale: 1.0,
                    maxScale: 4.0,
                    child: SizedBox.expand(
                      child: Image.network(
                        imageData.image!.getUrl(AmityImageSize.LARGE),
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.broken_image,
                              color: Colors.white54,
                              size: 64,
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),

            // Top bar fades with the background as user drags
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Opacity(
                opacity: _backgroundOpacity,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.black.withOpacity(0.0),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 96),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: IconButton(
                              icon: SvgPicture.asset(
                                'assets/Icons/amity_ic_close_viewer.svg',
                                package: 'amity_uikit_beta_service',
                                width: 32,
                                height: 32,
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: widget.posts.length > 1
                                  ? Text(
                                      '${_currentIndex + 1}/${widget.posts.length}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ),
                          const SizedBox(width: 64),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
