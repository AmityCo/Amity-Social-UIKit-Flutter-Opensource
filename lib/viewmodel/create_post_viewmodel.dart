import 'dart:async';
import 'dart:io';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/utils/navigation_key.dart';
import 'package:amity_uikit_beta_service/viewmodel/media_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../components/alert_dialog.dart';
import 'community_feed_viewmodel.dart';
import 'feed_viewmodel.dart';

class AmityFileInfoWithUploadStatus {
  AmityFileInfo? fileInfo;
  bool isComplete = false;
  File? file;

  void addFile(AmityFileInfo amityFileInfo, File file) {
    fileInfo = amityFileInfo;
    isComplete = false;
    this.file = file;
  }
}

class CreatePostVM extends ChangeNotifier {
  final TextEditingController textEditingController =
      TextEditingController(text: "");
  final ImagePicker _picker = ImagePicker();
  List<AmityFileInfoWithUploadStatus> amityUploadFile =
      <AmityFileInfoWithUploadStatus>[];
  AmityFileInfoWithUploadStatus? amityVideo;
  bool isloading = false;
  void inits() {
    _progressMap.clear();
    textEditingController.clear();
    amityVideo = null;
    amityUploadFile.clear();
  }

  bool isNotSelectedImageYet() {
    for (var file in amityUploadFile) {
      if (file.fileInfo!.getFileProperties?.type == "image") {
        return false; // At least one image file is selected
      }
    }
    return true; // No image file is selected
  }

  void deleteAmityFile(int index) {
    if (index >= 0 && index < amityUploadFile.length) {
      // Get the file path from the item at the specified index
      String filePath = amityUploadFile[index].file?.path ?? "";

      // Remove the item from the amityUploadFile list
      amityUploadFile.removeAt(index);

      // Remove the corresponding entries from the maps
      _progressMap.remove(filePath);
      _completeMap.remove(filePath);
      checkAreAllPathsComplete();
      // Notify listeners about the changes
      notifyListeners();
    }
  }

// Declare the map outside the function
  Map<String, Uint8List> thumbnailCache = {};

  Future<ImageProvider> getImageProvider(String path) async {
    if (path.endsWith('.mp4') || path.endsWith('.MOV')) {
      // Check if the thumbnail data for this path is already available in the map
      if (thumbnailCache.containsKey(path)) {
        return MemoryImage(thumbnailCache[path]!);
      }

      final uint8list = await VideoThumbnail.thumbnailData(
        video: path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 1000,
        maxHeight: 1000,
        quality: 0,
      );

      if (uint8list != null && uint8list.isNotEmpty) {
        // Save the generated thumbnail data in the map
        thumbnailCache[path] = uint8list;
        return MemoryImage(uint8list);
      } else {
        throw Exception('Failed to generate video thumbnail');
      }
    } else {
      return FileImage(File(path));
    }
  }

  final Map<String, int> _progressMap = {};
  final Map<String, bool> _completeMap = {};

  bool areAllFilesComplete = true;
  void checkAreAllPathsComplete() {
    var files = Provider.of<MediaPickerVM>(
            NavigationService.navigatorKey.currentContext!,
            listen: false)
        .selectedFiles;

    // Start with the assumption that all files are complete
    areAllFilesComplete = true;

    for (var file in files) {
      var path = file.path;
      // Check if the path is in the map and if it is marked as complete
      if (!_completeMap.containsKey(path) || !_completeMap[path]!) {
        areAllFilesComplete =
            false; // Found an incomplete file, set to false and break
        break;
      }
    }
  }

  int? getProgress(String filePath) {
    return _progressMap[filePath];
  }

  bool? getCompletionStatus(String filePath) {
    return _completeMap[filePath];
  }

  void setProgress(String filePath, int progress) {
    _progressMap[filePath] = progress;
  }

  void setCompletionStatus(String filePath, bool isComplete) {
    _completeMap[filePath] = isComplete;
  }

  void setfailUpload(String filePath) {
    _progressMap.remove(filePath);
    _completeMap.remove(filePath);
  }

  bool isNotSelectVideoYet() {
    for (var file in amityUploadFile) {
      if (file.fileInfo!.getFileProperties?.type == "video") {
        return false; // At least one image file is selected
      }
    }
    return true; // No image file is selected
  }

  bool isNotSelectedFileYet() {
    for (var file in amityUploadFile) {
      if (file.fileInfo!.getFileProperties?.type != "image" &&
          file.fileInfo!.getFileProperties?.type != "video") {
        return false; // At least one non-image and non-video file is selected
      }
    }
    return true; // No non-image and non-video file is selected
  }

  Future<void> uploadFile(File file,
      {required Function onSuccess, required Function(String) onError}) async {
    // Determine the MIME type of the file
    final mimeType = lookupMimeType(file.path);

    if (mimeType != null) {
      try {
        if (mimeType.startsWith('image')) {
          var client = AmityCoreClient.newFileRepository().uploadImage(file);
          await _performUpload(client, file, onSuccess, onError);
        } else if (mimeType.startsWith('video')) {
          var client = AmityCoreClient.newFileRepository().uploadVideo(file);
          await _performUpload(client, file, onSuccess, onError);
        } else if (mimeType.startsWith('audio')) {
          onError("Audio upload not implemented yet");
        } else {
          var client = AmityCoreClient.newFileRepository().uploadFile(file);
          await _performUpload(client, file, onSuccess, onError);
        }
      } catch (e) {
        onError(e.toString());
      }
    } else {
      onError('Unsupported file type');
    }
  }

  Future<void> _performUpload(
    StreamController<AmityUploadResult<dynamic>> client,
    File file,
    Function onSuccess,
    Function(String) onError,
  ) {
    setProgress(file.path, 1);
    final completer = Completer<void>();

    client.stream.listen(
      (amityUploadResult) {
        amityUploadResult.when(
          progress: (uploadInfo, cancelToken) {
            int progress = uploadInfo.getProgressPercentage();

            if (progress < 100) {
              setProgress(file.path, progress);
              setCompletionStatus(file.path, false);
              checkAreAllPathsComplete();
              notifyListeners();
            }
          },
          complete: (amityFile) {
            var uploadedImage = amityFile;
            amityUploadFile.add(
                AmityFileInfoWithUploadStatus()..addFile(uploadedImage, file));
            setProgress(file.path, 100); // Set progress to 100%
            setCompletionStatus(file.path, true);
            checkAreAllPathsComplete();
            notifyListeners();
            onSuccess(); // Invoke the success callback
            completer.complete(); // Mark the completer as complete
          },
          error: (error) async {
            // setProgress(file.path, -100);
            setfailUpload(file.path);
            await AmityDialog().showAlertErrorDialog(
              title: "Amity Error!",
              message: error.toString(),
            );

            notifyListeners();
            onError(error.toString()); // Invoke the error callback
            completer.completeError(error); // Propagate the error
          },
          cancel: () {
            checkAreAllPathsComplete();
            notifyListeners();
            onError('Upload cancelled'); // Invoke the error callback
            completer.completeError(
                Exception('Upload cancelled')); // Propagate the error
          },
        );
      },
    );

    return completer.future; // Return the future from the completer
  }

// List to store already selected image paths
  List<String> selectedImagePaths = [];
  Future<void> addFiles() async {
    if (isNotSelectVideoYet()) {
      final List<XFile> images =
          await _picker.pickMultiImage(imageQuality: 100);
      for (var image in images) {
        // Check if the image is already in the list of selected images
        if (_progressMap[image.path] == null) {
          await uploadFile(File(image.path),
              onSuccess: () {}, onError: (String) {});
          // Add the image path to the list after successful upload
        }
      }
    }
  }

  Future<void> addFileFromCamera() async {
    if (isNotSelectVideoYet()) {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        var fileWithStatus = AmityFileInfoWithUploadStatus();
        amityUploadFile.add(fileWithStatus);
        notifyListeners();
        await AmityCoreClient.newFileRepository()
            .uploadImage(File(image.path))
            .done
            .then((value) {
          var fileInfo = value as AmityUploadComplete;

          amityUploadFile.last.addFile(fileInfo.getFile, File(image.path));
          notifyListeners();
        }).onError((error, stackTrace) async {
          await AmityDialog()
              .showAlertErrorDialog(title: "Error!", message: error.toString());
        });
      }
    }
  }

  Future<void> addVideo() async {
    if (isNotSelectedImageYet()) {
      try {
        final XFile? video =
            await _picker.pickVideo(source: ImageSource.gallery);

        if (video != null) {
          // var fileWithStatus = AmityFileInfoWithUploadStatus();
          // amityVideo = fileWithStatus;
          // amityVideo!.file = File(video.path);

          // notifyListeners();
          // await AmityCoreClient.newFileRepository()
          //     .uploadImage(File(video.path))
          //     .done
          //     .then((value) {
          //   var fileInfo = value as AmityUploadComplete;

          //   amityVideo!.addFile(fileInfo.getFile);
          //   log(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>${fileInfo.getFile.fileId}");

          //   notifyListeners();
          // }).onError((error, stackTrace) async {
          //   log("error: $error");
          //   await AmityDialog()
          //       .showAlertErrorDialog(title: "Error!", message: error.toString());
          // });
        } else {
          // await AmityDialog().showAlertErrorDialog(
          //     title: "Error!", message: "error: video is null");
        }
      } catch (error) {
        await AmityDialog()
            .showAlertErrorDialog(title: "Error!", message: error.toString());
      }
    }
  }

  void deleteImageAt({required int index}) {
    amityUploadFile.removeAt(index);
    notifyListeners();
  }

  Future<void> createPost(BuildContext context,
      {String? communityId, required Function(bool, String?) callback}) async {
    isloading = true;
    notifyListeners();
    HapticFeedback.heavyImpact();
    bool isCommunity = (communityId != null) ? true : false;

    if (isCommunity) {
      if (isNotSelectVideoYet() &&
          isNotSelectedImageYet() &&
          isNotSelectedFileYet()) {
        // Create text post
        await createTextpost(context, communityId: communityId);
        callback(true, null);
      } else if (isNotSelectedImageYet() && isNotSelectedFileYet()) {
        // Create video post
        await creatVideoPost(context, communityId: communityId);
        callback(true, null);
      } else if (isNotSelectVideoYet() && isNotSelectedFileYet()) {
        // Create image post
        await creatImagePost(context, communityId: communityId);
        callback(true, null);
      } else if (isNotSelectVideoYet() && isNotSelectedImageYet()) {
        // Assuming createFilePost handles file selection internally
        await createFilePost(context, communityId: communityId);
        callback(true, null);
      }
    } else {
      if (isNotSelectVideoYet() &&
          isNotSelectedImageYet() &&
          isNotSelectedFileYet()) {
        // Create text post
        await createTextpost(context);
        callback(true, null);
      } else if (isNotSelectedImageYet() && isNotSelectedFileYet()) {
        // Create video post
        await creatVideoPost(context);
        callback(true, null);
      } else if (isNotSelectVideoYet() && isNotSelectedFileYet()) {
        // Create image post
        await creatImagePost(context);
        callback(true, null);
      } else if (isNotSelectVideoYet() && isNotSelectedImageYet()) {
        // Assuming createFilePost handles file selection internally
        await createFilePost(context);
        callback(true, null);
      }
    }
  }

  Future<void> createTextpost(BuildContext context,
      {String? communityId}) async {
    bool isCommunity = (communityId != null) ? true : false;
    if (isCommunity) {
      await AmitySocialClient.newPostRepository()
          .createPost()
          .targetCommunity(communityId)
          .text(textEditingController.text)
          .post()
          .then((AmityPost post) {
        ///add post to feed
        // var viewModel = Provider.of<CommuFeedVM>(context, listen: false);
        // viewModel.addPostToFeed(post);
        // if (viewModel.scrollcontroller.hasClients) {
        //   viewModel.scrollcontroller.jumpTo(0);
        // }
      }).onError((error, stackTrace) async {
        await AmityDialog()
            .showAlertErrorDialog(title: "Error!", message: error.toString());
      });
    } else {
      await AmitySocialClient.newPostRepository()
          .createPost()
          .targetMe() // or targetMe(), targetCommunity(communityId: String)
          .text(textEditingController.text)
          .post()
          .then((AmityPost post) {
        ///add post to feed
        if (communityId != null) {
          var viewModel = Provider.of<CommuFeedVM>(context, listen: false);
          viewModel.addPostToFeed(post);
          if (viewModel.scrollcontroller.hasClients) {
            viewModel.scrollcontroller.jumpTo(0);
          }
        } else {
          var viewModel = Provider.of<FeedVM>(context, listen: false);
          viewModel.addPostToFeed(post);
          if (viewModel.scrollcontroller.hasClients) {
            viewModel.scrollcontroller.jumpTo(0);
          }
        }
        notifyListeners();
      }).onError((error, stackTrace) async {
        await AmityDialog()
            .showAlertErrorDialog(title: "Error!", message: error.toString());
      });
    }
  }

  Future<void> createFilePost(BuildContext context,
      {String? communityId}) async {
    bool isCommunity = (communityId != null) ? true : false;
    List<AmityFile> files = [];
    for (var amityFile in amityUploadFile) {
      if (amityFile.fileInfo is AmityFile) {
        var file = amityFile.fileInfo as AmityFile;
        files.add(file);
      }
    }
    if (isCommunity) {
      // Creating a post with a file in a community
      var builder = AmitySocialClient.newPostRepository()
          .createPost()
          .targetCommunity(communityId)
          .file(files);

      if (textEditingController.text.isNotEmpty) {
        builder.text(textEditingController.text);
      }

      builder.post().then((post) async {
        // ///add post to feedx
        // log("success");
        // var viewModel = Provider.of<CommuFeedVM>(context, listen: false);
        // viewModel.addPostToFeed(post);
        // if (viewModel.scrollcontroller.hasClients) {
        //   viewModel.scrollcontroller.jumpTo(0);
        // }
      });
    } else {
      // Creating a post with a file targeted at the user's own feed
      var builder = AmitySocialClient.newPostRepository()
          .createPost()
          .targetMe()
          .file(files);

      if (textEditingController.text.isNotEmpty) {
        builder.text(textEditingController.text);
      }

      builder.post().then((post) async {
        ///add post to feedx
        if (communityId != null) {
          var viewModel = Provider.of<CommuFeedVM>(context, listen: false);
          viewModel.addPostToFeed(post);
          if (viewModel.scrollcontroller.hasClients) {
            viewModel.scrollcontroller.jumpTo(0);
          }
        } else {
          var viewModel = Provider.of<FeedVM>(context, listen: false);
          viewModel.addPostToFeed(post);
          if (viewModel.scrollcontroller.hasClients) {
            viewModel.scrollcontroller.jumpTo(0);
          }
        }
      });
    }

    // Add post to feed logic goes here...
    // You can use similar logic as in createTextpost
    // ...
  }

  Future<void> creatImagePost(BuildContext context,
      {String? communityId}) async {
    List<AmityImage> images = [];
    for (var amityImage in amityUploadFile) {
      if (amityImage.fileInfo is AmityImage) {
        var image = amityImage.fileInfo as AmityImage;
        images.add(image);
      }
    }
    bool isCommunity = (communityId != null) ? true : false;
    if (isCommunity) {
      var builder = AmitySocialClient.newPostRepository()
          .createPost()
          .targetCommunity(communityId)
          .image(images);

      if (textEditingController.text.isNotEmpty) {
        builder.text(textEditingController.text);
      }

      builder.post().then((post) async {
        ///add post to feedx
        var viewModel = Provider.of<CommuFeedVM>(context, listen: false);
        viewModel.addPostToFeed(post);
        if (viewModel.scrollcontroller.hasClients) {
          viewModel.scrollcontroller.jumpTo(0);
        }
      }).onError((error, stackTrace) async {
        await AmityDialog()
            .showAlertErrorDialog(title: "Error!", message: error.toString());
      });
    } else {
      var builder = AmitySocialClient.newPostRepository()
          .createPost()
          .targetMe()
          .image(images);

      if (textEditingController.text.isNotEmpty) {
        builder.text(textEditingController.text);
      }

      builder.post().then((post) async {
        ///add post to feedx
        if (communityId != null) {
          var viewModel = Provider.of<CommuFeedVM>(context, listen: false);
          viewModel.addPostToFeed(post);
          if (viewModel.scrollcontroller.hasClients) {
            viewModel.scrollcontroller.jumpTo(0);
          }
        } else {
          var viewModel = Provider.of<FeedVM>(context, listen: false);
          viewModel.addPostToFeed(post);
          if (viewModel.scrollcontroller.hasClients) {
            viewModel.scrollcontroller.jumpTo(0);
          }
        }
      }).onError((error, stackTrace) async {
        await AmityDialog()
            .showAlertErrorDialog(title: "Error!", message: error.toString());
      });
    }
  }

  Future<void> creatVideoPost(BuildContext context,
      {String? communityId}) async {
    List<AmityVideo> videos = [];
    for (var amityVideo in amityUploadFile) {
      AmityVideo video = amityVideo.fileInfo as AmityVideo;
      videos.add(video);
    }

    if (videos.isNotEmpty) {
      bool isCommunity = (communityId != null) ? true : false;
      if (isCommunity) {
        var builder = AmitySocialClient.newPostRepository()
            .createPost()
            .targetCommunity(communityId)
            .video(videos);

        if (textEditingController.text.isNotEmpty) {
          builder.text(textEditingController.text);
        }

        builder.post().then((post) async {
          ///add post to feedx
          Provider.of<CommuFeedVM>(context, listen: false).addPostToFeed(post);
          Provider.of<CommuFeedVM>(context, listen: false)
              .scrollcontroller
              .jumpTo(0);
        }).onError((error, stackTrace) async {
          await AmityDialog()
              .showAlertErrorDialog(title: "Error!", message: error.toString());
        });
      } else {
        var builder = AmitySocialClient.newPostRepository()
            .createPost()
            .targetMe()
            .video(videos);

        if (textEditingController.text.isNotEmpty) {
          builder.text(textEditingController.text);
        }

        builder.post().then((post) async {
          if (communityId != null) {
            var viewModel = Provider.of<CommuFeedVM>(context, listen: false);
            viewModel.addPostToFeed(post);
            if (viewModel.scrollcontroller.hasClients) {
              viewModel.scrollcontroller.jumpTo(0);
            }
          } else {
            var viewModel = Provider.of<FeedVM>(context, listen: false);
            viewModel.addPostToFeed(post);
            if (viewModel.scrollcontroller.hasClients) {
              viewModel.scrollcontroller.jumpTo(0);
            }
          }
        }).onError((error, stackTrace) async {
          await AmityDialog()
              .showAlertErrorDialog(title: "Error!", message: error.toString());
        });
      }
    }
  }
}
