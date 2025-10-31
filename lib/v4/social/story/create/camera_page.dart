import 'dart:io';
import 'package:amity_uikit_beta_service/v4/core/base_page.dart';
import 'package:amity_uikit_beta_service/v4/social/story/create/bloc/camera_permission_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/story/create/camera_preview_builder.dart';
import 'package:amity_uikit_beta_service/v4/social/story/draft/amity_story_media_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AmityCameraPage extends NewBasePage {
  final bool isVideoMode;
  final void Function(File, StoryVideoMetadata, bool isFromGallery) onVideoCaptured;
  final void Function(File, bool isFromGallery) onImageCaptured;
  final Function() onCloseClicked;

  AmityCameraPage({
    super.key,
    required this.isVideoMode,
    required this.onVideoCaptured,
    required this.onImageCaptured,
    required this.onCloseClicked,
  }) : super(pageId: 'amity_camera_page');

  @override
  Widget buildPage(BuildContext context) {
    return BlocProvider(
      create: (context) => CameraPermissionBloc(),
      child: CameraPreviewBuilder(
        isVideoMode: isVideoMode,
        onVideoCaptured: onVideoCaptured,
        onImageCaptured: onImageCaptured,
        onCloseClicked: onCloseClicked,
        themeColor: theme,
      ),
    );
  }
}
