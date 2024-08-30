

import 'dart:io';
import 'dart:typed_data';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:file_picker/file_picker.dart';

class AmityPostComposerOptions {
  final AmityPostComposerMode mode;
  final AmityPost? post;
  final String? targetId;
  final AmityPostTargetType? targetType;
  final AmityCommunity? community;

  AmityPostComposerOptions.editOptions({
    this.mode = AmityPostComposerMode.edit,
    required this.post,
  })  : targetId = null,
        targetType = null,
        community = null;

  AmityPostComposerOptions.createOptions({
    this.mode = AmityPostComposerMode.create,
    this.targetId,
    required this.targetType,
    this.community,
  }) : post = null;
}

enum AmityPostComposerMode {
  create,
  edit,
}

class AmityFileInfoWithUploadStatus {
  AmityFileInfo? fileInfo;
  bool isError = false;
  bool isUploaded = false;
  File? file;
  num progress = 0;
  Uint8List? videoThumbnail;
  FileType type = FileType.image;
  String? uploadedUrl;

  void addFile(
      {AmityFileInfo? amityFileInfo,
      File? file,
      FileType? type,
      num progress = 0,
      bool isUploaded = false,
      String? url}) {
    fileInfo = amityFileInfo;
    this.file = file;
    this.progress = progress;
    this.isUploaded = isUploaded;
    this.type = type ?? FileType.image;
    uploadedUrl = url;
  }

  void updateThumbnail(Uint8List thumbnail) {
    videoThumbnail = thumbnail;
  }

  void updateProgress(num newProgress) {
    progress = newProgress;
  }

  void uploadSuccess({AmityFileInfo? fileInfo, File? file}) {
    this.fileInfo = fileInfo;
    this.file = file;
    progress = 100;
    isUploaded = true;
  }

  void uploadUrl(String url) {
    uploadedUrl = url;
  }

  void uploadError() {
    isError = true;
  }
}
