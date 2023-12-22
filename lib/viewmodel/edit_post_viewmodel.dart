import 'dart:developer';

import 'package:amity_sdk/amity_sdk.dart';

import '../utils/env_manager.dart';
import 'create_post_viewmodel.dart';

class EditPostVM extends CreatePostVM {
  List<String> imageUrlList = [];
  String? videoUrl;

  void initForEditPost(AmityPost post) {
    textEditingController.clear();
    imageUrlList.clear();
    videoUrl = null;

    var textdata = post.data as TextData;
    textEditingController.text = textdata.text!;
    var children = post.children;
    if (children != null) {
      if (children[0].data is ImageData) {
        imageUrlList = [];
        for (var child in children) {
          var imageData = child.data as ImageData;
          imageUrlList.add(imageData.fileInfo.fileUrl!);
        }

        log("ImageData: $imageUrlList");
      } else if (children[0].data is VideoData) {
        var videoData = children[0].data as VideoData;

        videoUrl =
            "https://api.${env!.region}.amity.co/api/v3/files/${videoData.fileId}/download?size=full";
        log("VideoPost: $videoUrl");
      }
    }
  }

  @override
  void deleteImageAt({required int index}) {
    imageUrlList.removeAt(index);
    notifyListeners();
  }

  @override
  bool isNotSelectedImageYet() {
    if (imageUrlList.isEmpty) {
      return true;
    } else {
      return false;
    }
  }

  @override
  bool isNotSelectVideoYet() {
    if (amityVideo == null) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> editPost() async {}
}
