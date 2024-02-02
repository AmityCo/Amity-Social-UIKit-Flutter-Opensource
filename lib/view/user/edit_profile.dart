import 'dart:developer';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/components/alert_dialog.dart';
import 'package:amity_uikit_beta_service/components/custom_textfield.dart';
import 'package:animation_wrappers/animation_wrappers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/custom_user_avatar.dart';
import '../../viewmodel/amity_viewmodel.dart';
import '../../viewmodel/configuration_viewmodel.dart';
import '../../viewmodel/custom_image_picker.dart';
import '../../viewmodel/user_feed_viewmodel.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.user});
  final AmityUser user;
  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  double radius = 32;
  final TextEditingController _displayNameController = TextEditingController();

  final TextEditingController _descriptionController = TextEditingController();

  Widget imageWidgetBuilder(ImageState imageState) {
    log("image state$imageState");
    log("ImagePickerVM:${Provider.of<ImagePickerVM>(
      context,
    ).amityImage?.fileUrl}");
    log("AmityVM:${Provider.of<AmityVM>(
      context,
    ).currentamityUser?.avatarUrl}");
    var avatarWidget = const CircleAvatar();
    switch (imageState) {
      case ImageState.loading:
        avatarWidget = CircleAvatar(
            radius: radius,
            backgroundColor: Colors.grey,
            child: const CircularProgressIndicator(
              color: Colors.white,
            ));
        break;
      case ImageState.noImage:
        avatarWidget = CircleAvatar(
          radius: radius,
          backgroundColor: Colors.grey[400],
          child: Icon(
            Icons.person,
            color: Colors.white,
            size: radius,
          ),
        );
        break;
      case ImageState.hasImage:
        avatarWidget = CircleAvatar(
          radius: radius,
          backgroundImage:
              Provider.of<ImagePickerVM>(context, listen: true).amityImage !=
                      null
                  ? NetworkImage("${Provider.of<ImagePickerVM>(
                      context,
                    ).amityImage?.fileUrl}?size=medium")
                  : getImageProvider(
                      "${Provider.of<AmityVM>(
                        context,
                      ).currentamityUser?.avatarUrl}?size=medium",
                    ),
        );
        break;
    }
    return avatarWidget;
  }

  @override
  void initState() {
    Provider.of<ImagePickerVM>(context, listen: false).init(
        Provider.of<AmityVM>(context, listen: false)
            .currentamityUser
            ?.avatarUrl);
    _displayNameController.text = Provider.of<AmityVM>(context, listen: false)
            .currentamityUser!
            .displayName ??
        "";
    _descriptionController.text = Provider.of<AmityVM>(context, listen: false)
            .currentamityUser!
            .description ??
        "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final myAppBar = AppBar(
      title: Text(
        "Edit Profile",
        style: Provider.of<AmityUIConfiguration>(context).titleTextStyle,
      ),
      backgroundColor: Colors.white,
      leading: IconButton(
        color: Provider.of<AmityUIConfiguration>(context).primaryColor,
        onPressed: () {
          Navigator.of(context).pop();
        },
        icon: const Icon(
          Icons.chevron_left,
          color: Colors.black,
        ),
      ),
      elevation: 0,
      actions: [
        TextButton(
          onPressed: () async {
            if (Provider.of<ImagePickerVM>(context, listen: false).imageState !=
                ImageState.loading) {
              //edit profile

              if (Provider.of<ImagePickerVM>(context, listen: false)
                      .amityImage !=
                  null) {
                log("Image was selected and will be adding to user profile...");

                await Provider.of<UserFeedVM>(context, listen: false)
                    .editCurrentUserInfo(
                        displayName: _displayNameController.text,
                        description: _descriptionController.text,
                        avatarFileId:
                            Provider.of<ImagePickerVM>(context, listen: false)
                                .amityImage
                                ?.fileId);
              } else {
                log("No Image was selected and current avatarImage will be adding to user profile...");
                await Provider.of<UserFeedVM>(context, listen: false)
                    .editCurrentUserInfo(
                        displayName: _displayNameController.text,
                        description: _descriptionController.text,
                        avatarFileId:
                            Provider.of<AmityVM>(context, listen: false)
                                .currentamityUser!
                                .avatarFileId);
              }
              // ignore: use_build_context_synchronously
              await Provider.of<AmityVM>(context, listen: false)
                  .refreshCurrentUserData()
                  .then((value) {
                Navigator.of(context).pop();
                AmityDialog().showAlertErrorDialog(
                    title: "Success!",
                    message: "Profile updated successfully!");
              });
            }
          },
          child: Text(
            "Save",
            style: theme.textTheme.labelLarge!.copyWith(
                color: Provider.of<ImagePickerVM>(
                          context,
                        ).imageState ==
                        ImageState.loading
                    ? Colors.grey
                    : Provider.of<AmityUIConfiguration>(context).primaryColor,
                fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
    final bheight = mediaQuery.size.height -
        mediaQuery.padding.top -
        myAppBar.preferredSize.height;
    return Consumer<UserFeedVM>(builder: (context, vm, _) {
      return Scaffold(
        appBar: myAppBar,
        body: FadedSlideAnimation(
          beginOffset: const Offset(0, 0.3),
          endOffset: const Offset(0, 0),
          slideCurve: Curves.linearToEaseOut,
          child: Container(
            color: Colors.white,
            height: bheight,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 20, bottom: 20),
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: Stack(
                      children: [
                        FadedScaleAnimation(
                          child: GestureDetector(
                              onTap: () {
                                Provider.of<ImagePickerVM>(context,
                                        listen: false)
                                    .showBottomSheet(context);
                              },
                              child:
                                  imageWidgetBuilder(Provider.of<ImagePickerVM>(
                                context,
                              ).imageState)),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xffEBECEF),
                              // boxShadow: [
                              //   BoxShadow(
                              //     color: Colors.grey, // Shadow color
                              //     blurRadius: 4.0, // Blur radius
                              //     offset: Offset(
                              //         0, 2), // Changes position of shadow
                              //   ),
                              // ],
                            ),
                            child: const Icon(
                              Icons.camera_alt_outlined,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Container(
                        //   padding: const EdgeInsets.fromLTRB(20, 20, 0, 20),
                        //   alignment: Alignment.centerLeft,
                        //   color: Colors.grey[200],
                        //   width: double.infinity,
                        //   child: Text(
                        //     "Profile Info",
                        //     style: theme.textTheme.titleLarge!.copyWith(
                        //       color: Colors.grey,
                        //       fontSize: 16,
                        //     ),
                        //   ),
                        // ),
                        // Container(
                        //   color: Colors.white,
                        //   width: double.infinity,
                        //   padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                        //   child: TextField(
                        //     enabled: false,
                        //     controller:
                        //         TextEditingController(text: vm.amityUser!.userId),
                        //     decoration: const InputDecoration(
                        //       labelText: "User Id",
                        //       labelStyle: TextStyle(height: 1),
                        //       border: InputBorder.none,
                        //     ),
                        //   ),
                        // ),
                        // Divider(
                        //   color: Colors.grey[200],
                        //   thickness: 3,
                        // ),
                        TextFieldWithCounter(
                          controller: _displayNameController,
                          title: 'Display name',
                          hintText: 'Display name',
                          maxCharacters: 180,
                        ),

                        TextFieldWithCounter(
                          isRequired: false,
                          controller: _descriptionController,
                          title: 'About',
                          hintText: 'Enter description',
                          maxCharacters: 180,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                        ),

                        // Container(
                        //   color: Colors.white,
                        //   width: double.infinity,
                        //   padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                        //   child: TextField(
                        //     controller:
                        //         TextEditingController(text: '+1 9876543210'),
                        //     decoration: InputDecoration(
                        //       labelText: S.of(context).phoneNumber,
                        //       labelStyle: TextStyle(height: 1),
                        //       border: InputBorder.none,
                        //     ),
                        //   ),
                        // ),
                        // Divider(
                        //   color: ApplicationColors.lightGrey,
                        //   thickness: 3,
                        // ),
                        // Container(
                        //   color: Colors.white,
                        //   width: double.infinity,
                        //   padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                        //   child: TextField(
                        //     controller: TextEditingController(
                        //         text: S.of(context).samanthasmithmailcom),
                        //     decoration: InputDecoration(
                        //       labelText: S.of(context).emailAddress,
                        //       labelStyle: TextStyle(height: 1),
                        //       border: InputBorder.none,
                        //     ),
                        //   ),
                        // ),
                        // Divider(
                        //   color: ApplicationColors.lightGrey,
                        //   thickness: 3,
                        // ),
                        // Container(
                        //   color: Colors.white,
                        //   width: double.infinity,
                        //   padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                        //   child: TextField(
                        //     controller:
                        //         TextEditingController(text: S.of(context).female),
                        //     decoration: InputDecoration(
                        //       labelText: S.of(context).gender,
                        //       labelStyle: TextStyle(height: 1),
                        //       border: InputBorder.none,
                        //     ),
                        //   ),
                        // ),
                        // Divider(
                        //   color: ApplicationColors.lightGrey,
                        //   thickness: 3,
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
