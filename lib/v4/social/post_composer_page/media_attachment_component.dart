import 'dart:io';

import 'package:amity_uikit_beta_service/v4/core/base_component.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';

class AmityMediaAttachmentComponent extends NewBaseComponent {
  ImagePicker imagePicker = ImagePicker();
  final Function()? onCameraTap;
  final Function()? onImageTap;
  final Function()? onVideoTap;
  final FileType? mediaType;

  AmityMediaAttachmentComponent({
    Key? key,
    this.onCameraTap,
    this.onImageTap,
    this.onVideoTap,
    this.mediaType,
  }) : super(key: key, componentId: "media_attachment");

  @override
  Widget buildComponent(BuildContext context) {
    
    final featureConfig = configProvider.getFeatureConfig();
    final isVideoPostEnabled = featureConfig.post.video.createEnabled;
    final isImagePostEnabled = featureConfig.post.image.createEnabled;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (isImagePostEnabled || isVideoPostEnabled)
                IconButton(
                  icon: SvgPicture.asset(
                    'assets/Icons/amity_ic_camera_button.svg',
                    package: 'amity_uikit_beta_service',
                    width: 32,
                    height: 32,
                  ),
                  onPressed: () async {
                    if (onCameraTap != null) {
                      onCameraTap!();
                    }
                  },
                ),
              if ((mediaType == FileType.image || mediaType == null) && isImagePostEnabled)
                IconButton(
                  icon: SvgPicture.asset(
                    'assets/Icons/amity_ic_image_button.svg',
                    package: 'amity_uikit_beta_service',
                    width: 32,
                    height: 32,
                  ),
                  onPressed: () async {
                    if (onImageTap != null) {
                      onImageTap!();
                    }
                  },
                ),
              if ((mediaType == FileType.video || mediaType == null) && isVideoPostEnabled)
                IconButton(
                  icon: SvgPicture.asset(
                    'assets/Icons/amity_ic_video_button.svg',
                    package: 'amity_uikit_beta_service',
                    width: 32,
                    height: 32,
                  ),
                  onPressed: () async {
                    if (onVideoTap != null) {
                      onVideoTap!();
                    }
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }
}
