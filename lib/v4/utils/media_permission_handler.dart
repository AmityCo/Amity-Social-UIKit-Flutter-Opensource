import 'dart:io';
import 'dart:typed_data';

import 'package:amity_uikit_beta_service/utils/navigation_key.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/utils/amity_dialog.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class MediaPermissionHandler {
  // Check and request permissions.
  // Returns the PermissionState (authorized, limited, denied, notDetermined).
  // Use [requestPermissions] for a bool result, or inspect the state directly
  // to decide which picker to open without an extra system call.
  Future<PermissionState?> requestPermissionsWithState() async {
    if (await _isAndroid13OrHigher()) {
      final permissionState = await PhotoManager.requestPermissionExtend();
      if (permissionState == PermissionState.denied ||
          permissionState == PermissionState.notDetermined) {
        await _showPermissionDialog();
      }
      return permissionState;
    }
    return null; // Android 12 and below — use handleMediaPermissions()
  }

  // Check and request permissions.
  // Returns true when the user has granted either full or partial (limited)
  // access. Use [isLimitedAccess] afterwards to decide which picker to open.
  Future<bool> handleMediaPermissions() async {
    // For Android 13+ (API level 33+) use photo_manager which correctly
    // distinguishes full vs. partial (limited) access on Android 14+.
    if (await _isAndroid13OrHigher()) {
      final permissionState = await PhotoManager.requestPermissionExtend();

      if (permissionState == PermissionState.denied ||
          permissionState == PermissionState.notDetermined) {
        await _showPermissionDialog();
        return false;
      }

      // PermissionState.authorized  → full access
      // PermissionState.limited     → partial access (Android 14+)
      // Both are acceptable — callers use isLimitedAccess() to pick the
      // right picker UI.
      return permissionState == PermissionState.authorized ||
          permissionState == PermissionState.limited;
    }
    // For Android 12 and below
    else {
      final status = await Permission.storage.status;
      if (status.isDenied) {
        final result = await Permission.storage.request();
        
        if (!result.isGranted) {
          await _showPermissionDialog();
        }
        
        return result.isGranted;
      } else if (status.isPermanentlyDenied) {
        await _showPermissionDialog();
        return false;
      }
      return status.isGranted;
    }
  }

  Future<void> _showPermissionDialog() async {
    final BuildContext? context = NavigationService.navigatorKey.currentContext;
    if (context == null) return;

    final appName = await _getAppName();
    
    PermissionAlertV4Dialog().show(
      context: context,
      title: 'Allow access to your photos and videos',
      detailText:
          'This allows $appName to share photos and videos from this device.',
      bottomButtonText: 'OK',
      topButtonText: 'Open settings',
      onTopButtonAction: () {
        openAppSettings();
      },
    );
  }

  Future<String> _getAppName() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.appName;
    } catch (e) {
      return 'this app';
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

  // Returns true when the user has granted only partial (limited) media access
  // on Android 14+. Uses photo_manager which correctly reports PermissionState.limited
  // on Android 14+ (permission_handler does not surface this on Android).
  Future<bool> isLimitedAccess() async {
    if (!Platform.isAndroid) return false;
    if (!await _isAndroid13OrHigher()) return false;
    final permissionState = await PhotoManager.requestPermissionExtend();
    return permissionState == PermissionState.limited;
  }

  // Pick image using photo picker
  Future<XFile?> pickImage() async {
    if (await handleMediaPermissions()) {
      final ImagePicker picker = ImagePicker();
      try {
        // Use Android Photo Picker when access is limited so only the
        // user-selected photos are shown, not the full gallery.
        final limited = await isLimitedAccess();
        _configureAndroidPhotoPicker(limited);
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
        // Use Android Photo Picker when access is limited so only the
        // user-selected videos are shown, not the full gallery.
        final limited = await isLimitedAccess();
        _configureAndroidPhotoPicker(limited);
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

  Future<List<XFile>> pickImageAndVideo({int limit = 10, AmityThemeColor? theme}) async {
    final BuildContext? context = NavigationService.navigatorKey.currentContext;
    if (context == null) return [];

    try {
      // Build picker theme from UIKit AmityThemeColor if provided.
      // Override iconTheme and textTheme so the check icon and selection
      // index numbers (1,2,3) are always white — they sit on a colored
      // circle background and must contrast against it regardless of
      // whether the app is in light or dark mode.
      final ThemeData? pickerTheme = theme != null
          ? AssetPicker.themeData(theme.primaryColor,
                  light: theme.backgroundColor.computeLuminance() > 0.5)
              .copyWith(
              iconTheme: const IconThemeData(color: Colors.white),
              textTheme: Typography.material2021().white.copyWith(
                    bodyLarge: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
            )
          : null;

      final List<AssetEntity>? assets = await AssetPicker.pickAssets(
        context,
        pickerConfig: AssetPickerConfig(
          maxAssets: limit,
          requestType: RequestType.common, // image + video
          pickerTheme: pickerTheme,
        ),
      );

      if (assets == null || assets.isEmpty) return [];

      final List<XFile> files = [];
      for (final asset in assets) {
        final File? file = await asset.originFile;
        if (file != null) {
          files.add(XFile(file.path));
        }
      }
      return files;
    } catch (e) {
      return [];
    }
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
