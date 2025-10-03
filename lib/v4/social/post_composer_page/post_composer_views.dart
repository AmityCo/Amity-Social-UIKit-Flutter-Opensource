import 'dart:io';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/core/ui/mention/mention_field.dart';
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
        getPageTitle(context),
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

  String getPageTitle(BuildContext context) {
    if (options.mode == AmityPostComposerMode.edit) {
      return context.l10n.post_edit;
    } else if (options.targetType == AmityPostTargetType.USER) {
      return context.l10n.general_my_timeline;
    } else {
      return options.community?.displayName ?? '';
    }
  }

  Widget buildActionButton(BuildContext context) {
    // Disable button if posting is in progress or if conditions aren't met
    final isButtonEnabled = isPostButtonEnabled && !isPosting;

    return TextButton(
      onPressed: isButtonEnabled ? () => handleAction(context) : null,
      child: Text(
        options.mode == AmityPostComposerMode.edit
            ? context.l10n.general_save
            : context.l10n.general_post,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: isButtonEnabled
              ? theme.primaryColor
              : theme.primaryColor.blend(ColorBlendingOption.shade2),
        ),
      ),
    );
  }

  Widget buildTextField(BuildContext context, String? communityId,
      double minBottomSheetSize, double maxBottomSheetSize) {
    return MentionTextField(
      controller: textController,
      theme: theme,
      communityId: communityId,
      suggestionDisplayMode: SuggestionDisplayMode.inline,
      mentionContentType: MentionContentType.post,
      suggestionMaxRow: 2,
      maxLines: null,
      enabled: true,
      decoration: InputDecoration(
        hintText: context.l10n.post_create_hint,
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        hintStyle: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.normal,
            color: theme.baseColorShade3),
      ),
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.normal,
        color: theme.baseColor,
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
          child: _mediaView(context, files.entries.first, 0),
        );

      case 2:
        return AspectRatio(
          aspectRatio: 1,
          child: Row(
            spacing: 8,
            children: [
              Expanded(
                  child: _mediaView(context, files.entries.toList()[0], 0)),
              Expanded(child: _mediaView(context, files.entries.toList()[1], 1))
            ],
          ),
        );

      default:
        final entriesList = files.entries.toList();
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            crossAxisCount: 3,
          ),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: entriesList.length,
          itemBuilder: (context, index) {
            return _mediaView(context, entriesList[index], index);
          },
        );
    }
  }

  Widget _mediaView(BuildContext context,
      MapEntry<String, AmityFileInfoWithUploadStatus> file, int index) {
    var progress = file.value.progress;
    var isError = file.value.isError;
    var isUploaded = file.value.isUploaded;

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
      padding: const EdgeInsets.all(0.0),
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
                    existingImages.removeAt(index);
                  } else if (selectedMediaType == FileType.video) {
                    existingVideos.removeAt(index);
                    existingVideoObjects.removeAt(index);
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
