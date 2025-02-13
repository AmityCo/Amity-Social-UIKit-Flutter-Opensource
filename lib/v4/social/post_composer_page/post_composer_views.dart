import 'dart:io';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/social/post_composer_page/bloc/post_composer_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/post_composer_page/post_composer_page.dart';
import 'package:amity_uikit_beta_service/v4/utils/SingleVideoPlayer/single_video_player.dart';
import 'package:amity_uikit_beta_service/v4/social/post_composer_page/post_composer_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

extension PostComposerView on AmityPostComposerPage {
  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: theme.backgroundColor,
      title: Text(
        getPageTitle(),
        style: TextStyle(
            fontWeight: FontWeight.w600, fontSize: 17, color: theme.baseColor),
      ),
      leading: IconButton(
        icon: SvgPicture.asset(
          'assets/Icons/amity_ic_close_button.svg',
          package: 'amity_uikit_beta_service',
          width: 24,
          height: 24,
          colorFilter: ColorFilter.mode(theme.baseColor, BlendMode.srcIn),
        ),
        onPressed: () => handleClose(context),
      ),
      centerTitle: true,
      actions: [buildActionButton(context)],
    );
  }

  String getPageTitle() {
    if (options.mode == AmityPostComposerMode.edit) {
      return "Edit Post";
    } else if (options.targetType == AmityPostTargetType.USER) {
      return "My Timeline";
    } else {
      return options.community?.displayName ?? '';
    }
  }

  Widget buildActionButton(BuildContext context) {
    return TextButton(
      onPressed: isPostButtonEnabled ? () => handleAction(context) : null,
      child: Text(
        options.mode == AmityPostComposerMode.edit ? "Save" : "Post",
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: isPostButtonEnabled
              ? theme.primaryColor
              : theme.primaryColor.blend(ColorBlendingOption.shade2),
        ),
      ),
    );
  }

  Widget buildTextField() {
    return TextFormField(
      controller: controller,
      maxLines: null,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        hintText: "What’s going on...",
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        hintStyle: TextStyle(color: theme.baseColorShade3),
      ),
    );
  }

  Widget mediaListView(
      BuildContext context, Map<String, AmityFileInfoWithUploadStatus> files) {
    switch (files.length) {
      case 0:
        return Container();
      case 1:
        return AspectRatio(
          aspectRatio: 1,
          child: _mediaView(context, files.entries.first),
        );

      case 2:
        return AspectRatio(
          aspectRatio: 1,
          child: Row(children: [
            Expanded(child: _mediaView(context, files.entries.toList()[0])),
            Expanded(child: _mediaView(context, files.entries.toList()[1]))
          ]),
        );

      default:
        return GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: files.entries.map((entry) {
            return _mediaView(context, entry);
          }).toList(),
        );
    }
  }

  Widget _mediaView(BuildContext context,
      MapEntry<String, AmityFileInfoWithUploadStatus> file) {
    var progress = file.value.progress;
    var isError = file.value.isError;
    var isUploaded = file.value.isUploaded;

    if (isError) {
      isPostButtonEnabled = false;
    }

    Widget mediaContent() {
      if (file.value.type == FileType.video) {
        if (file.value.videoThumbnail != null) {
          // New video
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SingleVideoPlayer(
                    initialIndex: 0,
                    filePath: file.key,
                    fileUrl: null,
                  ),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.memory(
                file.value.videoThumbnail!,
                fit: BoxFit.cover,
              ),
            ),
          );
        } else if (file.value.uploadedUrl != null) {
          // Existing video
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SingleVideoPlayer(
                    initialIndex: 0,
                    filePath: null,
                    fileUrl: file.key,
                  ),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(file.value.uploadedUrl!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          );
        }
      } else if (selectedMediaType == FileType.image) {
        if (file.value.uploadedUrl != null) {
          // Existing image
          return ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(file.value.uploadedUrl!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        } else {
          // New image
          return ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.file(
              File(file.key),
              fit: BoxFit.cover,
            ),
          );
        }
      }
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Stack(
        fit: StackFit.expand,
        children: [
          mediaContent(),
          if (progress < 100 && !isUploaded && !isError)
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Center(
                child: CircularProgressIndicator(
                  value: progress / 100.0,
                  strokeWidth: 3,
                  backgroundColor: Colors.white,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
            ),
          if (progress == 100 && file.value.type == FileType.video)
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 28,
                height: 28,
                decoration: const ShapeDecoration(
                  color: Color(0x40000000),
                  shape: OvalBorder(),
                ),
                child: const Icon(
                  Icons.play_arrow,
                  size: 24.0,
                  color: Colors.white,
                ),
              ),
            ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  context.read<PostComposerBloc>().add(
                        PostComposerDeleteFileEvent(filePath: file.key),
                      );
                  if (selectedMediaType == FileType.image) {
                    existingImages.remove(file.value.uploadedUrl);
                  } else if (selectedMediaType == FileType.video) {
                    existingVideos.remove(file.value.uploadedUrl);
                  }
                },
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                  child: Container(
                    color: theme.baseColor.withOpacity(0.5),
                    child: SvgPicture.asset(
                      'assets/Icons/amity_ic_close_button.svg',
                      package: 'amity_uikit_beta_service',
                      width: 24,
                      height: 24,
                      colorFilter:
                          const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (isError)
            Center(
              child: SvgPicture.asset(
                'assets/Icons/amity_ic_upload_error.svg',
                package: 'amity_uikit_beta_service',
                width: 28,
                height: 28,
              ),
            ),
        ],
      ),
    );
  }
}
