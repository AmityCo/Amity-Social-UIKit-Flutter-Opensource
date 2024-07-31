import 'dart:developer';
import 'dart:io';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/components/alert_dialog.dart';
import 'package:amity_uikit_beta_service/viewmodel/create_postV2_viewmodel.dart';
import 'package:flutter/material.dart';

class EditPostVM extends CreatePostVMV2 {
  List<UIKitFileSystem> editPostMedie = [];
  AmityPost? amityPost;
  int originalPostLength = 0;
  AmityDataType? postDataForEditMedie;
  void initForEditPost(AmityPost post) {
    print("initForEditPost");
    amityPost = post;
    if (amityPost!.children != null) {
      originalPostLength = amityPost!.children!.length;
      if (amityPost!.children!.isNotEmpty) {
        postDataForEditMedie = amityPost!.children![0].type;
      }
    }

    textEditingController.clear();
    editPostMedie.clear();

    var textdata = post.data as TextData;
    textEditingController.text = textdata.text ?? "";
    var children = post.children;
    if (children != null) {
      print(children.length);
      print(children[0].type);
      if (children[0].type == AmityDataType.IMAGE) {
        print(children[0].data!.fileId);
        editPostMedie = [];
        for (var child in children) {
          var uikitFile = UIKitFileSystem(
              postDataForEditMedie: child.data,
              status: FileStatus.complete,
              fileType: MyFileType.image,
              file: File(""));
          editPostMedie.add(uikitFile);
        }

        log("ImageData: $editPostMedie");
      } else if (children[0].type == AmityDataType.VIDEO) {
        var videoData = children[0].data as VideoData;

        editPostMedie = [];
        for (var child in children) {
          var uikitFile = UIKitFileSystem(
              postDataForEditMedie: child.data,
              status: FileStatus.complete,
              fileType: MyFileType.image,
              file: File(""));
          editPostMedie.add(uikitFile);
        }
      } else if (children[0].type == AmityDataType.FILE) {
        var fileData = children[0].data as FileData;
        var fileName = fileData.fileInfo.fileName!;
        editPostMedie = [];
        for (var child in children) {
          var uikitFile = UIKitFileSystem(
              postDataForEditMedie: child.data,
              status: FileStatus.complete,
              progress: -1,
              fileType: MyFileType.file,
              file: File(fileName));
          editPostMedie.add(uikitFile);
        }
      }
    }

    textEditingController.text = (post.data as TextData).text ?? "";
  }

  Future<void> editPost(
      {required BuildContext context, Function? callback}) async {
    var builder = amityPost!.edit().text(textEditingController.text);

    if (editPostMedie.length != originalPostLength) {
      print("Children Length is not equal");
      if (editPostMedie.isNotEmpty) {
        var childPost = amityPost!.children![0];
        var postType = childPost.type;
        print(postType);
        if (postType == AmityDataType.IMAGE) {
          var children = amityPost!.children;
          var images =
              children!.map((e) => e.data!.fileInfo as AmityImage).toList();
          builder = builder.image(images);
        } else if (postType == AmityDataType.VIDEO) {
          var children = amityPost!.children;
          var videos =
              children!.map((e) => e.data!.fileInfo as AmityVideo).toList();
          builder = builder.video(videos);
        } else if (postType == AmityDataType.FILE) {
          var children = amityPost!.children;
          var files =
              children!.map((e) => e.data!.fileInfo as AmityFile).toList();
          builder = builder.file(files);
        }
      } else {
        print("Empty Children");

        print(postDataForEditMedie);
        if (postDataForEditMedie == AmityDataType.IMAGE) {
          builder = builder.image([]);
        } else if (postDataForEditMedie == AmityDataType.VIDEO) {
          builder = builder.video([]);
        } else if (postDataForEditMedie == AmityDataType.FILE) {
          builder = builder.file([]);
        }
      }
    }
    builder.build().update().then((value) {
      notifyListeners();
      callback!();
    }).onError((error, stackTrace) async {
      await AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
    });
  }

  void deselectFileAt(int index) {
    editPostMedie.removeAt(index);
    amityPost!.children!.removeAt(index);
    notifyListeners();
  }
}
