import 'dart:async';
import 'dart:io';

import 'dart:math';
import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/amity_uikit.dart';
import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:amity_uikit_beta_service/v4/core/base_page.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/amity_uikit_toast.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/globalfeed/bloc/global_feed_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/post_composer_page/bloc/post_composer_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/post_composer_page/detailed_media_attachment_component.dart';
import 'package:amity_uikit_beta_service/v4/social/post_composer_page/media_attachment_component.dart';
import 'package:amity_uikit_beta_service/v4/social/post_composer_page/post_camera_screen.dart';
import 'package:amity_uikit_beta_service/v4/social/post_composer_page/post_composer_file_picker.dart';
import 'package:amity_uikit_beta_service/v4/social/post_composer_page/post_composer_views.dart';
import 'package:amity_uikit_beta_service/v4/social/post_composer_page/post_composer_model.dart';
import 'package:amity_uikit_beta_service/v4/utils/CustomBottomSheet/custom_buttom_sheet.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:amity_uikit_beta_service/v4/utils/amity_dialog.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/ui/mention/mention_text_editing_controller.dart';

class AmityPostComposerPage extends NewBasePage {
  final AmityPostComposerOptions options;
  final MentionTextEditingController textController =
      MentionTextEditingController();
  final void Function(bool shouldPopCaller)? onPopRequested;
  ImagePicker imagePicker = ImagePicker();
  late String currentPostText = '';
  late int currentUrlsCount = 0;
  Map<String, AmityFileInfoWithUploadStatus> selectedFiles = {};
  Set<String>? existingFileKeys;
  FileType? selectedMediaType;
  List<AmityImage> existingImages = [];
  List<VideoData> existingVideos = [];
  List<AmityVideo> existingVideoObjects = [];
  bool isPostButtonEnabled = false;
  bool isTextChanged = false;
  bool isFileCountChanged = false;
  bool isMediaReady = false;
  String appName = '';

  AmityPostComposerPage({Key? key, required this.options, this.onPopRequested})
      : super(key: key, pageId: 'post_composer_page');

  final Cubit<int>? postAsCubit =
      AmityUIKit4Manager.freedomBehavior.postComposerPageBehavior.postAsCubit;
  final addIsCreateByAdminMetadata = AmityUIKit4Manager
      .freedomBehavior.postComposerPageBehavior.addIsCreateByAdminMetadata;
  final buildPostAsButton = AmityUIKit4Manager
      .freedomBehavior.postComposerPageBehavior.buildPostAsButton;

  @override
  Widget buildPage(BuildContext context) {
    _getAppName();
    String? communityId =
        (options.targetType == AmityPostTargetType.COMMUNITY &&
                options.targetId != null)
            ? options.targetId
            : null;

    if (options.mode == AmityPostComposerMode.edit) {
      AmityPost post = options.post!;
      currentPostText = (post.data as TextData).text ?? '';

      existingImages.clear();
      existingVideos.clear();

      if (post.children?.isNotEmpty ?? false) {
        for (var child in post.children!) {
          var postData = child.data;
          if (postData is VideoData) {
            var data = postData;
            existingVideos.add(data);

            data.getVideo(AmityVideoQuality.LOW).then((video) {
              existingVideoObjects.add(video);
            });

            selectedMediaType = FileType.video;
          } else if (postData is ImageData) {
            var data = postData;
            existingImages.add(data.image!);
            selectedMediaType = FileType.image;
          }
        }
        if (selectedMediaType == FileType.image) {
          currentUrlsCount = existingImages.length;
        } else if (selectedMediaType == FileType.video) {
          currentUrlsCount = existingVideos.length;
        }
      }
    }
    return BlocProvider(
      create: (context) => PostComposerBloc(),
      child: Builder(builder: (context) {
        _initializeController(context);

        return BlocBuilder<PostComposerBloc, PostComposerState>(
          builder: (context, state) {
            if (existingImages.isNotEmpty || existingVideos.isNotEmpty) {
              if (selectedMediaType == FileType.image) {
                List<String> uploadedUrlsKeys = existingImages.map((e) {
                  return e.getUrl(AmityImageSize.MEDIUM);
                }).toList();
                context.read<PostComposerBloc>().add(
                      PostComposerGetImageUrlsEvent(urls: uploadedUrlsKeys),
                    );
              } else if (selectedMediaType == FileType.video) {
                List<VideoData> uploadedUrlsKeys = existingVideos.toList();
                context.read<PostComposerBloc>().add(
                      PostComposerGetVideoUrlsEvent(videos: uploadedUrlsKeys),
                    );
              }
            }

            if (state is PostComposerTextChangeState) {
              textController.text = state.text;
              if (currentPostText != state.text) {
                isTextChanged = true;
              } else {
                isTextChanged = false;
              }
              updatePostButtonStatus();
            }

            if (state is PostComposerSelectedFiles) {
              selectedFiles = state.selectedFiles;
              existingFileKeys ??= selectedFiles.keys.toSet();
              final newFileKeys = selectedFiles.keys.toSet();

              if (state.selectedFiles.isEmpty) {
                selectedMediaType = null;
                isFileCountChanged = !setEquals(existingFileKeys, newFileKeys);
              } else {
                if (selectedFiles.entries.first.value.type == FileType.video) {
                  selectedMediaType = FileType.video;
                } else if (selectedFiles.entries.first.value.type ==
                    FileType.image) {
                  selectedMediaType = FileType.image;
                }
                if (currentUrlsCount != selectedFiles.length) {
                  isFileCountChanged = true;
                } else {
                  isFileCountChanged =
                      !setEquals(existingFileKeys, newFileKeys);
                }
                checkAllFilesAreUploaded(context);
              }
              updatePostButtonStatus();
            }

            double maxBottomSheetSize = 0.3;
            double minBottomSheetSize = 0.125;
            if (selectedMediaType != null) {
              // 0.8 per item
              maxBottomSheetSize = 0.22;
            }

            return Scaffold(
              backgroundColor: theme.backgroundColor,
              appBar: buildAppBar(context),
              body: Stack(
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                const SizedBox(height: 10),
                                if (options.community != null)
                                  buildPostAsButton(options.community!),
                                buildTextField(context, communityId,
                                    minBottomSheetSize, maxBottomSheetSize),
                                const SizedBox(height: 10),
                                Container(
                                  color: Colors.transparent,
                                  child: mediaListView(context, selectedFiles),
                                ),
                                const SizedBox(height: 200),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // if (options.mode == AmityPostComposerMode.create)
                  CustomBottomSheet(
                    maxSize: maxBottomSheetSize,
                    minSize: minBottomSheetSize,
                    theme: theme,
                    collapsedContent: AmityMediaAttachmentComponent(
                      onCameraTap: () async {
                        onCameraTap(context);
                      },
                      onImageTap: () async {
                        pickMultipleFiles(context, FileType.image,
                            maxFiles: 10);
                      },
                      onVideoTap: () async {
                        pickMultipleFiles(context, FileType.video,
                            maxFiles: 10);
                      },
                      mediaType: selectedMediaType,
                    ),
                    expandedContent: AmityDetailedMediaAttachmentComponent(
                        onCameraTap: () {
                          onCameraTap(context);
                        },
                        onImageTap: () {
                          pickMultipleFiles(context, FileType.image,
                              maxFiles: 10);
                        },
                        onVideoTap: () {
                          pickMultipleFiles(context, FileType.video,
                              maxFiles: 10);
                        },
                        mediaType: selectedMediaType),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  void updatePostButtonStatus() {
    // For create mode, enable button if there's text or files
    if (options.mode == AmityPostComposerMode.create) {
      if (textController.text.isNotEmpty) {
        isPostButtonEnabled = true;
      } else if (selectedFiles.isNotEmpty) {
        isPostButtonEnabled = isMediaReady; // Only enable if media is ready
      } else {
        isPostButtonEnabled = false; // Nothing to post
      }
      return;
    }

    // For edit mode, check if anything changed
    if (options.mode == AmityPostComposerMode.edit) {
      // Check if text and files are empty
      if (textController.text.isEmpty && selectedFiles.isEmpty) {
        isPostButtonEnabled = false;
        return;
      }

      // If nothing changed, disable button
      if (!isTextChanged && !isFileCountChanged) {
        isPostButtonEnabled = false;
        return;
      }

      // If files changed, check if they're all uploaded
      if (isFileCountChanged && selectedFiles.isNotEmpty) {
        isPostButtonEnabled = isMediaReady;
        return;
      }

      // If file count changed and files are empty, enable button
      if (isFileCountChanged && selectedFiles.isEmpty) {
        isPostButtonEnabled = true;
        return;
      }

      // If only text changed (no files or no file changes), enable button
      if (isTextChanged) {
        isPostButtonEnabled = true;
        return;
      }

      // print('No changes detected');
      // Default case - nothing valid to update
      isPostButtonEnabled = false;
    }
  }

  void checkAllFilesAreUploaded(BuildContext context) {
    bool isAllImageUploaded =
        selectedFiles.values.every((image) => image.isUploaded == true);
    if (isAllImageUploaded) {
      isMediaReady = true;
      context.read<AmityToastBloc>().add(AmityToastDismiss());
    } else {
      isMediaReady = false;
    }
  }

  Future<void> _getAppName() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appName = packageInfo.appName;
  }

  void onCameraTap(BuildContext context) {
    final localize = context.l10n;

    // Use a different context for navigation to avoid conflicts
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (dialogContext) => AmityPostCameraScreen(
          selectedType: selectedMediaType,
        ),
      ),
    )
        .then(
      (value) {
        AmityCameraResult? result = value;

        if (result != null) {
          if (result.type == FileType.video) {
            if (selectedFiles.length == 10) {
              AmityV4Dialog().showAlertErrorDialog(
                title: localize.error_max_upload_reached,
                message:
                    localize.error_max_upload_videos_reached_description(10),
                closeText: localize.general_close,
              );
            } else {
              context.read<PostComposerBloc>().add(
                    PostComposerSelectVideosEvent(selectedVideos: result.file),
                  );
            }
          } else {
            if (selectedFiles.length == 10) {
              AmityV4Dialog().showAlertErrorDialog(
                  title: localize.error_max_upload_reached,
                  message:
                      localize.error_max_upload_image_reached_description(10),
                  closeText: localize.general_close);
            } else {
              context.read<PostComposerBloc>().add(
                    PostComposerSelectImagesEvent(selectedImage: result.file),
                  );
            }
          }
        }
      },
    );
  }

  void _initializeController(BuildContext context) {
    if (options.mode == AmityPostComposerMode.edit &&
        options.post?.data is TextData) {
      final text = (options.post!.data as TextData).text ?? '';
      var mentionList = List<AmityUserMentionMetadata>.empty();

      if (options.post!.metadata != null) {
        final mentionedGetter =
            AmityMentionMetadataGetter(metadata: options.post!.metadata!);
        mentionList = mentionedGetter.getMentionedUsers();
      }

      textController.populate(text, mentionList);
    }
    textController.addListener(() {
      context
          .read<PostComposerBloc>()
          .add(PostComposerTextChangeEvent(text: textController.text));
    });
  }

  void handleClose(BuildContext context) {
    ConfirmationV4Dialog().show(
      context: context,
      title: context.l10n.post_discard,
      detailText: context.l10n.post_discard_description,
      leftButtonText: context.l10n.general_keep_editing,
      rightButtonText: context.l10n.general_discard,
      onConfirm: () {
        Navigator.pop(context);
        onPopRequested?.call(true);
      },
    );
  }

  void handleAction(BuildContext context) {
    if (options.mode == AmityPostComposerMode.edit) {
      _editPost(context);
    } else {
      _createPost(context);
    }
  }

  void _editPost(BuildContext context) {
    if (selectedMediaType == FileType.image) {
      List<AmityImage> images = existingImages.toList();
      var imageList = selectedFiles.entries;
      for (var image in imageList) {
        if (image.value.fileInfo != null &&
            image.value.fileInfo!.getFileProperties != null) {
          images.add(AmityImage(image.value.fileInfo!.getFileProperties!));
        }
      }

      options.post
          ?.edit()
          .image(images)
          .text(textController.text)
          .build()
          .update()
          .then((post) {
        Navigator.pop(context);
      }).onError((error, stackTrace) {
        _showToast(
            context, context.l10n.error_edit_post, AmityToastIcon.warning);
      });
    } else {
      final postEditBuilder = options.post?.edit();
      List<AmityVideo> videosToUpload = [];

      // First, add all existing videos that haven't been deleted
      for (var video in existingVideoObjects) {
        if (video.getFileProperties != null) {
          String videoUrl = video.getFileProperties!.fileUrl ?? "";
          // Check if this video should still be included
          // (it's still in the selectedFiles list)
          bool shouldInclude = false;
          for (var entry in selectedFiles.entries) {
            if (entry.key == videoUrl) {
              shouldInclude = true;
              break;
            }
          }

          if (shouldInclude || selectedFiles.isEmpty) {
            videosToUpload.add(video);
          }
        }
      }

      // Then add any newly uploaded videos
      for (var entry in selectedFiles.entries) {
        // Skip videos that are already in existingVideoObjects
        bool isExisting = false;
        for (var video in existingVideoObjects) {
          String url = video.getFileProperties?.fileUrl ?? "";
          if (url == entry.key) {
            isExisting = true;
            break;
          }
        }

        // If it's a new video, add it
        if (!isExisting &&
            entry.value.fileInfo != null &&
            entry.value.fileInfo!.getFileProperties != null) {
          AmityVideo video =
              AmityVideo(entry.value.fileInfo!.getFileProperties!);
          videosToUpload.add(video);
        }
      }

      if (videosToUpload.isNotEmpty) {
        postEditBuilder?.video(videosToUpload);
      } else {
        // If all videos were removed, send an empty list
        postEditBuilder?.video([]);
      }

      postEditBuilder?.text(textController.text).build().update().then((post) {
        Navigator.pop(context);
      }).onError((error, stackTrace) {
        _showToast(
            context, context.l10n.error_edit_post, AmityToastIcon.warning);
      });
    }
  }

  void _createPost(BuildContext context) {
    final targetId = options.targetId;

    context.read<AmityToastBloc>().add(AmityToastLoading(
        message: context.l10n.general_posting, icon: AmityToastIcon.loading));

    var targetBuilder = AmitySocialClient.newPostRepository().createPost();

    AmityPostCreateDataTypeSelector dataTypeSelector;
    if (options.targetType == AmityPostTargetType.COMMUNITY &&
        targetId != null) {
      dataTypeSelector = targetBuilder.targetCommunity(targetId);
    } else {
      dataTypeSelector = targetBuilder.targetMe();
    }

    PostCreator postCreatorBuilder;

    if (selectedFiles.isNotEmpty) {
      if (selectedMediaType == FileType.video) {
        List<AmityVideo> videos = [];

        for (var amityVideo in selectedFiles.entries) {
          AmityVideo video =
              AmityVideo(amityVideo.value.fileInfo!.getFileProperties!);
          videos.add(video);
        }
        postCreatorBuilder =
            dataTypeSelector.video(videos).text(textController.text);
      } else {
        List<AmityImage> images = [];
        var imageList = selectedFiles.entries;
        for (var image in imageList) {
          images.add(AmityImage(image.value.fileInfo!.getFileProperties!));
        }
        postCreatorBuilder =
            dataTypeSelector.image(images).text(textController.text);
      }
    } else {
      postCreatorBuilder = dataTypeSelector.text(textController.text);
    }
    final mentionMetadataList = textController.getAmityMentionMetadata();
    final mentionUserIds = textController.getMentionUserIds();
    final mentionMetadataJson =
        AmityMentionMetadataCreator(mentionMetadataList).create();
    addIsCreateByAdminMetadata(mentionMetadataJson);

    postCreatorBuilder
        .mentionUsers(mentionUserIds)
        .metadata(mentionMetadataJson)
        .post()
        .then((post) {
      _onPostSuccess(context, post);
    }).onError((error, stackTrace) {
      _showToast(
          context, context.l10n.error_create_post, AmityToastIcon.warning);
    });
  }

  void _onPostSuccess(BuildContext context, AmityPost post) {
    context.read<AmityToastBloc>().add(AmityToastDismiss());
    Future.delayed(const Duration(milliseconds: 500), () {
      context.read<GlobalFeedBloc>().add(GlobalFeedAddLocalPost(post: post));
      Navigator.pop(context);
      onPopRequested?.call(true);
    });
  }

  void _showToast(BuildContext context, String message, AmityToastIcon icon) {
    context
        .read<AmityToastBloc>()
        .add(AmityToastShort(message: message, icon: icon));
  }
}
