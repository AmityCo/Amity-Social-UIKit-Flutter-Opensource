import 'dart:io';

import 'package:amity_uikit_beta_service/v4/core/toast/amity_uikit_toast.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/post_composer_page/bloc/post_composer_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/post_composer_page/post_composer_page.dart';
import 'package:amity_uikit_beta_service/v4/utils/amity_dialog.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;

extension PostComposerFilePicker on AmityPostComposerPage {
  /// Converts HEIC/HEIF XFile images to JPG format
  /// Returns the original XFile if it's not HEIC/HEIF or if conversion fails
  Future<XFile> _convertHeicXFileToJpgIfNeeded(XFile xFile) async {
    try {
      final fileExtension = path.extension(xFile.path).toLowerCase();
      print('Lets check file extension: $fileExtension');

      // Convert all images
        // Generate output path with .jpg extension
        final directory = path.dirname(xFile.path);
        final fileName = path.basenameWithoutExtension(xFile.path);
        final outputPath = path.join(directory, '$fileName.jpg');
        
        // Convert HEIC/HEIF to JPG using flutter_image_compress
        final result = await FlutterImageCompress.compressAndGetFile(
          xFile.path,
          outputPath,
          format: CompressFormat.jpeg,
          quality: 95,
        );
        
        if (result != null) {
          print('Image got converted to JPG');
          return XFile(result.path);
        }
      
    } catch (e) {
      // If conversion fails, return original file
      print('Failed to convert HEIC/HEIF to JPG: $e');
    }
    
    return xFile;
  }

  void pickMultipleFiles(BuildContext context, FileType type,
      {int maxFiles = 10}) async {
    try {
      String typeText;
      List<XFile> files = [];
      bool isPickerClosed = false;
      if (Platform.isAndroid) {
        // for Android
        if (type == FileType.video) {
          typeText = 'videos';

          pickVideos() async {
            FilePickerResult? result = await FilePicker.platform.pickFiles(
              type: type,
              allowMultiple: true,
              allowCompression: true,
              withData: false,
              withReadStream: true,
              lockParentWindow: true,
              onFileLoading: (status) => {
                if (status == FilePickerStatus.done)
                  {context.read<AmityToastBloc>().add(AmityToastDismiss())}
                else
                  {
                    context.read<AmityToastBloc>().add(const AmityToastLoading(
                        message: "Processing...", icon: AmityToastIcon.loading))
                  }
              },
            );

            if (result != null) {
              files = result.files
                  .where((file) => file.path != null)
                  .map((file) => XFile(file.path!))
                  .toList();
            }
          }

          showPermissionDialog() async {
            ConfirmationV4Dialog().show(
              context: context,
              title: 'Allow access to your vidoes',
              detailText:
                  'This allows $appName to access vidoes on your device.',
              leftButtonColor: null,
              leftButtonText: 'OK',
              rightButtonText: 'Open settings',
              onConfirm: () {
                openAppSettings();
              },
            );
          }

          try {
            var androidInfo = await DeviceInfoPlugin().androidInfo;
            var sdkInt = androidInfo.version.sdkInt;

            if (sdkInt > 32) {              
              await pickVideos();
            } else {
              // Needs to check storage permission on Android versions 12 and below
              if (await Permission.storage.request().isGranted) {
                await pickVideos();
              } else {
                await showPermissionDialog();
              }
            }
          } catch (e) {
            await showPermissionDialog();
          }
        } else {
          typeText = 'images';
          Future.delayed(const Duration(milliseconds: 1000), () {
            if (!isPickerClosed) {
              context.read<AmityToastBloc>().add(const AmityToastLoading(
                  message: "Processing...", icon: AmityToastIcon.loading));
            }
          });
          try {
            files = await imagePicker.pickMultiImage(limit: 10);
            isPickerClosed = true;
            context.read<AmityToastBloc>().add(AmityToastDismiss());
          } catch (e) {
            isPickerClosed = true;

            PermissionAlertV4Dialog().show(
              context: context,
              title: 'Allow access to your photos',
              detailText:
                  'This allows $appName to share photos from this device and save photos to it.',
              bottomButtonText: 'OK',
              topButtonText: 'Open settings',
              onTopButtonAction: () {
                openAppSettings();
              },
            );
            context.read<AmityToastBloc>().add(AmityToastDismiss());
          }
        }
      } else {
        // for iOS
        Future<void> Function() showPermissionDialog;

        if (type == FileType.image) {
          typeText = 'images';
          showPermissionDialog = () async {
            PermissionAlertV4Dialog().show(
              context: context,
              title: 'Allow access to your photos',
              detailText:
                  'This allows $appName to share photos from this device and save photos to it.',
              bottomButtonText: 'OK',
              topButtonText: 'Open settings',
              onTopButtonAction: () {
                openAppSettings();
              },
            );
          };
        } else {
          typeText = 'videos';

          showPermissionDialog = () async {
            ConfirmationV4Dialog().show(
              context: context,
              title: 'Allow access to your vidoes',
              detailText:
                  'This allows $appName to access vidoes on your device.',
              leftButtonColor: null,
              leftButtonText: 'OK',
              rightButtonText: 'Open settings',
              onConfirm: () {
                openAppSettings();
              },
            );
          };
        }

        try {
          pickFiles() async {
            FilePickerResult? result = await FilePicker.platform.pickFiles(
              type: type,
              allowMultiple: true,
              allowCompression: true,
              withData: false,
              withReadStream: true,
              lockParentWindow: true,
              onFileLoading: (status) => {
                if (status == FilePickerStatus.done)
                  {context.read<AmityToastBloc>().add(AmityToastDismiss())}
                else
                  {
                    context.read<AmityToastBloc>().add(const AmityToastLoading(
                        message: "Processing...", icon: AmityToastIcon.loading))
                  }
              },
            );

            if (result != null) {
              files = result.files
                  .where((file) => file.path != null)
                  .map((file) => XFile(file.path!))
                  .toList();
            }
          }

          await pickFiles();
        } catch (e) {
          isPickerClosed = true;
          showPermissionDialog();
          context.read<AmityToastBloc>().add(AmityToastDismiss());
        }
      }

      if (files.isNotEmpty) {
        if (selectedFiles.length + files.length > 10) {
          AmityV4Dialog().showAlertErrorDialog(
            title: "Maximum upload limit reached",
            message:
                "You’ve reached the upload limit of 10 $typeText. Any additional $typeText will not be saved.",
            closeText: "Close",
          );
        } else {
          if (type == FileType.image) {
            for (var image in files) {
              // Convert HEIC/HEIF to JPG if needed before uploading
              XFile convertedImage = await _convertHeicXFileToJpgIfNeeded(image);
              context.read<PostComposerBloc>().add(
                    PostComposerSelectImagesEvent(selectedImage: convertedImage),
                  );
            }
          } else {
            for (var video in files) {
              context.read<PostComposerBloc>().add(
                    PostComposerSelectVideosEvent(selectedVideos: video),
                  );
            }
          }
        }
      } else {
        context.read<AmityToastBloc>().add(AmityToastDismiss());
      }
      // ignore: empty_catches
    } catch (e) {}
    return null;
  }
}