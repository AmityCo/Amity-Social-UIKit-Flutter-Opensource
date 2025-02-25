import 'dart:io';

import 'package:amity_uikit_beta_service/v4/utils/amity_dialog.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> isImageFileMime(XFile file) async {
  final mimeType = lookupMimeType(file.path);
  return mimeType?.startsWith('image/') ?? false;
}

Future<bool> isVideoFileMime(XFile file) async {
  final mimeType = lookupMimeType(file.path);
  return mimeType?.startsWith('video/') ?? false;
}

ImageProvider getAvatarImageFromUrl(String? avatarUrl) {
  if (avatarUrl != null && avatarUrl.isNotEmpty) {
    return NetworkImage(avatarUrl);
  } else {
    return const AssetImage("assets/images/user_placeholder.png",
        package: "amity_uikit_beta_service");
  }
}

Future<bool> saveImageFromUrl(String imageUrl,
    {String name = "saved_image"}) async {
  try {
    final response = await Dio().get(
      imageUrl,
      options: Options(responseType: ResponseType.bytes),
    );

    final Uint8List imageBytes = Uint8List.fromList(response.data);

    final result = await ImageGallerySaver.saveImage(
      imageBytes,
      quality: 100,
      name: name,
    );

    if (result['isSuccess']) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    return false;
  }
}
