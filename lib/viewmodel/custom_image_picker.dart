import 'dart:developer';
import 'dart:io';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../components/alert_dialog.dart';

enum ImageState { noImage, loading, hasImage }

class ImagePickerVM extends ChangeNotifier {
  final ImagePicker _picker = ImagePicker();
  AmityFileInfo? amityImage;
  ImageState imageState = ImageState.loading;

  void init(String? imageurl) {
    amityImage = null;
    checkUserImage(imageurl);
  }

  checkUserImage(String? url) {
    if (url != null && url != "" && url != "null") {
      imageState = ImageState.hasImage;
      log("has image:$url");
    } else {
      imageState = ImageState.noImage;
      log("no image");
    }
  }

  void showBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          // <-- SEE HERE
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(25.0),
          ),
        ),
        builder: (context) {
          return SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(
                  height: 10,
                ),
                ListTile(
                    leading: const Icon(Icons.photo),
                    title: const Text('Gallery'),
                    onTap: () async {
                      Navigator.pop(context);
                      final XFile? image =
                          await _picker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        AmityCoreClient.newFileRepository()
                            .uploadImage(File(image.path))
                            .stream
                            .listen((amityUploadResult) {
                          amityUploadResult.when(
                            progress: (uploadInfo, cancelToken) {
                              imageState = ImageState.loading;
                              notifyListeners();
                              int progress = uploadInfo.getProgressPercentage();
                              log(progress.toString());
                            },
                            complete: (file) {
                              //check if the upload result is complete
                              log("complete");
                              AmityLoadingDialog.hideLoadingDialog();
                              final AmityImage uploadedImage = file;
                              amityImage = uploadedImage;
                              //proceed result with uploadedImage

                              log("check amity image ${amityImage!.fileId}");
                              imageState = ImageState.hasImage;
                              notifyListeners();
                            },
                            error: (error) async {
                              log("error: $error");
                              await AmityDialog().showAlertErrorDialog(
                                  title: "Error!", message: error.toString());
                              imageState = ImageState.hasImage;
                              notifyListeners();
                            },
                            cancel: () {
                              //upload is cancelled
                            },
                          );
                        });
                      }
                    }),
                const Divider(
                  color: Colors.grey,
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Camera'),
                  onTap: () async {
                    Navigator.pop(context);
                    final XFile? image =
                        await _picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      imageState = ImageState.loading;
                      notifyListeners();
                      await AmityCoreClient.newFileRepository()
                          .uploadImage(File(image.path))
                          .done
                          .then((value) {
                        var fileInfo = value as AmityUploadComplete;

                        amityImage = fileInfo.getFile;
                        imageState = ImageState.hasImage;
                        notifyListeners();
                        Navigator.pop(context);
                      }).onError((error, stackTrace) async {
                        log("error: $error");
                        await AmityDialog().showAlertErrorDialog(
                            title: "Error!", message: error.toString());
                        imageState = ImageState.hasImage;
                        notifyListeners();
                      });
                    }
                  },
                ),
              ],
            ),
          );
        });
  }
}
