import 'package:amity_uikit_beta_service/v4/chat/group_message/amity_group_chat_page.dart';
import 'package:amity_uikit_beta_service/v4/core/base_page.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/amity_uikit_toast.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/utils/amity_dialog.dart';
import 'package:amity_uikit_beta_service/v4/social/post_composer_page/post_camera_screen.dart';
import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:amity_sdk/amity_sdk.dart';
import 'package:flutter_svg/svg.dart';
import '../bloc/amity_create_group_cubit.dart';
import 'package:amity_uikit_beta_service/v4/core/shared/user/user_list.dart';
import 'package:amity_uikit_beta_service/v4/utils/media_permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:amity_uikit_beta_service/v4/chat/createGroup/ui/amity_select_group_member_page.dart';

class AmityCreateGroupChatPage extends NewBasePage {
  // Add the new required parameter
  final List<AmityUser> selectedUsers;
  // Add callback for user removal
  final Function(AmityUser)? onUserRemoved;

  AmityCreateGroupChatPage({
    Key? key,
    required this.selectedUsers,
    this.onUserRemoved,
  }) : super(key: key, pageId: 'create_group_chat_page');

  final TextEditingController _groupNameController = TextEditingController();
  // Define ValueNotifier for selected privacy option
  final ValueNotifier<String> _selectedNotifier =
      ValueNotifier<String>('Public');
  final ScrollController _selectedUsersController = ScrollController();
  // Add state variable for selected image
  final ValueNotifier<String?> _selectedImagePath =
      ValueNotifier<String?>(null);
  final MediaPermissionHandler _mediaHandler = MediaPermissionHandler();
  // Add a ValueNotifier for character count
  final ValueNotifier<int> _charCount = ValueNotifier<int>(0);
  // Create a ValueNotifier for the selected users list to track changes
  late final ValueNotifier<List<AmityUser>> _selectedUsersNotifier;

  @override
  Widget buildPage(BuildContext context) {
    // Initialize the selected users notifier with the initial list
    _selectedUsersNotifier =
        ValueNotifier<List<AmityUser>>(List.from(selectedUsers));

    // Set up text controller listener to update character count
    _groupNameController.addListener(() {
      _charCount.value = _groupNameController.text.length;
    });

    return BlocProvider(
      create: (context) => AmityCreateGroupCubit(),
      child: BlocConsumer<AmityCreateGroupCubit, AmityCreateGroupState>(
        listener: (context, state) {
          if (state.status == CreateGroupStatus.success) {
            // Navigate to the group chat page with the created channel
            if (state.createdChannel?.channelId != null) {
              context.read<AmityToastBloc>().add(AmityToastShort(
                  message: context.l10n.chat_create_success,
                  icon: AmityToastIcon.success));
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => AmityGroupChatPage(
                    channelId: state.createdChannel!.channelId ?? '',
                    isJustCreated: true,
                  ),
                ),
              );
            } else {
              Navigator.of(context).pop(state.createdChannel);
            }
          } else if (state.status == CreateGroupStatus.uploadImageFailed) {
            AmityV4Dialog().showAlertErrorDialog(
              title: state.errorTitle ?? "Error",
              message: state.error ?? context.l10n.chat_create_error,
              closeText: 'OK',
            );
          } else if (state.status == CreateGroupStatus.failure) {
            context.read<AmityToastBloc>().add(AmityToastShort(
                message: context.l10n.chat_create_error_retry,
                icon: AmityToastIcon.warning));
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: theme.backgroundColor,
              title: Text(
                context.l10n.chat_create_title,
                style: AmityTextStyle.titleBold(theme.baseColor),
              ),
              automaticallyImplyLeading: false, // Remove default back button

              leading: IconButton(
                icon: SvgPicture.asset(
                  'assets/Icons/amity_ic_close_button.svg',
                  package: 'amity_uikit_beta_service',
                  width: 24,
                  height: 24,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    // Call create group function
                    final cubit = context.read<AmityCreateGroupCubit>();
                    final isPublic = _selectedNotifier.value == context.l10n.chat_privacy_public;

                    // Get the image path from the notifier
                    final imagePath = _selectedImagePath.value;

                    String displayName = _groupNameController.text;
                    if (displayName.trim().isEmpty) {
                      // Start with the current user, then add other members
                      final currentUser = AmityCoreClient.getCurrentUser();
                      final List<AmityUser> allUsers = [
                        currentUser,
                        ..._selectedUsersNotifier.value
                            .where((user) => user.userId != currentUser.userId)
                      ];
                      displayName =
                          cubit.generateDisplayNameFromMembers(allUsers);
                    }

                    final File? groupImage =
                        imagePath != null ? File(imagePath) : null;

                    await cubit.createGroup(
                      groupName: displayName,
                      isPublic: isPublic,
                      users: _selectedUsersNotifier.value,
                      groupImage: groupImage,
                    );
                  },
                  child: Text(
                    context.l10n.chat_create_button,
                    style: AmityTextStyle.body(theme.primaryColor),
                  ),
                ),
              ],
            ),
            body: Container(
              color: theme.backgroundColor,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main content area
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Group Image Picker
                          Center(
                            child: Column(
                              children: [
                                ValueListenableBuilder<String?>(
                                    valueListenable: _selectedImagePath,
                                    builder: (context, imagePath, child) {
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
                                                image: imagePath != null
                                                    ? DecorationImage(
                                                        image: FileImage(
                                                            File(imagePath)),
                                                        fit: BoxFit.cover,
                                                      )
                                                    : null,
                                              ),
                                              child: imagePath == null
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
                                                color: Colors.black
                                                    .withOpacity(0.3),
                                                borderRadius:
                                                    BorderRadius.circular(24),
                                              ),
                                              child: Center(
                                                child: SvgPicture.asset(
                                                  'assets/Icons/amity_ic_camera.svg',
                                                  package:
                                                      'amity_uikit_beta_service',
                                                  width: 32,
                                                  height: 28,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
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
                                          text: context.l10n.chat_group_name_label,
                                          style: AmityTextStyle.titleBold(
                                              theme.baseColor),
                                        ),
                                        TextSpan(
                                          text: ' ${context.l10n.chat_group_name_optional}',
                                          style: AmityTextStyle.caption(
                                              theme.baseColorShade3),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ValueListenableBuilder<int>(
                                    valueListenable: _charCount,
                                    builder: (context, count, _) {
                                      return Text(
                                        '$count/100',
                                        style: AmityTextStyle.caption(
                                          count > 100
                                              ? Colors.red
                                              : theme.baseColorShade1,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              TextField(
                                controller: _groupNameController,
                                decoration: InputDecoration(
                                  hintText: context.l10n.chat_group_name_placeholder,
                                  hintStyle: AmityTextStyle.body(
                                      theme.baseColorShade3),
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
                                maxLines: null,
                                textInputAction: TextInputAction.newline,
                                buildCounter: (context,
                                    {required currentLength,
                                    required isFocused,
                                    maxLength}) {
                                  return null;
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          Text(context.l10n.settings_privacy,
                              style: AmityTextStyle.titleBold(theme.baseColor)),
                          const SizedBox(height: 4),
                          ValueListenableBuilder<String>(
                              valueListenable: _selectedNotifier,
                              builder: (context, selected, _) {
                                return Column(
                                  children: [
                                    _buildOption(
                                      title: context.l10n.chat_privacy_public,
                                      description: context.l10n.chat_privacy_public_desc,
                                      iconPath:
                                          'assets/Icons/amity_ic_create_group_public_button.svg',
                                      selected: selected,
                                    ),
                                    _buildOption(
                                      title: context.l10n.chat_privacy_private,
                                      description: context.l10n.chat_privacy_private_desc,
                                      iconPath:
                                          'assets/Icons/amity_ic_create_group_private_button.svg',
                                      selected: selected,
                                    ),
                                  ],
                                );
                              }),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.backgroundShade1Color,
                      ),
                      child: Text(
                          context.l10n.chat_privacy_warning,
                          style: AmityTextStyle.caption(theme.baseColorShade1)),
                    ),

                    // Selected Users Grid List
                    ValueListenableBuilder<List<AmityUser>>(
                      valueListenable: _selectedUsersNotifier,
                      builder: (context, currentSelectedUsers, _) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 16.0, top: 8.0, bottom: 4.0),
                              child: Text(context.l10n.chat_member_label,
                                  style: AmityTextStyle.titleBold(
                                      theme.baseColor)),
                            ),
                            // Remove height constraint to allow all users to be visible
                            gridUserList(
                              context: context,
                              scrollController: _selectedUsersController,
                              users: currentSelectedUsers,
                              theme: theme,
                              loadMore: () {
                                // No need to load more for a fixed selected users list
                              },
                              onTap: (user) {
                                // Remove user from selection
                                _removeUser(user);
                              },
                              onAddTap: () async {
                                // Navigate to select users screen with onMembersSelected callback
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AmitySelectGroupMemberPage(
                                      isModifyMember: true,
                                      selectedGroupMember:
                                          _selectedUsersNotifier.value,
                                      onMembersSelected: (updatedUsers) {
                                        if (updatedUsers.isNotEmpty) {
                                          _selectedUsersNotifier.value =
                                              updatedUsers;
                                        }
                                      },
                                    ),
                                  ),
                                );
                              },
                              excludeCurrentUser: false, // Show current user
                            ),
                          ],
                        );
                      },
                    ),

                    // Some padding at the bottom for better scrolling experience
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOption({
    required String title,
    required String description,
    required String iconPath, // Changed from IconData to String for SVG path
    required String selected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
      child: InkWell(
        onTap: () {
          _selectedNotifier.value = title;
        },
        borderRadius: BorderRadius.circular(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Replace Icon with SVG with background
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.baseColorShade4,
                borderRadius: BorderRadius.circular(90),
              ),
              child: Center(
                child: SvgPicture.asset(
                  iconPath,
                  package: 'amity_uikit_beta_service',
                  width: 24,
                  height: 24,
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AmityTextStyle.bodyBold(theme.baseColor)),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: AmityTextStyle.caption(theme.baseColorShade1),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12),
            Radio<String>(
              value: title,
              groupValue: selected,
              activeColor: theme.primaryColor,
              onChanged: (value) {
                if (value != null) {
                  _selectedNotifier.value = value;
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // Add method to pick an image
  Future<void> _pickImage(BuildContext context) async {
    try {
      final XFile? image = await _mediaHandler.pickImage();
      if (image != null) {
        _selectedImagePath.value = image.path;
      }
    } catch (e) {}
  }

  // Add method to remove a user
  void _removeUser(AmityUser user) {
    final currentList = List<AmityUser>.from(_selectedUsersNotifier.value);
    currentList.removeWhere((u) => u.userId == user.userId);
    _selectedUsersNotifier.value = currentList;

    // Notify parent if callback is provided
    if (onUserRemoved != null) {
      onUserRemoved!(user);
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
          _selectedImagePath.value = result.file.path;
        }
      },
    );
  }
}
