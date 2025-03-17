import 'package:amity_uikit_beta_service/v4/core/base_page.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/amity_uikit_toast.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/core/user_avatar.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_creation/element/info_text_field.dart';
import 'package:amity_uikit_beta_service/v4/social/user/profile/bloc/edit_profile_bloc.dart';
import 'package:amity_uikit_beta_service/v4/utils/bloc_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class AmityEditUserProfilePage extends NewBasePage {
  final String userId;

  // Once profile is edited, it should be reflected in user profile page.
  // But user object in user profile page is not a live object. Hence we use this optional callback to update user profile page.
  final Function(bool)? userEditAction;

  AmityEditUserProfilePage(
      {super.key, required this.userId, this.userEditAction})
      : super(pageId: 'edit_user_profile_page');

  @override
  Widget buildPage(BuildContext context) {
    return BlocProvider(
        create: (context) => EditProfileBloc(userId),
        child: Builder(builder: (context) {
          return BlocBuilder<EditProfileBloc, EditProfileState>(
            builder: (context, state) {
              return Scaffold(
                backgroundColor: theme.backgroundColor,
                appBar: AppBar(
                  title: Text('Edit profile',
                      style: AmityTextStyle.titleBold(theme.baseColor)),
                  leading: IconButton(
                    //iconSize: 24,
                    icon: ColorFiltered(
                      colorFilter:
                          ColorFilter.mode(theme.baseColor, BlendMode.srcIn),
                      child: SvgPicture.asset(
                        'assets/Icons/amity_ic_nav_back_button.svg',
                        package: 'amity_uikit_beta_service',
                      ),
                    ), // amity_ic_back_button.svg
                    onPressed: () => {
                      if (state.isProfileInfoUpdated)
                        {askConfirmationToDiscard(context)}
                      else
                        {Navigator.of(context).pop()}
                    },
                  ),
                  backgroundColor: theme.backgroundColor,
                ),
                body: SafeArea(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ListView(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  context
                                      .read<EditProfileBloc>()
                                      .addEvent(EditProfileImagePickerEvent(
                                    onError: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return CupertinoAlertDialog(
                                            title: const Text(
                                                "Unsupported image type"),
                                            content: const Text(
                                                "Please upload a PNG or JPG image."),
                                            actions: [
                                              CupertinoDialogAction(
                                                child: Text(
                                                  "OK",
                                                  style: AmityTextStyle.body(
                                                      theme.highlightColor),
                                                ),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ));
                                },
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // We need to fetch user profile here & show it as network avatar
                                    if (state.selectedImage == null) ...[
                                      AmityUserAvatar(
                                        avatarUrl: state.user?.avatarUrl ?? "",
                                        displayName:
                                            state.user?.displayName ?? "",
                                        isDeletedUser:
                                            state.user?.isDeleted ?? false,
                                        avatarSize: const Size(64, 64),
                                      ),
                                    ] else ...[
                                      Container(
                                        width: 64,
                                        height: 64,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                                image: FileImage(
                                                    state.selectedImage!),
                                                fit: BoxFit.cover)),
                                      )
                                    ],
                                    // Overlay & Camera Icon
                                    Container(
                                      width: 64,
                                      height: 64,
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.3),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: SvgPicture.asset(
                                          'assets/Icons/amity_ic_edit_profile_camera_button.svg',
                                          package: "amity_uikit_beta_service",
                                          height: 24,
                                          width: 24,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),

                                    // Camera Icon
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 24,
                              ),
                              // Note:
                              // Here key is generated using userId from User object, so that info text field correctly renders the data & character count.
                              // We do not set the userId from state here (state.userId) because it will never change, so it will not trigger the rebuild of the widget.
                              InfoTextField(
                                key: Key(
                                    "name_field_${state.user?.userId ?? ""}"),
                                title: "Display Name",
                                initialText: state.user?.displayName ?? "",
                                maxLength: 100,
                                expandable: false,
                                isDisabled: true,
                                onChanged: (text) => {},
                              ),
                              const SizedBox(
                                height: 24,
                              ),
                              InfoTextField(
                                key: Key(
                                    "about_field_${state.user?.userId ?? ""}"),
                                title: "About",
                                isOptional: true,
                                initialText: state.user?.description ?? "",
                                maxLength: 180,
                                expandable: true,
                                onChanged: (text) => {
                                  context.read<EditProfileBloc>().addEvent(
                                      EditProfileAboutChangedEvent(
                                          value: text)),
                                },
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          color: theme.baseColorShade4,
                          thickness: 1,
                        ),
                        _getProfileSaveButton(context, state)
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }));
  }

  Widget _getProfileSaveButton(BuildContext context, EditProfileState state) {
    final AmityToastBloc toastBloc = context.read<AmityToastBloc>();

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                if (state.isProfileInfoUpdated) {
                  context.read<EditProfileBloc>().addEvent(EditProfileSaveEvent(
                    onCompletion: (
                        {required isSuccess, required isUnsafeUploadError}) {
                      if (isSuccess) {
                        // Dismiss Screen
                        Navigator.of(context).pop();

                        // Callback to update
                        if (userEditAction != null) {
                          userEditAction!(isSuccess);
                        }
                      } else {
                        if (isUnsafeUploadError) {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return CupertinoAlertDialog(
                                title: const Text("Inappropriate image"),
                                content: const Text(
                                    "Please choose a different image to upload."),
                                actions: [
                                  CupertinoDialogAction(
                                    child: Text(
                                      "OK",
                                      style: AmityTextStyle.body(
                                          theme.highlightColor),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          toastBloc.add(
                            const AmityToastShort(
                                message:
                                    "Failed to save your profile. Please try again.",
                                icon: AmityToastIcon.warning),
                          );
                        }
                      }
                    },
                  ));
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: !state.isProfileInfoUpdated
                      ? theme.primaryColor.blend(ColorBlendingOption.shade2)
                      : theme.primaryColor, // Rectangle background color
                  borderRadius: BorderRadius.circular(8.0), // Rounded corners
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Center(
                  child: Text(
                    "Save",
                    style: AmityTextStyle.bodyBold(Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void askConfirmationToDiscard(BuildContext context) {
    dismissScreen() {
      Navigator.of(context).pop();
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text("Unsaved changes"),
          content: const Text(
              "Are you sure you want to discard the changes? They will be lost when you leave this page."),
          actions: [
            CupertinoDialogAction(
              child: Text(
                "Cancel",
                style: AmityTextStyle.body(theme.highlightColor),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: Text(
                "Discard",
                style: AmityTextStyle.bodyBold(theme.alertColor),
              ),
              onPressed: () {
                Navigator.pop(context);

                dismissScreen();
              },
            ),
          ],
        );
      },
    );
  }
}
