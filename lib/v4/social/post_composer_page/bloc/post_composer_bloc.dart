import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/social/post_composer_page/post_composer_model.dart';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_video_thumbnail/flutter_video_thumbnail.dart';
import 'package:image_picker/image_picker.dart';

part 'post_composer_events.dart';
part 'post_composer_state.dart';

class PostComposerBloc extends Bloc<PostComposerEvent, PostComposerState> {
  PostComposerBloc() : super(const PostComposerState()) {
    Map<String, AmityFileInfoWithUploadStatus> files = {};

    Future<void> performUpload(
      File file,
      FileType type,
      Function(num) onUploading,
      Function onSuccess,
      Function(String) onError,
      Function(Uint8List) onGetThumbnail,
    ) async {
      StreamController<AmityUploadResult>? client;

      if (type == FileType.video) {
        final Uint8List? uint8list = await FlutterVideoThumbnail.getThumbnail(
          file.path,
          quality: 75,
          useCache: true,
        );

        if (uint8list != null && uint8list.isNotEmpty) {
          files[file.path]?.updateThumbnail(uint8list);
          onGetThumbnail(uint8list);
        }
        client = AmityCoreClient.newFileRepository()
            .uploadVideo(file, feedtype: AmityContentFeedType.POST);
      } else if (type == FileType.image) {
        client = AmityCoreClient.newFileRepository().uploadImage(file);
      }

      if (client != null) {
        client.stream.listen(
          (amityUploadResult) {
            amityUploadResult.when(
              progress: (uploadInfo, cancelToken) {
                int progress = uploadInfo.getProgressPercentage();
                files[file.path]?.updateProgress(progress);
                onUploading(progress);
              },
              complete: (amityFile) {
                files[file.path]
                    ?.uploadSuccess(fileInfo: amityFile, file: file);
                onSuccess();
              },
              error: (error) async {
                files[file.path]?.uploadError();
                onError(error.toString());
              },
              cancel: () {
                onError('Upload cancelled'); // Invoke the error callback
              },
            );
          },
        );
      }

    }

    void handleUploadFile(String filePath, FileType type) async {
      emit(PostComposerSelectedFiles(selectedFiles: files));
      await performUpload(
        File(filePath),
        type,
        (progress) {
          emit(PostComposerSelectedFiles(selectedFiles: {}));
          emit(PostComposerSelectedFiles(selectedFiles: files));
        },
        () {
          emit(PostComposerSelectedFiles(selectedFiles: {}));
          emit(PostComposerSelectedFiles(selectedFiles: files));
        },
        (String) {
          emit(PostComposerSelectedFiles(selectedFiles: {}));
          emit(PostComposerSelectedFiles(selectedFiles: files));
        },
        (Uint8List) {
          emit(PostComposerSelectedFiles(selectedFiles: {}));
          emit(PostComposerSelectedFiles(selectedFiles: files));
        },
      );
    }

    on<PostComposerTextChangeEvent>((event, emit) {
      emit(PostComposerTextChangeState(text: event.text));
    });

    on<PostComposerSelectImagesEvent>((event, emit) async {
      AmityFileInfoWithUploadStatus image = AmityFileInfoWithUploadStatus()
        ..addFile(type: FileType.image);
      files[event.selectedImage.path] = image;
      handleUploadFile(event.selectedImage.path, FileType.image);
    });

    on<PostComposerSelectVideosEvent>((event, emit) async {
      AmityFileInfoWithUploadStatus video = AmityFileInfoWithUploadStatus()
        ..addFile(type: FileType.video);
      files[event.selectedVideos.path] = video;
      handleUploadFile(event.selectedVideos.path, FileType.video);
    });

    on<PostComposerDeleteFileEvent>((event, emit) async {
      final updatedImages =
          Map<String, AmityFileInfoWithUploadStatus>.from(files);
      updatedImages.remove(event.filePath);

      AmityCoreClient.newFileRepository().cancelUpload(event.filePath);
      emit(PostComposerSelectedFiles(selectedFiles: updatedImages));
      files.remove(event.filePath);
    });

    on<PostComposerGetImageUrlsEvent>((event, emit) async {
      for (var url in event.urls) {
        AmityFileInfoWithUploadStatus image = AmityFileInfoWithUploadStatus()
          ..addFile(
              type: FileType.image, url: url, progress: 100, isUploaded: true);
        files[url] = image;
      }
      emit(PostComposerSelectedFiles(selectedFiles: files));
    });

    on<PostComposerGetVideoUrlsEvent>((event, emit) async {
      final List<AmityVideo> videos = [];

      for (var data in event.videos) {
        final AmityVideo video = await data.getVideo(AmityVideoQuality.LOW);
        final videoUrl = video.getFileProperties!.fileUrl ?? "";

        var thumbnail = data.thumbnail?.getUrl(AmityImageSize.MEDIUM);
        AmityFileInfoWithUploadStatus image = AmityFileInfoWithUploadStatus()
          ..addFile(
              type: FileType.video,
              url: thumbnail,
              progress: 100,
              isUploaded: true);
        files[videoUrl] = image;
        videos.add(video);
      }
      emit(PostComposerSelectedFiles(
          selectedFiles: files, currentVideos: videos));
    });
  }
}
