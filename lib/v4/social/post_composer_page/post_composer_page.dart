import 'dart:async';
import 'dart:io';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/base_page.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/amity_uikit_toast.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/globalfeed/bloc/global_feed_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/post_composer_page/bloc/post_composer_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/post_composer_page/detailed_media_attachment_component.dart';
import 'package:amity_uikit_beta_service/v4/social/post_composer_page/media_attachment_component.dart';
import 'package:amity_uikit_beta_service/v4/social/post_composer_page/post_camera_screen.dart';
import 'package:amity_uikit_beta_service/v4/social/post_composer_page/post_composer_model.dart';
import 'package:amity_uikit_beta_service/v4/utils/CustomBottomSheet/custom_buttom_sheet.dart';
import 'package:amity_uikit_beta_service/v4/utils/SingleVideoPlayer/single_video_player.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:amity_uikit_beta_service/v4/utils/amity_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class PostComposerPage extends NewBasePage {
  final AmityPostComposerOptions options;
  final TextEditingController _controller = TextEditingController(text: '');
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

  PostComposerPage({Key? key, required this.options, this.onPopRequested})
      : super(key: key, pageId: '');

  @override
  Widget buildPage(BuildContext context) {
    _getAppName();
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
              _controller.text = state.text;
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
            if (selectedMediaType != null) {
              // 0.8 per item
              maxBottomSheetSize = 0.22;
            }

            return Scaffold(
              backgroundColor: theme.backgroundColor,
              appBar: _buildAppBar(context),
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
                                _buildTextField(),
                                const SizedBox(height: 20),
                                Container(
                                  color: Colors.transparent,
                                  child: _mediaListView(context, selectedFiles),
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
                      minSize: 0.125,
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

  void pickMultipleFiles(BuildContext context, FileType type,
      {int maxFiles = 10}) async {
    try {
      String typeText;
      List<XFile> files = [];

      if (type == FileType.video) {
        typeText = 'videos';

        pickVideos() async {
          FilePickerResult? result = await FilePicker.platform.pickFiles(
            type: type,
            allowMultiple: true,
            allowCompression: true,
            withData: false,
            withReadStream: true,
            lockParentWindow: true,
            onFileLoading: (status) => {
              if (status == FilePickerStatus.done)
                {context.read<AmityToastBloc>().add(AmityToastDismiss())}
              else
                {
                  context.read<AmityToastBloc>().add(const AmityToastLoading(
                      message: "Processing...", icon: AmityToastIcon.loading))
                }
            },
          );

          if (result != null) {
            files = result.files
                .where((file) => file.path != null)
                .map((file) => XFile(file.path!))
                .toList();
          }
        }

        showPermissionDialog() async {
          ConfirmationV4Dialog().show(
            context: context,
            title: 'Allow access to your vidoes',
            detailText: 'This allows $appName to access vidoes on your device.',
            leftButtonColor: null,
            leftButtonText: 'OK',
            rightButtonText: 'Open settings',
            onConfirm: () {
              openAppSettings();
            },
          );
        }

        try {
          if (Platform.isAndroid) {
            var androidInfo = await DeviceInfoPlugin().androidInfo;
            var sdkInt = androidInfo.version.sdkInt;

            if (sdkInt > 32) {
              await pickVideos();
            } else {
              if (await Permission.storage.request().isGranted) {
                await pickVideos();
              } else {
                await showPermissionDialog();
              }
            }
          } else {
            await pickVideos();
          }
        } catch (e) {
          await showPermissionDialog();
        }
      } else {
        typeText = 'images';
        bool isPickerClosed = false;

        Future.delayed(const Duration(milliseconds: 1000), () {
          if (!isPickerClosed) {
            context.read<AmityToastBloc>().add(const AmityToastLoading(
                message: "Processing...", icon: AmityToastIcon.loading));
          }
        });
        try {
          files = await imagePicker.pickMultiImage(limit: 10);
          isPickerClosed = true;
          context.read<AmityToastBloc>().add(AmityToastDismiss());
        } catch (e) {
          isPickerClosed = true;

          PermissionAlertV4Dialog().show(
            context: context,
            title: 'Allow access to your photos',
            detailText:
                'This allows $appName to share photos from this device and save photos to it.',
            bottomButtonText: 'OK',
            topButtonText: 'Open settings',
            onTopButtonAction: () {
              openAppSettings();
            },
          );
          context.read<AmityToastBloc>().add(AmityToastDismiss());
        }
      }

      if (files.isNotEmpty) {
        if (selectedFiles.length + files.length > 10) {
          AmityV4Dialog().showAlertErrorDialog(
            title: "Maximum upload limit reached",
            message:
                "You’ve reached the upload limit of 10 $typeText. Any additional $typeText will not be saved.",
            closeText: "Close",
          );
        } else {
          if (type == FileType.image) {
            for (var image in files) {
              context.read<PostComposerBloc>().add(
                    PostComposerSelectImagesEvent(selectedImage: image),
                  );
            }
          } else {
            for (var video in files) {
              context.read<PostComposerBloc>().add(
                    PostComposerSelectVideosEvent(selectedVideos: video),
                  );
            }
          }
        }
      } else {
        context.read<AmityToastBloc>().add(AmityToastDismiss());
      }
    } catch (e) {
      print(e.toString());
    }
    return null;
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

  Widget _mediaListView(
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

  void _initializeController(BuildContext context) {
    if (options.mode == AmityPostComposerMode.edit &&
        options.post?.data is TextData) {
      _controller.text = (options.post!.data as TextData).text ?? '';
    }
    _controller.addListener(() {
      context
          .read<PostComposerBloc>()
          .add(PostComposerTextChangeEvent(text: _controller.text));
    });
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: theme.backgroundColor,
      title: Text(
        _getPageTitle(),
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
        onPressed: () => _handleClose(context),
      ),
      centerTitle: true,
      actions: [_buildActionButton(context)],
    );
  }

  String _getPageTitle() {
    if (options.mode == AmityPostComposerMode.edit) {
      return "Edit Post";
    } else if (options.targetType == AmityPostTargetType.USER) {
      return "My Timeline";
    } else {
      return options.community?.displayName ?? '';
    }
  }

  Widget _buildActionButton(BuildContext context) {
    return TextButton(
      onPressed: isPostButtonEnabled ? () => _handleAction(context) : null,
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

  void _handleClose(BuildContext context) {
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

  void _handleAction(BuildContext context) {
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
          .text(_controller.text)
          .build()
          .update()
          .then((post) {
        context.read<GlobalFeedBloc>().add(GlobalFeedReloadThePost(post: post));
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

      postEditBuilder?.text(_controller.text).build().update().then((post) {
        context.read<GlobalFeedBloc>().add(GlobalFeedReloadThePost(post: post));
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
        postCreatorBuilder =
            dataTypeSelector.video(videos).text(_controller.text);
      } else {
        List<AmityImage> images = [];
        var imageList = selectedFiles.entries;
        for (var image in imageList) {
          images.add(AmityImage(image.value.fileInfo!.getFileProperties!));
        }
        postCreatorBuilder =
            dataTypeSelector.image(images).text(_controller.text);
      }
    } else {
      postCreatorBuilder = dataTypeSelector.text(_controller.text);
    }

    postCreatorBuilder.post().then((post) {
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

  Widget _buildTextField() {
    return TextFormField(
      controller: _controller,
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
}
