import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/components/alert_dialog.dart';

import 'package:amity_uikit_beta_service/view/UIKit/social/community_setting/posts/post_cpmponent.dart';

import 'package:amity_uikit_beta_service/viewmodel/configuration_viewmodel.dart';
import 'package:amity_uikit_beta_service/viewmodel/create_postV2_viewmodel.dart';
// import 'package:amity_uikit_beta_service/viewmodel/create_post_viewmodel.dart';
// import 'package:amity_uikit_beta_service/viewmodel/media_viewmodel.dart';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class AmityCreatePostV2Screen extends StatefulWidget {
  final AmityCommunity? community;

  const AmityCreatePostV2Screen({
    super.key,
    this.community,
  });

  @override
  State<AmityCreatePostV2Screen> createState() =>
      _AmityCreatePostV2ScreenState();
}

class _AmityCreatePostV2ScreenState extends State<AmityCreatePostV2Screen> {
  bool hasContent = true;

  @override
  void initState() {
    Provider.of<CreatePostVMV2>(context, listen: false).inits();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<CreatePostVMV2>(builder: (context, vm, _) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            widget.community != null
                ? widget.community?.displayName ?? "Community"
                : "My Feed",
            style: Provider.of<AmityUIConfiguration>(context).titleTextStyle,
          ),
          leading: IconButton(
            icon: Icon(
              Icons.chevron_left,
              color: Colors.black,
            ),
            onPressed: () {
              if (hasContent) {
                ConfirmationDialog().show(
                  context: context,
                  title: 'Discard Post?',
                  detailText: 'Do you want to discard your post?',
                  leftButtonText: 'Cancel',
                  rightButtonText: 'Discard',
                  onConfirm: () {
                    Navigator.of(context).pop();
                  },
                );
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: hasContent
                  ? () async {
                      print(vm.isUploadComplete);
                      if (vm.isUploadComplete) {
                        if (widget.community == null) {
                          //creat post in user Timeline
                          await vm.createPost(context,
                              callback: (isSuccess, error) {
                            if (isSuccess) {
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            } else {}
                          });
                        } else {
                          //create post in Community
                          await vm.createPost(context,
                              communityId: widget.community?.communityId!,
                              callback: (isSuccess, error) {
                            if (isSuccess) {
                              Navigator.of(context).pop();
                            }
                          });
                        }
                      }
                    }
                  : null,
              child: Text("Post",
                  style: TextStyle(
                      color: vm.isPostValid
                          ? Provider.of<AmityUIConfiguration>(context)
                              .primaryColor
                          : Colors.grey)),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextField(
                          onChanged: (value) => vm.updatePostValidity(),
                          controller: vm.textEditingController,
                          scrollPhysics: const NeverScrollableScrollPhysics(),
                          maxLines: null,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "Write something to post",
                          ),
                          // style: t/1heme.textTheme.bodyText1.copyWith(color: Colors.grey),
                        ),
                        Consumer<CreatePostVMV2>(
                          builder: (context, vm, _) =>
                              PostMedia(files: vm.files),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Divider(),
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _iconButton(
                      Icons.camera_alt_outlined,
                      isEnable:
                          vm.availableFileSelectionOptions()[MyFileType.image]!,
                      label: "Photo",
                      // debugingText:
                      //     "${vm2.isNotSelectVideoYet()}&& ${vm2.isNotSelectedFileYet()}",
                      onTap: () {
                        _handleCameraTap(context);
                      },
                    ),
                    _iconButton(
                      Icons.image_outlined,
                      label: "Image",
                      isEnable:
                          vm.availableFileSelectionOptions()[MyFileType.image]!,
                      onTap: () async {
                        _handleImageTap(context);
                      },
                    ),
                    _iconButton(
                      Icons.play_circle_outline,
                      label: "Video",
                      isEnable:
                          vm.availableFileSelectionOptions()[MyFileType.video]!,
                      onTap: () async {
                        _handleVideoTap(context);
                      },
                    ),
                    _iconButton(
                      Icons.attach_file_outlined,
                      label: "File",
                      isEnable:
                          vm.availableFileSelectionOptions()[MyFileType.file]!,
                      onTap: () async {
                        _handleFileTap(context);
                      },
                    ),
                    _iconButton(
                      Icons.more_horiz,
                      isEnable: true,
                      label: "More",
                      onTap: () {
                        // TODO: Implement more options logic
                        _showMoreOptions(context);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _iconButton(IconData icon,
      {required String label,
      required VoidCallback onTap,
      required bool isEnable,
      String? debugingText}) {
    return Column(
      children: [
        debugingText == null ? SizedBox() : Text(debugingText),
        CircleAvatar(
          radius: 16,
          backgroundColor: Colors.grey[200],
          child: IconButton(
            icon: Icon(
              icon,
              size: 18,
              color: isEnable ? Colors.black : Colors.grey,
            ),
            onPressed: () {
              if (isEnable) {
                onTap();
              }
            },
          ),
        ),
        // SizedBox(height: 4),
        // Text(label),
      ],
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15.0),
              topRight: Radius.circular(15.0),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(top: 16.0), // Space at the top
              child: Wrap(
                children: <Widget>[
                  ListTile(
                    leading: _iconButton(Icons.camera_alt_outlined,
                        isEnable: true, label: "Camera", onTap: () {}),
                    title: Text('Camera'),
                    onTap: () {
                      _handleCameraTap(context);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: _iconButton(Icons.image_outlined,
                        isEnable: true, label: "Photo", onTap: () {}),
                    title: Text('Photo'),
                    onTap: () {
                      _handleImageTap(context);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: _iconButton(Icons.attach_file_rounded,
                        isEnable: true, label: "Attachment", onTap: () {}),
                    title: Text('Attachment'),
                    onTap: () {
                      _handleFileTap(context);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: _iconButton(Icons.play_circle_outline_outlined,
                        isEnable: true, label: "Video", onTap: () {}),
                    title: Text('Video'),
                    onTap: () {
                      _handleVideoTap(context);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDiscardDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Discard Post?'),
        content: Text('Do you want to discard your post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              Navigator.of(context).pop();
            },
            child: Text('Discard'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCameraTap(BuildContext context) async {
    await _pickMedia(context, PickerAction.cameraImage);
  }

  Future<void> _handleImageTap(BuildContext context) async {
    await _pickMedia(context, PickerAction.galleryImage);
  }

  Future<void> _handleVideoTap(BuildContext context) async {
    await _pickMedia(context, PickerAction.galleryVideo);
  }

  Future<void> _handleFileTap(BuildContext context) async {
    await _pickMedia(context, PickerAction.filePicker);
  }

  Future<void> _pickMedia(BuildContext context, PickerAction action) async {
    var createPostVM = Provider.of<CreatePostVMV2>(context, listen: false);
    await createPostVM.pickFile(action);
  }
}
