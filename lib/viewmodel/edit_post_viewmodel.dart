import 'dart:developer';
import 'dart:io';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/components/alert_dialog.dart';
import 'package:amity_uikit_beta_service/viewmodel/create_postV2_viewmodel.dart';
import 'package:flutter/material.dart';

class EditPostVM extends CreatePostVMV2 {
  List<UIKitFileSystem> editPostMedie = [];
  AmityPost? amityPost;
  void initForEditPost(AmityPost post) {
    amityPost = post;
    textEditingController.clear();
    editPostMedie.clear();

    var textdata = post.data as TextData;
    textEditingController.text = textdata.text!;
    var children = post.children;
    if (children != null) {
      print(children.length);
      print(children[0].type);
      if (children[0].type == AmityDataType.IMAGE) {
        print(children[0].data!.fileId);
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
      }
    }
    print((post.data as TextData).text!);
    textEditingController.text = (post.data as TextData).text!;
  }

  Future<void> editPost(
      {required BuildContext context, Function? callback}) async {
    amityPost!
        .edit()
        .text(textEditingController.text)
        .build()
        .update()
        .then((value) {
      notifyListeners();
      callback!();
    }).onError((error, stackTrace) async {
      await AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
    });
  }
}
