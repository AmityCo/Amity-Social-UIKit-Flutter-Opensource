import 'package:carousel_slider/carousel_slider.dart';
// import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

class ImageViewer extends StatelessWidget {
  final List<String> imageURLs;
  final int initialIndex;
  const ImageViewer(
      {Key? key, required this.imageURLs, required this.initialIndex})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Colors.black,
        child: Stack(
          children: [
            CarouselSlider(
              options: CarouselOptions(
                height: MediaQuery.of(context).size.height,
                disableCenter: true,
                initialPage: initialIndex,
                enableInfiniteScroll: imageURLs.length > 1,
                viewportFraction: 1.0,
              ),
              items: imageURLs.map((url) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container();
                    // return Container(
                    //     width: MediaQuery.of(context).size.width,
                    //     decoration:
                    //         const BoxDecoration(color: Colors.transparent),
                    //     child: ExtendedImage.network(
                    //       url,
                    //       cache: true,
                    //       fit: BoxFit.cover,
                    //       enableLoadState: true,
                    //       loadStateChanged: (ExtendedImageState state) {
                    //         if (state.extendedImageLoadState ==
                    //             LoadState.loading) {
                    //           return const Center(
                    //               child: CircularProgressIndicator());
                    //         } else if (state.extendedImageLoadState ==
                    //             LoadState.completed) {
                    //           return ExtendedRawImage(
                    //             fit: BoxFit.fitWidth,
                    //             image: state.extendedImageInfo?.image,
                    //             width: state.extendedImageInfo?.image.width
                    //                 .toDouble(),
                    //             height: state.extendedImageInfo?.image.height
                    //                 .toDouble(),
                    //           );
                    //         } else {
                    //           return const Text("Else STATE MESNT NOT HANDLED");
                    //         }
                    //       },
                    //       mode: ExtendedImageMode.gesture,
                    //       initGestureConfigHandler: (state) {
                    //         return GestureConfig(
                    //           minScale: 0.9,
                    //           animationMinScale: 0.7,
                    //           maxScale: 3.0,
                    //           animationMaxScale: 3.5,
                    //           speed: 1.0,
                    //           inertialSpeed: 100.0,
                    //           initialScale: 1.0,
                    //           inPageView: false,
                    //           initialAlignment: InitialAlignment.center,
                    //         );
                    //       },
                    //     ));
                  },
                );
              }).toList(),
            ),
            Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: const Icon(Icons.close_rounded,
                      size: 30, color: Colors.white),
                )),
          ],
        ),
      ),
    );
  }
}
