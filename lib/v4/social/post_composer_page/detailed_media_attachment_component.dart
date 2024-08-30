import 'package:amity_uikit_beta_service/v4/core/base_component.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';

class AmityDetailedMediaAttachmentComponent extends NewBaseComponent {
  ImagePicker imagePicker = ImagePicker();
  final Function()? onCameraTap;
  final Function()? onImageTap;
  final Function()? onVideoTap;
  final FileType? mediaType;

  AmityDetailedMediaAttachmentComponent({
    Key? key,
    this.onCameraTap,
    this.onImageTap,
    this.onVideoTap,
    this.mediaType,
  }) : super(key: key, componentId: "componentId");

  Widget _buildListTile({
    required String assetPath,
    required String title,
    required Function()? onTap,
  }) {
    return ListTile(
      leading: SvgPicture.asset(
        assetPath,
        package: 'amity_uikit_beta_service',
        width: 32,
        height: 32,
      ),
      title: Transform.translate(
        offset: const Offset(-5, 0),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: theme.baseColor,
          ),
        ),
      ),
      onTap: onTap,
    );
  }

  @override
  Widget buildComponent(BuildContext context) {
    return Column(
      children: [
        Column(
          children: [
            _buildListTile(
              assetPath: 'assets/Icons/amity_ic_camera_button.svg',
              title: 'Camera',
              onTap: onCameraTap,
            ),
            if (mediaType == FileType.image || mediaType == null)
              _buildListTile(
                assetPath: 'assets/Icons/amity_ic_image_button.svg',
                title: 'Photo',
                onTap: onImageTap,
              ),
            if (mediaType == FileType.video || mediaType == null)
              _buildListTile(
                assetPath: 'assets/Icons/amity_ic_video_button.svg',
                title: 'Video',
                onTap: onVideoTap,
              ),
          ],
        ),
      ],
    );
  }
}
