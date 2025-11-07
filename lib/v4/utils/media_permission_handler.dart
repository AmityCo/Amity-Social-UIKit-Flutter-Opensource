import 'dart:io';
import 'dart:typed_data';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';

class MediaPermissionHandler {
  // Check and request permissions
  Future<bool> handleMediaPermissions() async {
    // For Android 13+ (API level 33+)
    if (await _isAndroid13OrHigher()) {
      final status = await Permission.photos.status;
      if (status.isDenied) {
        // Request permissions
        Map<Permission, PermissionStatus> statuses = await [
          Permission.photos,
          Permission.videos,
        ].request();

        return statuses[Permission.photos]!.isGranted &&
            statuses[Permission.videos]!.isGranted;
      }
      return status.isGranted;
    }
    // For Android 12 and below
    else {
      final status = await Permission.storage.status;
      if (status.isDenied) {
        final result = await Permission.storage.request();
        return result.isGranted;
      }
      return status.isGranted;
    }
  }

  // Check if device is running Android 13 or higher
  Future<bool> _isAndroid13OrHigher() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      return androidInfo.version.sdkInt >= 33;
    }
    return false;
  }

  // Pick image using photo picker
  Future<XFile?> pickImage() async {
    if (await handleMediaPermissions()) {
      final ImagePicker picker = ImagePicker();
      try {
        _configureAndroidPhotoPicker(false);
        final XFile? image = await picker.pickImage(
          source: ImageSource.gallery,
        );
        return image;
      } catch (e) {
        print('Error picking image: $e');
        return null;
      }
    }
    return null;
  }

  // Pick video using photo picker
  Future<XFile?> pickVideo() async {
    if (await handleMediaPermissions()) {
      final ImagePicker picker = ImagePicker();
      try {
        _configureAndroidPhotoPicker(false);
        final XFile? video = await picker.pickVideo(
          source: ImageSource.gallery,
        );
        return video;
      } catch (e) {
        print('Error picking video: $e');
        return null;
      }
    }
    return null;
  }

  Future<List<XFile>> pickImageAndVideo({limit = 10}) async {
    if (await handleMediaPermissions()) {
      final ImagePicker picker = ImagePicker();
      try {
        final ImagePickerPlatform imagePickerImplementation =
            ImagePickerPlatform.instance;
        if (imagePickerImplementation is ImagePickerAndroid) {
          imagePickerImplementation.useAndroidPhotoPicker = false;
        }
        List<XFile> mediaFiles = [];

        // Pick images
        final List<XFile> images = await picker.pickMultipleMedia(
          limit: limit,
        );
        mediaFiles.addAll(images);
        return mediaFiles;
      } catch (e) {
        return [];
      }
    }
    return [];
  }

  void _configureAndroidPhotoPicker(bool enabled) {
    final platform = ImagePickerPlatform.instance;
    if (platform is ImagePickerAndroid) {
      platform.useAndroidPhotoPicker = enabled;
    }
  }

  // Save media to gallery
  Future<bool> saveVideoToGallery(String filePath, String? fileName) async {
    if (await handleMediaPermissions()) {
      try {
        await PhotoManager.editor.saveVideo(
          File(filePath),
          title: fileName ?? 'video_${DateTime.now().millisecondsSinceEpoch}',
        );
        return true;
      } catch (e) {
        return false;
      }
    }
    return false;
  }

  Future<bool> saveImageToGallery(Uint8List imageData, String? fileName) async {
    if (await handleMediaPermissions()) {
      try {
        await PhotoManager.editor.saveImage(
          imageData,
          filename:
              fileName ?? 'image_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        return true;
      } catch (e) {
        return false;
      }
    }
    return false;
  }

  Future<bool> downloadAndSaveVideo(String url) async {
    Dio dio = Dio();
    final fileName = 'video_${DateTime.now().millisecondsSinceEpoch}.mp4';
    try {
      // Get the application documents directory
      Directory appDocDir = await getApplicationCacheDirectory();

      // Create a file path with the filename
      String filePath = '${appDocDir.path}/$fileName';

      // Start downloading the video
      await dio.download(
        url,
        filePath,
        onReceiveProgress: (int received, int total) {},
      );

      // Save the video to gallery
      await saveVideoToGallery(filePath, fileName);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> downloadAndSaveImage(String url) async {
    Dio dio = Dio();
    final fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
    try {
      final response = await dio.get(
        url,
        options: Options(responseType: ResponseType.bytes),
      );

      final Uint8List imageBytes = Uint8List.fromList(response.data);

      // Save the video to gallery
      await saveImageToGallery(imageBytes, fileName);
      return true;
    } catch (e) {
      return false;
    }
  }
}
