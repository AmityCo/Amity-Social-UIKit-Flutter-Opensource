import 'dart:async';
import 'dart:io';

import 'dart:math';
import 'package:amity_sdk/amity_sdk.dart';
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
  FileType? selectedMediaType;
  Map<String, AmityImage> existingImages = {};
  Map<String, VideoData> existingVideos = {};
  List<AmityVideo>? currentVideos;
  bool isPostButtonEnabled = false;
  bool isTextChanged = false;
  bool isFileCountChanged = false;
  bool isMediaReady = false;
  String appName = '';

  AmityPostComposerPage({Key? key, required this.options, this.onPopRequested})
      : super(key: key, pageId: '');

  @override
  Widget buildPage(BuildContext context) {
    _getAppName();
    String? communityId = (options.targetType == AmityPostTargetType.COMMUNITY &&
        options.targetId != null)
        ? options.targetId
        : null;

    if (options.mode == AmityPostComposerMode.edit) {
      AmityPost post = options.post!;
      currentPostText = (post.data as TextData).text ?? '';

      if (post.children?.isNotEmpty ?? false) {
        for (var child in post.children!) {
          var postData = child.data;
          if (postData is VideoData) {
            var data = postData;
            var url =
                data.thumbnail?.getUrl(AmityImageSize.MEDIUM) ?? data.postId;

            existingVideos[url] = (data);

            selectedMediaType = FileType.video;
          } else if (postData is ImageData) {
            var data = postData;
            var url = data.image?.getUrl(AmityImageSize.MEDIUM);
            existingImages[url!] = (data.image!);
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
                List<String> uploadedUrlsKeys = existingImages.keys.toList();
                context.read<PostComposerBloc>().add(
                      PostComposerGetImageUrlsEvent(urls: uploadedUrlsKeys),
                    );
              } else if (selectedMediaType == FileType.video) {
                List<VideoData> uploadedUrlsKeys =
                    existingVideos.values.toList();
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

              if (options.mode == AmityPostComposerMode.create) {
                if (state.selectedFiles.isEmpty) {
                  isPostButtonEnabled = false;
                  selectedMediaType = null;
                } else {
                  bool isAllImageUploaded = selectedFiles.values
                      .every((image) => image.isUploaded == true);

                  if (selectedFiles.entries.first.value.type ==
                      FileType.video) {
                    selectedMediaType = FileType.video;
                  } else if (selectedFiles.entries.first.value.type ==
                      FileType.image) {
                    selectedMediaType = FileType.image;
                  }
                  if (isAllImageUploaded) {
                    isMediaReady = true;
                    context.read<AmityToastBloc>().add(AmityToastDismiss());
                  } else {
                    isMediaReady = false;
                  }
                  updatePostButtonStatus();
                }
              } else {
                if (selectedMediaType == FileType.image) {
                  if (currentUrlsCount != selectedFiles.length) {
                    isFileCountChanged = true;
                  } else {
                    isFileCountChanged = false;
                  }
                } else if (selectedMediaType == FileType.video) {
                  if (currentUrlsCount != selectedFiles.length) {
                    isFileCountChanged = true;
                  } else {
                    isFileCountChanged = false;
                  }
                }
                updatePostButtonStatus();

                currentVideos = state.currentVideos;
              }
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
                                const SizedBox(height: 20),
                                buildTextField(context, communityId, minBottomSheetSize, maxBottomSheetSize),
                                const SizedBox(height: 20),
                                Container(
                                  color: Colors.transparent,
                                  child: mediaListView(context, selectedFiles),
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (options.mode == AmityPostComposerMode.create)
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
    if (isTextChanged || isFileCountChanged || isMediaReady) {
      isPostButtonEnabled = true;
    } else {
      isPostButtonEnabled = false;
    }
  }

  Future<void> _getAppName() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appName = packageInfo.appName;
  }

  void onCameraTap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AmityPostCameraScreen(
          selectedType: selectedMediaType,
        ),
      ),
    ).then(
      (value) {
        AmityCameraResult? result = value;

        if (result != null) {
          if (result.type == FileType.video) {
            if (selectedFiles.length == 10) {
              AmityV4Dialog().showAlertErrorDialog(
                title: "Maximum upload limit reached",
                message:
                    "You’ve reached the upload limit of 10 vidoes. Any additional videos will not be saved.",
                closeText: "Close",
              );
            } else {
              context.read<PostComposerBloc>().add(
                    PostComposerSelectVideosEvent(selectedVideos: result.file),
                  );
            }
          } else {
            if (selectedFiles.length == 10) {
              AmityV4Dialog().showAlertErrorDialog(
                title: "Maximum upload limit reached",
                message:
                    "You’ve reached the upload limit of 10 images. Any additional images will not be saved.",
                closeText: "Close",
              );
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

      if(options.post!.metadata != null) {
        final mentionedGetter = AmityMentionMetadataGetter(
            metadata: options.post!.metadata!);
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
      title: 'Discard this post?',
      detailText: 'The post will be permanently deleted. It cannot be undone.',
      leftButtonText: 'Keep editing',
      rightButtonText: 'Discard',
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
      List<AmityImage> images = existingImages.values.toList();
      options.post
          ?.edit()
          .image(images)
          .text(textController.text)
          .build()
          .update()
          .then((post) {
        Navigator.pop(context);
      }).onError((error, stackTrace) {
        _showToast(context, "Failed to edit post. Please try again.",
            AmityToastIcon.warning);
      });
    } else {
      final postEditBuilder = options.post?.edit();

      if (currentVideos != null) {
        postEditBuilder?.video(currentVideos!);
      }
      postEditBuilder
          ?.text(textController.text)
          .build()
          .update()
          .then((post) {
        Navigator.pop(context);
      }).onError((error, stackTrace) {
        _showToast(context, "Failed to edit post. Please try again.",
            AmityToastIcon.warning);
      });
    }
  }

  void _createPost(BuildContext context) {
    final targetId = options.targetId;

    context.read<AmityToastBloc>().add(const AmityToastLoading(
        message: "Posting", icon: AmityToastIcon.loading));

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
        postCreatorBuilder = dataTypeSelector
            .video(videos)
            .text(textController.text);
      } else {
        List<AmityImage> images = [];
        var imageList = selectedFiles.entries;
        for (var image in imageList) {
          images.add(AmityImage(image.value.fileInfo!.getFileProperties!));
        }
        postCreatorBuilder = dataTypeSelector
            .image(images)
            .text(textController.text);
      }
    } else {
      postCreatorBuilder = dataTypeSelector
          .text(textController.text);
    }
    final mentionMetadataList = textController.getAmityMentionMetadata();
    final mentionUserIds = textController.getMentionUserIds();
    final mentionMetadataJson =
        AmityMentionMetadataCreator(mentionMetadataList).create();

    postCreatorBuilder
        .mentionUsers(mentionUserIds)
        .metadata(mentionMetadataJson)
        .post()
        .then((post) {
      _onPostSuccess(context, post);
    }).onError((error, stackTrace) {
      _showToast(context, "Failed to create post. Please try again.",
          AmityToastIcon.warning);
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
