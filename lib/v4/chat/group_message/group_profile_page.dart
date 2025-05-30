import 'dart:io';

import 'package:amity_uikit_beta_service/v4/core/base_page.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/amity_uikit_toast.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/utils/amity_dialog.dart';
import 'package:amity_uikit_beta_service/v4/utils/media_permission_handler.dart';
import 'package:amity_uikit_beta_service/v4/social/post_composer_page/post_camera_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:amity_sdk/amity_sdk.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';

part 'group_profile_cubit.dart';
part 'group_profile_state.dart';

class GroupProfilePage extends NewBasePage {
  final AmityChannel channel;

  GroupProfilePage({Key? key, required this.channel})
      : super(key: key, pageId: 'group_profile_page');

  @override
  Widget buildPage(BuildContext context) {
    return BlocProvider(
      create: (_) => GroupProfileCubit(channel),
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              backgroundColor: theme.backgroundColor,
              title: const Text('Group profile'),
              actions: [
                BlocBuilder<GroupProfileCubit, GroupProfileState>(
                  builder: (context, state) {
                    final hasChanged =
                        state is GroupProfileLoaded ? state.hasChanged : false;
                    return TextButton(
                      onPressed: hasChanged
                          ? () {
                              _saveGroupProfile(context, state);
                            }
                          : null,
                      child: Text(
                        'Save',
                        style: TextStyle(
                          color: hasChanged
                              ? theme.primaryColor
                              : theme.primaryColor
                                  .blend(ColorBlendingOption.shade2),
                        ),
                      ),
                    );
                  },
                ),
              ],
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: BlocBuilder<GroupProfileCubit, GroupProfileState>(
              builder: (context, state) {
                if (state is GroupProfileLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is GroupProfileLoaded) {
                  return Container(
                    color: theme.backgroundColor,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Group Image Picker
                          Center(
                            child: Column(
                              children: [
                                BlocBuilder<GroupProfileCubit,
                                    GroupProfileState>(
                                  builder: (context, state) {
                                    if (state is! GroupProfileLoaded)
                                      return const SizedBox();

                                    return GestureDetector(
                                      onTap: () {
                                        _showBottomSheet(context);
                                      },
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Container(
                                            width: 120,
                                            height: 120,
                                            decoration: BoxDecoration(
                                              color: theme.primaryColor.blend(
                                                  ColorBlendingOption.shade2),
                                              borderRadius:
                                                  BorderRadius.circular(24),
                                              image: (state.selectedImagePath !=
                                                      null)
                                                  ? DecorationImage(
                                                      image: FileImage(File(state
                                                          .selectedImagePath!)),
                                                      fit: BoxFit.cover,
                                                    )
                                                  : (state.imagePath != null)
                                                      ? DecorationImage(
                                                          image: FileImage(File(
                                                              state
                                                                  .imagePath!)),
                                                          fit: BoxFit.cover,
                                                        )
                                                      : (channel.avatar
                                                                      ?.fileUrl !=
                                                                  null &&
                                                              channel
                                                                  .avatar!
                                                                  .fileUrl!
                                                                  .isNotEmpty)
                                                          ? DecorationImage(
                                                              image: NetworkImage(
                                                                  channel
                                                                      .avatar!
                                                                      .fileUrl!),
                                                              fit: BoxFit.cover,
                                                            )
                                                          : null,
                                            ),
                                            child: (state.selectedImagePath ==
                                                        null &&
                                                    state.imagePath == null &&
                                                    (channel.avatar?.fileUrl ==
                                                            null ||
                                                        channel.avatar!.fileUrl!
                                                            .isEmpty))
                                                ? Center(
                                                    child: SvgPicture.asset(
                                                      'assets/Icons/amity_ic_group_chat_avatar_placeholder.svg',
                                                      package:
                                                          'amity_uikit_beta_service',
                                                      width: 40,
                                                      height: 40,
                                                    ),
                                                  )
                                                : null,
                                          ),
                                          // Camera icon overlay
                                          Container(
                                            width: 120,
                                            height: 120,
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.black.withOpacity(0.3),
                                              borderRadius:
                                                  BorderRadius.circular(24),
                                            ),
                                            child: Center(
                                              child: SvgPicture.asset(
                                                'assets/Icons/amity_ic_camera.svg',
                                                package: 'amity_uikit_beta_service',
                                                width: 32,
                                                height: 28,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),

                          // Group Name Field
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Group name ',
                                          style: AmityTextStyle.titleBold(
                                              theme.baseColor),
                                        ),
                                        TextSpan(
                                          text: '(Required)',
                                          style: AmityTextStyle.caption(
                                              theme.baseColorShade3),
                                        ),
                                      ],
                                    ),
                                  ),
                                  BlocBuilder<GroupProfileCubit,
                                      GroupProfileState>(
                                    builder: (context, state) {
                                      final count = state is GroupProfileLoaded
                                          ? state.charCount
                                          : 0;
                                      return Text(
                                        '$count/100',
                                        style: AmityTextStyle.caption(
                                          count > 100
                                              ? Colors.red
                                              : theme.baseColorShade2,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: context
                                    .read<GroupProfileCubit>()
                                    .nameController,
                                decoration: InputDecoration(
                                  hintText: 'Enter group name',
                                  hintStyle: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 18,
                                  ),
                                  contentPadding: EdgeInsets.only(bottom: 8),
                                  border: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade300),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade300),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: theme.primaryColor),
                                  ),
                                  counterText: '', // Hide the default counter
                                ),
                                maxLength: 100, // Still enforce the limit
                                style: AmityTextStyle.body(theme.baseColor),
                                keyboardType: TextInputType.multiline,
                                maxLines: null, // Allow unlimited lines
                                textInputAction: TextInputAction.newline,
                                buildCounter: (context,
                                    {required currentLength,
                                    required isFocused,
                                    maxLength}) {
                                  return null; // Return null to hide the default counter
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return const Center(child: Text('Error loading profile'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // Save group profile method moved from AppBar action
  void _saveGroupProfile(BuildContext context, GroupProfileLoaded state) {
    final cubit = BlocProvider.of<GroupProfileCubit>(context);

    if (state.selectedImagePath != null) {
      final file = File(state.selectedImagePath!);
      AmityCoreClient.newFileRepository()
          .uploadImage(file)
          .stream
          .listen((amityUploadResult) {
        amityUploadResult.when(
          progress: (uploadInfo, cancelToken) {},
          complete: (file) {
            AmityChatClient.newChannelRepository()
                .updateChannel(channel.channelId ?? "")
                .displayName(cubit.nameController.text)
                .avatar(file)
                .create()
                .then((updatedChannel) {
              // Show success toast
              if (context.mounted) {
                context.read<AmityToastBloc>().add(const AmityToastShort(
                    message: "Group profile updated.",
                    icon: AmityToastIcon.success));
                Navigator.pop(
                    context, {'status': 'success', 'channel': updatedChannel});
              }
            }).catchError((error) {
              // Show error toast
              if (context.mounted) {
                context.read<AmityToastBloc>().add(const AmityToastShort(
                    message: "Failed to update group profile. Please try again.",
                    icon: AmityToastIcon.warning));
                Navigator.pop(context, {'status': 'error'});
              }
            });
          },
          error: (error) {
            // Handle upload errors with more specific feedback
            final Map<String, dynamic>? errorData = 
                error.data is Map<String, dynamic> ? error.data as Map<String, dynamic> : null;
            
            String errorMessage = "Please try again.";
            String errorTitle = "Upload Failed";
            
            if (errorData != null) {
              final int? uploadErrorCode = errorData["detail"]?["error"]?["code"];
              if (uploadErrorCode == 403) {
                errorTitle = "Inappropriate Content";
                errorMessage = "Inappropriate image. Please choose a different image to upload.";
              }
            }
            
            // Show error dialog for upload failures
            AmityV4Dialog().showAlertErrorDialog(
              title: errorTitle,
              message: errorMessage,
              closeText: 'OK',
            );
          },
          cancel: () {
            // Show toast for cancelled upload
            if (context.mounted) {
              context.read<AmityToastBloc>().add(const AmityToastShort(
                  message: "Image upload cancelled.",
                  icon: AmityToastIcon.warning));
            }
          },
        );
      });
    } else {
      // Update only the display name
      AmityChatClient.newChannelRepository()
          .updateChannel(channel.channelId ?? "")
          .displayName(cubit.nameController.text)
          .create()
          .then((updatedChannel) {
        // Show success toast
        if (context.mounted) {
          context.read<AmityToastBloc>().add(const AmityToastShort(
              message: "Group profile updated successfully.",
              icon: AmityToastIcon.success));
          Navigator.pop(
              context, {'status': 'success', 'channel': updatedChannel});
        }
      }).catchError((error) {
        // Show error toast
        if (context.mounted) {
          context.read<AmityToastBloc>().add(const AmityToastShort(
              message: "Failed to update group profile. Please try again.",
              icon: AmityToastIcon.warning));
          Navigator.pop(context, {'status': 'error'});
        }
      });
    }
  }

  // Add method to show bottom sheet for image selection
  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        backgroundColor: theme.backgroundColor,
        builder: (_) {
          return SizedBox(
            height: 200,
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 36,
                  padding: const EdgeInsets.only(top: 12, bottom: 20),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 36,
                        height: 4,
                        decoration: ShapeDecoration(
                          color: theme.baseColorShade3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildListTile(
                  assetPath: 'assets/Icons/amity_ic_camera_button.svg',
                  title: 'Camera',
                  onTap: () {
                    Navigator.pop(context);
                    _goToCameraPage(context);
                  },
                ),
                _buildListTile(
                    assetPath: 'assets/Icons/amity_ic_image_button.svg',
                    title: 'Photo',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(context);
                    })
              ],
            ),
          );
        });
  }

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

  void _goToCameraPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => AmityPostCameraScreen(
          selectedType: FileType.image,
        ),
      ),
    ).then(
      (value) {
        AmityCameraResult? result = value;
        if (result != null) {
          context.read<GroupProfileCubit>().updateSelectedImage(result.file.path);
        }
      },
    );
  }

  // Add method to pick an image using existing cubit method
  Future<void> _pickImage(BuildContext context) async {
    context.read<GroupProfileCubit>().pickImage();
  }
}
