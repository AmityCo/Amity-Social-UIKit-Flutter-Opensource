import 'dart:io';

import 'package:amity_uikit_beta_service/components/custom_user_avatar.dart';
import 'package:amity_uikit_beta_service/viewmodel/create_postV2_viewmodel.dart';
import 'package:amity_uikit_beta_service/viewmodel/media_viewmodel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class PostMedia extends StatelessWidget {
  final List<UIKitFileSystem> files;
  const PostMedia({super.key, required this.files});

  @override
  Widget build(BuildContext context) {
    Widget _buildMediaGrid(List<UIKitFileSystem> files) {
      if (files.isEmpty) return Container();

      Widget _backgroundImage(UIKitFileSystem file, int index) {
        // var file = files[index];
        int rawprogress =
            Provider.of<CreatePostVMV2>(context).files[0].progress;
        var progress = rawprogress / 100.0;

        return Padding(
          padding: const EdgeInsets.all(2.0),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: file.fileType == MyFileType.video
                        ? getImageProvider(file.file.path)
                        : FileImage(file.file),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              progress == 1
                  ? SizedBox()
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.center,
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 4.0,
                          backgroundColor: Colors.black38,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    print("delete file...");
                    print("delete file...");
                    Provider.of<CreatePostVMV2>(context, listen: false)
                        .deselectFile(
                            Provider.of<CreatePostVMV2>(context, listen: false)
                                .files[index]);
                  },
                ),
              ),
            ],
          ),
        );
      }

      switch (files.length) {
        case 1:
          return AspectRatio(
            aspectRatio: 1,
            child: _backgroundImage(files[0], 0),
          );

        case 2:
          return AspectRatio(
            aspectRatio: 1,
            child: Row(children: [
              Expanded(child: _backgroundImage(files[0], 0)),
              Expanded(child: _backgroundImage(files[1], 1))
            ]),
          );

        case 3:
          return AspectRatio(
            aspectRatio: 1,
            child: Column(
              children: [
                Expanded(child: _backgroundImage(files[0], 0)),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(child: _backgroundImage(files[1], 0)),
                      Expanded(child: _backgroundImage(files[2], 0)),
                    ],
                  ),
                ),
              ],
            ),
          );

        case 4:
          return AspectRatio(
            aspectRatio: 1,
            child: Column(
              children: [
                Expanded(child: _backgroundImage(files[0], 0)),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: _backgroundImage(files[1], 1),
                        ),
                      ),
                      Expanded(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: _backgroundImage(files[2], 2),
                        ),
                      ),
                      Expanded(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: _backgroundImage(files[3], 3),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );

        default:
          return GridView.count(
            crossAxisCount: 3,
            children: files.asMap().entries.map((entry) {
              int index = entry.key;
              var file = entry.value;
              return _backgroundImage(file, index);
            }).toList(),
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
          );
      }
    }

    String _getFileImage(String filePath) {
      String extension = filePath.split('.').last;
      switch (extension) {
        case 'audio':
          return 'assets/images/fileType/audio_small.png';
        case 'avi':
          return 'assets/images/fileType/avi_large.png';
        case 'csv':
          return 'assets/images/fileType/csv_large.png';
        case 'doc':
          return 'assets/images/fileType/doc_large.png';
        case 'exe':
          return 'assets/images/fileType/exe_large.png';
        case 'html':
          return 'assets/images/fileType/html_large.png';
        case 'img':
          return 'assets/images/fileType/img_large.png';
        case 'mov':
          return 'assets/images/fileType/mov_large.png';
        case 'mp3':
          return 'assets/images/fileType/mp3_large.png';
        case 'mp4':
          return 'assets/images/fileType/mp4_large.png';
        case 'pdf':
          return 'assets/images/fileType/pdf_large.png';
        case 'ppx':
          return 'assets/images/fileType/ppx_large.png';
        case 'rar':
          return 'assets/images/fileType/rar_large.png';
        case 'txt':
          return 'assets/images/fileType/txt_large.png';
        case 'xls':
          return 'assets/images/fileType/xls_large.png';
        case 'zip':
          return 'assets/images/fileType/zip_large.png';
        default:
          return 'assets/images/fileType/default.png';
      }
    }

    Widget _listMediaGrid(List<UIKitFileSystem> files) {
      return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: files.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          var file = files[index];
          int rawprogress =
              Provider.of<CreatePostVMV2>(context).files[index].progress;
          var progress = rawprogress / 100.0;

          String fileImage = _getFileImage(file.file.path);

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.0),
              border: Border.all(
                color: Color(0xffEBECEF),
                width: 1.0,
              ),
            ),
            margin: EdgeInsets.all(8.0),
            child: Stack(
              children: [
                // Progress indicator
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.transparent,
                  color: Colors.grey.shade200,
                  minHeight: 72,
                ),
                // ListTile content
                rawprogress == 0
                    ? const SizedBox(
                        height: 30,
                        child: Center(
                            child: Icon(
                          Icons.warning,
                          color: Colors.grey,
                        )))
                    : SizedBox(),
                ListTile(
                  onTap: () {},
                  contentPadding: EdgeInsets.symmetric(
                      vertical: 8, horizontal: 14), // Reduced padding
                  tileColor: Colors.white.withOpacity(0.0),
                  leading: Container(
                    height: 100, // Reduced height to make it slimmer
                    width: 40, // Added width to align the image
                    alignment:
                        Alignment.centerLeft, // Center alignment for the image
                    child: Image(
                      image: AssetImage(fileImage,
                          package: 'amity_uikit_beta_service'),
                    ),
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min, // Reduce extra space
                    children: [
                      Text(
                        file.file.path.split('/').last,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        '${(file.file.lengthSync() / 1024).toStringAsFixed(2)} KB',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  trailing: GestureDetector(
                    onTap: () {
                      print("delete file...");
                      Provider.of<CreatePostVMV2>(context, listen: false)
                          .deselectFile(Provider.of<CreatePostVMV2>(context,
                                  listen: false)
                              .files[index]);
                    },
                    child: Icon(Icons.close),
                  ),
                )
              ],
            ),
          );
        },
      );
    }

    bool isNotImageVideoOrAudio(UIKitFileSystem file) {
      final mimeType = lookupMimeType(file.file.path);

      if (mimeType != null) {
        final isImage = mimeType.startsWith('image/');
        final isVideo = mimeType.startsWith('video/');
        final isAudio = mimeType.startsWith('audio/');

        return !(isImage || isVideo || isAudio);
      } else {
        // If the MIME type is unknown, consider it as not an image, video, or audio.
        return true;
      }
    }

    if (files.isEmpty) {
      return Container(); // No non-image, non-video, non-audio files to display.
    }
    return isNotImageVideoOrAudio(files[0])
        ? _listMediaGrid(files)
        : _buildMediaGrid(files);
  }
}
