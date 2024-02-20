import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/components/alert_dialog.dart';
import 'package:amity_uikit_beta_service/viewmodel/community_feed_viewmodel.dart';
import 'package:amity_uikit_beta_service/viewmodel/feed_viewmodel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

enum FileStatus { uploading, rejected, complete }

enum PickerAction { cameraImage, galleryImage, galleryVideo, filePicker }

enum MyFileType { image, video, file }

class UIKitFileSystem {
  AmityPostData? postDataForEditMedie;
  AmityFileInfo? fileInfo;
  dynamic amityFile;
  FileStatus status;
  int progress;
  MyFileType fileType;
  File file;

  UIKitFileSystem({
    this.fileInfo,
    this.postDataForEditMedie,
    required this.status,
    required this.fileType,
    required this.file,
    this.amityFile,
    this.progress = 0,
  });
}

class CreatePostVMV2 with ChangeNotifier {
  final TextEditingController textEditingController =
      TextEditingController(text: "");
  final ImagePicker _picker = ImagePicker();
  List<UIKitFileSystem> files = [];
  bool isUploadComplete = false;
  MyFileType? selectedFileType;
  bool get isPostValid {
    // Check if there are any files
    bool hasFiles = files.isNotEmpty;

    // Check if the text is empty
    bool isTextEmpty = textEditingController.text.isEmpty;

    // If there are no files and text is empty, return false
    if (!hasFiles && isTextEmpty) {
      return false;
    }

    // If there are files, then validity depends on whether the upload is complete
    // If there are no files, the post is valid regardless of the upload status
    return !hasFiles || isUploadComplete;
  }

  void updatePostValidity() {
    // First, update the upload complete status
    checkAllFilesUploaded();

    // Then, update the isPostValid status

    log("textEditingController: ${textEditingController.text.isNotEmpty}");
    log("isUploadComplete: $isUploadComplete");

    notifyListeners();
  }

  void inits() {
    isUploadComplete = false;
    files.clear();
    textEditingController.clear();
    selectedFileType = null;
  }

  // Function to determine which type of file can be selected
  Map<MyFileType, bool> availableFileSelectionOptions() {
    // If no files have been selected yet, all options are available
    if (files.isEmpty) {
      return {
        MyFileType.image: true,
        MyFileType.video: true,
        MyFileType.file: true
      };
    }

    // If there are files, only allow selecting more of the same type
    Map<MyFileType, bool> selectionOptions = {
      MyFileType.image: false,
      MyFileType.video: false,
      MyFileType.file: false
    };

    // Check the type of the first file (assuming all files are of the same type)
    MyFileType currentType = files.first.fileType ?? MyFileType.file;
    selectionOptions[currentType] = true;

    return selectionOptions;
  }

  // Updated selectFiles method
  Future<void> selectFiles(
      List<XFile> selectedFiles, MyFileType fileType) async {
    // Ensure only one type of file is selected at a time
    if (selectedFileType != null && selectedFileType != fileType) {
      // Handle error: different file type selected
      return;
    }

    selectedFileType = fileType;

    for (var file in selectedFiles) {
      // Add file to the list with status 'uploading'
      var uikitFile = UIKitFileSystem(
          status: FileStatus.uploading,
          fileType: fileType,
          file: File(file.path));
      files.add(uikitFile);
      checkAllFilesUploaded();
      notifyListeners();

      // Start uploading the file
      uploadFile(file, uikitFile);
    }
  }

  Future<void> uploadFile(XFile xFile, UIKitFileSystem uikitFile) async {
    File uploadingFile = File(xFile.path);

    // Determine the MIME type of the file
    final mimeType = lookupMimeType(uploadingFile.path);
    log("uploading...$mimeType");
    if (mimeType != null) {
      try {
        if (mimeType.startsWith('image')) {
          await _performUpload(
            AmityCoreClient.newFileRepository().uploadImage(uploadingFile),
            uikitFile,
          );
        } else if (mimeType.startsWith('video')) {
          log("Generating thumbnail...");
          final Uint8List? uint8list = await VideoThumbnail.thumbnailData(
            video: uploadingFile.path,
            imageFormat: ImageFormat.PNG,
            maxWidth: 1000,
            maxHeight: 1000,
            quality: 75, // Adjusted quality to a non-zero value
          );

          if (uint8list != null && uint8list.isNotEmpty) {
            // Save the generated thumbnail data in the map
            thumbnailCache[uploadingFile.path] = uint8list;
            notifyListeners();
          }
          await _performUpload(
            AmityCoreClient.newFileRepository().uploadVideo(uploadingFile),
            uikitFile,
          );
        } else {
          log("_performUpload file");
          await _performUpload(
            AmityCoreClient.newFileRepository().uploadFile(uploadingFile),
            uikitFile,
          );
        }
      } catch (e) {
        uikitFile.status = FileStatus.rejected;
        notifyListeners();
        // Handle the error as appropriate for your app
      }
    } else {
      uikitFile.status = FileStatus.rejected;
      notifyListeners();
      // Handle unsupported file type
    }
  }

  Future<void> _performUpload(
    StreamController<AmityUploadResult<dynamic>> client,
    UIKitFileSystem uikitFile,
  ) async {
    client.stream.listen(
      (amityUploadResult) {
        amityUploadResult.when(
          progress: (uploadInfo, cancelToken) {
            int progress = uploadInfo.getProgressPercentage();
            uikitFile.progress = progress;
            notifyListeners();
          },
          complete: (amityFile) {
            uikitFile.status = FileStatus.complete;
            uikitFile.fileInfo = amityFile;
            uikitFile.amityFile = amityFile;

            checkAllFilesUploaded();
            notifyListeners();
          },
          error: (error) {
            uikitFile.status = FileStatus.rejected;
            notifyListeners();
            // Handle the error as appropriate for your app
          },
          cancel: () {
            // Handle cancellation
          },
        );
      },
    );
  }

  // Method to select files (e.g., using a file picker)
  Future<void> pickImagesFromCamera() async {
    try {
      XFile? pickedImage = await _picker.pickImage(source: ImageSource.camera);

      if (pickedImage != null) {
        selectFiles([pickedImage], MyFileType.image);
      }
    } catch (e) {
      log("Error picking images: $e");
      // Handle the error as appropriate for your app
    }
  }

  Future<void> pickMultipleImages() async {
    try {
      List<XFile>? pickedImages = await _picker.pickMultiImage();

      if (pickedImages.isNotEmpty) {
        selectFiles(pickedImages, MyFileType.image);
      }
    } catch (e) {
      log("Error picking images: $e");
      // Handle the error as appropriate for your app
    }
  }

  Future<void> pickVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        selectFiles([video], MyFileType.video);
      }
    } catch (e) {
      log("Error picking video: $e");
      // Handle the error as appropriate for your app
    }
  }

  Future<void> pickFile(PickerAction action) async {
    try {
      if (action == PickerAction.cameraImage) {
        XFile? pickedImage =
            await _picker.pickImage(source: ImageSource.camera);
        if (pickedImage != null) {
          selectFiles([pickedImage], MyFileType.image);
        }
      } else if (action == PickerAction.galleryImage) {
        List<XFile>? pickedImages = await _picker.pickMultiImage();
        if (pickedImages.isNotEmpty) {
          selectFiles(pickedImages, MyFileType.image);
        }
      } else if (action == PickerAction.galleryVideo) {
        final XFile? video =
            await _picker.pickVideo(source: ImageSource.gallery);
        if (video != null) {
          selectFiles([video], MyFileType.video);
        }
      } else if (action == PickerAction.filePicker) {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          allowMultiple: true,
          type: FileType.any,
        );
        if (result != null && result.files.isNotEmpty) {
          List<XFile> pickedFiles = result.files
              .where((file) => file.path != null)
              .map((file) => XFile(file.path!))
              .toList();
          selectFiles(pickedFiles, MyFileType.file);
        }
      }
    } catch (e) {
      log("Error during file picking: $e");
      // Handle the error as appropriate for your app
    }
  }

  // Method to check if all files are uploaded
  void checkAllFilesUploaded() {
    isUploadComplete =
        files.every((file) => file.status == FileStatus.complete);
    notifyListeners();
  }

  // Method to deselect a file
  void deselectFile(UIKitFileSystem file) {
    files.remove(file);
    notifyListeners();
  }

  List<File> convertToFileList(List<UIKitFileSystem> uikitFiles) {
    return uikitFiles
        // Ensure that fileInfo is not null and has a valid file path
        .where((uikitFile) => uikitFile.file != null)
        // Map each UIKitFileSystem to a File
        .map((uikitFile) => uikitFile.file)
        .toList();
  }

  Future<void> createPost(BuildContext context,
      {String? communityId,
      required Function(bool success, String? error) callback}) async {
    if (isUploadComplete) {
      log("creating Post...");
      bool isCommunity = communityId != null;

      var targetBuilder = AmitySocialClient.newPostRepository().createPost();

      AmityPostCreateDataTypeSelector? postBuilder;
      if (isCommunity) {
        log("set target as commu...");
        postBuilder = targetBuilder.targetCommunity(communityId);
      } else {
        log("set target as user...");
        postBuilder = targetBuilder.targetMe();
      }

      // Check for file types and add them to the post
      var images =
          files.where((file) => file.fileType == MyFileType.image).toList();
      var videos =
          files.where((file) => file.fileType == MyFileType.video).toList();
      var otherFiles =
          files.where((file) => file.fileType == MyFileType.file).toList();

      if (images.isNotEmpty) {
        log("image was selected");
        List<AmityImage> images = [];
        log("files length : ${files.length}");
        for (var amityImage in files) {
          images.add(AmityImage(amityImage.fileInfo!.getFileProperties!));
        }
        log("images length: ${images.length}");
        var readyBuilder = postBuilder.image(images);
        if (textEditingController.text.isNotEmpty) {
          readyBuilder.text(textEditingController.text);
        }
        await readyBuilder.post().then((post) async {
          handleCreatePost(
              post: post,
              isCommunity: isCommunity,
              context: context,
              callback: callback);
        }).onError((error, stackTrace) async {
          await AmityDialog()
              .showAlertErrorDialog(title: "Error!", message: error.toString());
        });
      } else if (videos.isNotEmpty) {
        log("video was selected");
        List<AmityVideo> videos = [];

        for (var amityVideo in files) {
          AmityVideo video =
              AmityVideo(amityVideo.fileInfo!.getFileProperties!);
          videos.add(video);
          log("add file to videos ${video.fileId}");
        }
        var readyBuilder = postBuilder.video(videos);
        if (textEditingController.text.isNotEmpty) {
          readyBuilder.text(textEditingController.text);
        }
        await readyBuilder.post().then((post) async {
          handleCreatePost(
              post: post,
              isCommunity: isCommunity,
              context: context,
              callback: callback);
          notifyListeners();
        }).onError((error, stackTrace) async {
          log(error.toString());
          await AmityDialog()
              .showAlertErrorDialog(title: "Error!", message: error.toString());
        });
      } else if (otherFiles.isNotEmpty) {
        log("file was selected");

        var readyBuilder = postBuilder.file(otherFiles
            .map((f) => AmityFile(f.fileInfo!.getFileProperties!))
            .toList());
        if (textEditingController.text.isNotEmpty) {
          readyBuilder.text(textEditingController.text);
        }

        await readyBuilder.post().then((AmityPost post) {
          handleCreatePost(
              post: post,
              isCommunity: isCommunity,
              context: context,
              callback: callback);
        }).onError((error, stackTrace) {
          callback(false, error.toString());
        });
      } else {
        print("creating.. text post");
        var readyBuilder = postBuilder.text(textEditingController.text);
        await readyBuilder.createTextPost().then((AmityPost post) {
          handleCreatePost(
              post: post,
              isCommunity: isCommunity,
              context: context,
              callback: callback);
        });
      }
    }
  }

  void handleCreatePost(
      {required AmityPost post,
      required bool isCommunity,
      required BuildContext context,
      required Function callback}) {
    if (isCommunity) {
      print("refreshing commu feed");
      Provider.of<CommuFeedVM>(context, listen: false).initAmityCommunityFeed(
          (post.target as CommunityTarget).targetCommunityId!);
      Provider.of<CommuFeedVM>(context, listen: false)
          .initAmityPendingCommunityFeed(
              (post.target as CommunityTarget).targetCommunityId!,
              AmityFeedType.REVIEWING);
    } else {
      var viewModel = Provider.of<FeedVM>(context, listen: false);
      viewModel.addPostToFeed(post);
      if (viewModel.scrollcontroller.hasClients) {
        viewModel.scrollcontroller.jumpTo(0);
      }
    }
    callback(true, null);
    notifyListeners();
  }

// Declare the map outside the function
  Map<String, Uint8List> thumbnailCache = {};
  ImageProvider getImageProvider(String path) {
    if (path.endsWith('.mp4') || path.endsWith('.MOV')) {
      log("Checking for thumbnail...");

      // Check if the thumbnail data for this path is already available in the map
      if (thumbnailCache.containsKey(path)) {
        log("found in cache");
        return MemoryImage(thumbnailCache[path]!);
      } else {
        throw Exception('Failed to generate video thumbnail: $path');
      }
    } else {
      return FileImage(File(path));
    }
  }
}
