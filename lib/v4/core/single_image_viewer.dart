import 'package:amity_sdk/amity_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SingleImagePostViewer extends StatelessWidget {
  final AmityPost post;

  const SingleImagePostViewer({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageUrl = (post.data as ImageData).getUrl(AmityImageSize.FULL);

    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: Container(
              padding: const EdgeInsets.only(left: 16),
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
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(imageUrl),
              fit: BoxFit.fitWidth,
            ),
          ),
        ));
  }
}
