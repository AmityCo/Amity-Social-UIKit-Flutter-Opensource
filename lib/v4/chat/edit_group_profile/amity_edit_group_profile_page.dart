import 'dart:io';

import 'package:amity_uikit_beta_service/v4/core/base_page.dart';
import 'package:amity_uikit_beta_service/v4/core/theme/amity_color_token.dart';
import 'package:amity_uikit_beta_service/v4/core/theme/amity_token_context.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/amity_uikit_toast.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/utils/amity_dialog.dart';
import 'package:amity_uikit_beta_service/v4/utils/media_permission_handler.dart';
import 'package:amity_uikit_beta_service/v4/social/post_composer_page/post_camera_screen.dart';
import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:amity_sdk/amity_sdk.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';

part 'amity_edit_group_profile_cubit.dart';
part 'amity_edit_group_profile_state.dart';

class AmityEditGroupProfilePage extends NewBasePage {
  final AmityChannel channel;

  AmityEditGroupProfilePage({Key? key, required this.channel})
      : super(key: key, pageId: 'edit_group_profile_page');

  @override
  Widget buildPage(BuildContext context) {
    return BlocProvider(
      create: (_) => AmityEditGroupProfileCubit(channel),
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              backgroundColor: token(AmityColorToken.surfacePageBackgroundDefault),
              title: Text(
                context.l10n.chat_group_profile_title,
                style: AmityTextStyle.titleBold(
                    token(AmityColorToken.textSheetsHeaderTitleDefault)),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(
                  height: 1,
                  color: token(AmityColorToken.lineDividerPostDefault),
                ),
              ),
              actions: [
                BlocBuilder<AmityEditGroupProfileCubit, AmityEditGroupProfileState>(
                  builder: (context, state) {
                    final hasChanged =
                        state is AmityEditGroupProfileLoaded ? state.hasChanged : false;
                    return TextButton(
                      onPressed: hasChanged
                          ? () {
                              _saveGroupProfile(context, state);
                            }
                          : null,
                      child: Text(
                        context.l10n.general_save,
                        style: TextStyle(
                          color: hasChanged
                              ? token(AmityColorToken.textMainButtonDefaultGhostPrimaryEnabled)
                              : token(AmityColorToken.textMainButtonDefaultGhostPrimaryDisabled),
                        ),
                      ),
                    );
                  },
                ),
              ],
              leading: IconButton(
                icon: SvgPicture.asset(
                  'assets/Icons/amity_ic_close_button.svg',
                  package: 'amity_uikit_beta_service',
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                      token(AmityColorToken.iconIconButtonGhostSecondaryDefault),
                      BlendMode.srcIn),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: BlocBuilder<AmityEditGroupProfileCubit, AmityEditGroupProfileState>(
              builder: (context, state) {
                if (state is AmityEditGroupProfileLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is AmityEditGroupProfileLoaded) {
                  return Container(
                    color: token(AmityColorToken.surfacePageBackgroundDefault),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Group Image Picker
                          Center(
                            child: Column(
                              children: [
                                BlocBuilder<AmityEditGroupProfileCubit,
                                    AmityEditGroupProfileState>(
                                  builder: (context, state) {
                                    if (state is! AmityEditGroupProfileLoaded)
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
                                              color: token(AmityColorToken.surfaceAvatarProfileDefault),
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
                                                      width: 64,
                                                      height: 64,
                                                      colorFilter: ColorFilter.mode(
                                                          token(AmityColorToken
                                                              .iconAvatarDefault),
                                                          BlendMode.srcIn),
                                                    ),
                                                  )
                                                : null,
                                          ),
                                          // Camera icon overlay
                                          Container(
                                            width: 120,
                                            height: 120,
                                            decoration: BoxDecoration(
                                              color: token(AmityColorToken
                                                  .surfaceMediaOverlayTransparentBlack),
                                              borderRadius:
                                                  BorderRadius.circular(24),
                                            ),
                                            child: Center(
                                              child: SvgPicture.asset(
                                                'assets/Icons/amity_ic_camera_r.svg',
                                                package: 'amity_uikit_beta_service',
                                                width: 64,
                                                height: 64,
                                                colorFilter: ColorFilter.mode(
                                                    token(AmityColorToken
                                                        .iconAvatarDefault),
                                                    BlendMode.srcIn),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 40),
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
                                          text: context.l10n.chat_group_name_label,
                                          style: AmityTextStyle.titleBold(
                                              token(AmityColorToken.textListHeaderDefaultDefault)),
                                        ),
                                        TextSpan(
                                          text: ' ${context.l10n.chat_group_name_required}',
                                          style: AmityTextStyle.caption(
                                              token(AmityColorToken.textInputTextInputIndicatorDefault)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  BlocBuilder<AmityEditGroupProfileCubit,
                                      AmityEditGroupProfileState>(
                                    builder: (context, state) {
                                      final count = state is AmityEditGroupProfileLoaded
                                          ? state.charCount
                                          : 0;
                                      return Text(
                                        '$count/100',
                                        style: AmityTextStyle.caption(
                                          count > 100
                                              ? Colors.red
                                              : token(AmityColorToken.textInputTextInputTextCountDefault),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              TextField(
                                controller: context
                                    .read<AmityEditGroupProfileCubit>()
                                    .nameController,
                                keyboardAppearance: context.amityBrightness,
                                decoration: InputDecoration(
                                  hintText: context.l10n.chat_group_name_hint,
                                  hintStyle: AmityTextStyle.body(token(
                                      AmityColorToken
                                          .textInputTextInputPlaceholderEnabledFilled)),
                                  contentPadding: EdgeInsets.only(bottom: 8),
                                  border: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: token(AmityColorToken
                                            .lineInputTextInputUnderlinedDefault)),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: token(AmityColorToken
                                            .lineInputTextInputUnderlinedDefault)),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(
                                        color: token(AmityColorToken
                                            .lineInputTextInputUnderlinedDefault)),
                                  ),
                                  counterText: '', // Hide the default counter
                                ),
                                maxLength: 100, // Still enforce the limit
                                style: AmityTextStyle.body(token(AmityColorToken.textListHeaderDefaultDefault)),
                                keyboardType: TextInputType.text,
                                maxLines: 1,
                                textInputAction: TextInputAction.done,
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
                  return Center(child: Text(context.l10n.chat_group_profile_error));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // Save group profile method moved from AppBar action
  void _saveGroupProfile(BuildContext context, AmityEditGroupProfileLoaded state) {
    final cubit = BlocProvider.of<AmityEditGroupProfileCubit>(context);
    // The upload callbacks fire after the page may be gone, so resolve strings now.
    final l10n = context.l10n;

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
                context.read<AmityToastBloc>().add(AmityToastShort(
                    message: context.l10n.toast_group_profile_updated,
                    icon: AmityToastIcon.success));
                Navigator.pop(
                    context, {'status': 'success', 'channel': updatedChannel});
              }
            }).catchError((error) {
              // Show error toast
              if (context.mounted) {
                context.read<AmityToastBloc>().add(AmityToastShort(
                    message: context.l10n.toast_group_profile_error,
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
                errorTitle = l10n.profile_edit_inappropriate_image_title;
                errorMessage = l10n.profile_edit_inappropriate_image_description;
              }
            }
            
            // Show error dialog for upload failures
            AmityV4Dialog().showAlertErrorDialog(
              title: errorTitle,
              message: errorMessage,
              closeText: l10n.general_ok,
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
          context.read<AmityToastBloc>().add(AmityToastShort(
              message: context.l10n.toast_group_profile_updated,
              icon: AmityToastIcon.success));
          Navigator.pop(
              context, {'status': 'success', 'channel': updatedChannel});
        }
      }).catchError((error) {
        // Show error toast
        if (context.mounted) {
          context.read<AmityToastBloc>().add(AmityToastShort(
              message: context.l10n.toast_group_profile_error,
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
        backgroundColor: token(AmityColorToken.surfacePageBackgroundDefault),
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
                          color: token(AmityColorToken.textBaseSubdue),
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
                  title: context.l10n.general_camera,
                  onTap: () {
                    Navigator.pop(context);
                    _goToCameraPage(context);
                  },
                ),
                _buildListTile(
                    assetPath: 'assets/Icons/amity_ic_image_button.svg',
                    title: context.l10n.general_photo,
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
            color: token(AmityColorToken.textListHeaderDefaultDefault),
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
          context.read<AmityEditGroupProfileCubit>().updateSelectedImage(result.file.path);
        }
      },
    );
  }

  // Add method to pick an image using existing cubit method
  Future<void> _pickImage(BuildContext context) async {
    context.read<AmityEditGroupProfileCubit>().pickImage();
  }
}
