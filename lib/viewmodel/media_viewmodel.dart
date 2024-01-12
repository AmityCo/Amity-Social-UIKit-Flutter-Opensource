import 'dart:io';

import 'package:amity_uikit_beta_service/utils/navigation_key.dart';
import 'package:amity_uikit_beta_service/viewmodel/create_post_viewmodel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';

class MediaPickerVM with ChangeNotifier {
  final ImagePicker _picker = ImagePicker();
  final List<File> _selectedFiles = [];
  void deleteAmityFile(int index) {
    if (index >= 0 && index < _selectedFiles.length) {
      _selectedFiles.removeAt(index);
      notifyListeners();
    }
  }

  List<File> get selectedFiles => _selectedFiles;

  bool isNotUploadYet(String filePath) {
    // Access the list of uploaded files from the Provider
    var uploadedList = Provider.of<CreatePostVM>(
            NavigationService.navigatorKey.currentContext!,
            listen: false)
        .amityUploadFile;

    // Iterate through the uploadedList to find if any file's path matches the given filePath
    for (var fileInfo in uploadedList) {
      // Assuming that fileInfo.file represents the File and has a path property
      // print(fileInfo.file?.path);
      if (fileInfo.file?.path == filePath) {
        // The file's path matches the given filePath, meaning the upload did not fail
        print("MATCH");
        return false;
      }
    }

    // If no match was found in the uploadedList, return true, indicating the upload failed

    return true;
  }

  Future<void> pickImagesfromCamera() async {
    try {
      XFile? pickedImage = await _picker.pickImage(source: ImageSource.camera);

      if (pickedImage != null) {
        _selectedFiles.add(File(pickedImage.path));

        notifyListeners();
      }
    } catch (e) {
      print("Error picking images: $e");
      // Handle the error as appropriate for your app
    }
  }

  Future<void> pickMultipleImages() async {
    try {
      List<XFile>? pickedImages = await _picker.pickMultiImage();

      if (pickedImages.isNotEmpty) {
        for (var image in pickedImages) {
          _selectedFiles.add(File(image.path));
        }
        notifyListeners();
      }
    } catch (e) {
      print("Error picking images: $e");
      // Handle the error as appropriate for your app
    }
  }

  Future<void> pickVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        _selectedFiles.add(File(video.path));
        notifyListeners();
      }
    } catch (e) {
      print("Error picking video: $e");
      // Handle the error as appropriate for your app
    }
  }

  void clearFiles() {
    _selectedFiles.clear();
  }

  bool get hasSelectedFiles => _selectedFiles.isNotEmpty;

  Future<void> pickFile() async {
    try {
      FilePickerResult? result =
          await FilePicker.platform.pickFiles(allowMultiple: true);

      if (result != null && result.files.isNotEmpty) {
        for (var file in result.files) {
          _selectedFiles.add(File(file.path!));
        }
        notifyListeners();
      }
    } catch (e) {
      print("Error picking files: $e");
      // Handle the error as appropriate for your app
    }
  }

  bool isNotSelectVideoYet() {
    return !_selectedFiles.any((file) => _isVideo(file));
  }

  bool isNotSelectedFileYet() {
    return !_selectedFiles.any((file) => _isOther(file));
  }

  bool isNotSelectedImageYet() {
    return !_selectedFiles.any((file) => _isImage(file));
  }

  bool _isImage(File file) {
    var mimeType = lookupMimeType(file.path);
    return mimeType != null && mimeType.startsWith('image/');
  }

  bool _isVideo(File file) {
    var mimeType = lookupMimeType(file.path);
    return mimeType != null && mimeType.startsWith('video/');
  }

  bool _isOther(File file) {
    var mimeType = lookupMimeType(file.path);
    return mimeType != null &&
        !mimeType.startsWith('image/') &&
        !mimeType.startsWith('video/');
  }
}
