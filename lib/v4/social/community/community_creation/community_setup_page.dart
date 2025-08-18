import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:amity_uikit_beta_service/uikit_behavior.dart';
import 'package:amity_uikit_beta_service/v4/core/base_page.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/core/user_avatar.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_creation/member/community_add_member_page.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_creation/bloc/community_setup_page_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_creation/element/bloc/info_text_field_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_creation/element/category_grid_view.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_creation/element/info_text_field.dart';
import 'package:amity_uikit_beta_service/v4/social/community/profile/amity_community_profile_page.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_creation/category/community_add_category_page.dart';
import 'package:amity_uikit_beta_service/v4/social/post_composer_page/post_camera_screen.dart';
import 'package:amity_uikit_beta_service/v4/utils/amity_dialog.dart';
import 'package:amity_uikit_beta_service/v4/utils/app_bar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

enum CommunityPrivacy { public, private }

abstract class AmityCommunitySetupPageMode {
  const AmityCommunitySetupPageMode();
}

class CreateMode extends AmityCommunitySetupPageMode {
  const CreateMode();
}

class EditMode extends AmityCommunitySetupPageMode {
  final AmityCommunity community;

  const EditMode(this.community);
}

// ignore: must_be_immutable
class AmityCommunitySetupPage extends NewBasePage {
  late InfoTextFieldState nameTextFieldState;
  late InfoTextFieldState descriptionTextFieldState;
  final AmityCommunitySetupPageMode mode;
  AmityCommunity? community;
  late ScrollController _scrollController;

  AmityCommunitySetupPage({super.key, required this.mode})
      : super(pageId: 'community_composer_page') {
    if (mode is EditMode) {
      final EditMode editMode = mode as EditMode;
      community = editMode.community;
    }

    _scrollController = ScrollController();
  }

  @override
  Widget buildPage(BuildContext context) {
    return BlocProvider(
        create: (context) => CommunitySetupPageBloc(community: community),
        child: BlocListener<CommunitySetupPageBloc, CommunitySetupPageState>(
            listenWhen: (previous, current) =>
                previous.communityPrivacy != current.communityPrivacy &&
                mode is CreateMode,
            listener: (context, state) {
              if (state.communityPrivacy == CommunityPrivacy.private) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                });
              }
            },
            child: BlocBuilder<CommunitySetupPageBloc, CommunitySetupPageState>(
                builder: (context, state) {
              return _getPageWidget(context, state);
            })));
  }

  Widget _getPageWidget(BuildContext context, CommunitySetupPageState state) {
    return Scaffold(
        backgroundColor: theme.backgroundColor,
        appBar: AmityAppBar(
          title: mode is CreateMode ? context.l10n.community_create : context.l10n.community_edit,
          configProvider: configProvider,
          theme: theme,
          leadingButton: GestureDetector(
              onTap: () => _backAction(context),
              child: Center(
                child: SvgPicture.asset(
                  'assets/Icons/amity_ic_close_button.svg',
                  width: 28,
                  height: 28,
                  package: 'amity_uikit_beta_service',
                  colorFilter:
                      ColorFilter.mode(theme.baseColor, BlendMode.srcIn),
                ),
              )),
        ),
        body: GestureDetector(
            onVerticalDragDown: (_) {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    controller: _scrollController,
                    children: [
                      GestureDetector(
                        onTap: () => _showBottomSheet(context),
                        child: _getProfileAvatarWidget(context, state),
                      ),
                      Padding(
                          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                          child: Column(
                            children: [
                              InfoTextField(
                                  title: context.l10n.community_name,
                                  hint: context.l10n.community_name_hint,
                                  initialText: community?.displayName ?? '',
                                  maxLength: 30,
                                  expandable: false,
                                  onChanged: (text) {
                                    context.read<CommunitySetupPageBloc>().add(
                                        CommunitySetupPageNameChangedEvent(
                                            text));
                                  }),
                              const SizedBox(height: 24),
                              InfoTextField(
                                  title: context.l10n.community_about,
                                  isOptional: true,
                                  hint: context.l10n.community_description_hint,
                                  initialText: community?.description ?? '',
                                  maxLength: 180,
                                  expandable: true,
                                  onChanged: (text) {
                                    context.read<CommunitySetupPageBloc>().add(
                                        CommunitySetupPageDescriptionChangedEvent(
                                            text));
                                  }),
                              const SizedBox(height: 24),
                              GestureDetector(
                                onTap: () {
                                  _goToCategoryPage(context, state);
                                },
                                child: _getCategoryWidget(context, state),
                              ),
                              const SizedBox(height: 24),
                              _getPrivacyWidget(context, state),
                              if (state.communityPrivacy ==
                                      CommunityPrivacy.private &&
                                  mode is CreateMode) ...[
                                const SizedBox(height: 24),
                                _getDividerWidget(),
                                const SizedBox(height: 24),
                                _getMemberWidget(context, state)
                              ]
                            ],
                          ))
                    ],
                  ),
                ),
                _getDividerWidget(),
                if (mode is CreateMode)
                  _getCreateCommunityButtonWidget(context, state)
                else
                  _getSaveButtonWidget(context, state)
              ],
            )));
  }

  Widget _getProfileAvatarWidget(
      BuildContext context, CommunitySetupPageState state) {
    return Container(
      height: 188,
      decoration: BoxDecoration(
        image: state.pickedImage != null
            ? DecorationImage(
                image: FileImage(state.pickedImage!),
                fit: BoxFit.cover,
              )
            : DecorationImage(
                image: NetworkImage(
                    state.avatar?.getUrl(AmityImageSize.FULL) ?? ''),
                fit: BoxFit.cover,
              ),
        color: Colors.black.withOpacity(0.5),
      ),
      child: Center(
        child: SvgPicture.asset(
          'assets/Icons/amity_ic_camera.svg',
          width: 32,
          height: 28,
          package: 'amity_uikit_beta_service',
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _getCategoryWidget(
      BuildContext context, CommunitySetupPageState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.categories_title,
          style: AmityTextStyle.titleBold(theme.baseColor),
        ),
        const SizedBox(height: 22),
        Row(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Aligns items at the top
          children: [
            Expanded(
                child: state.communityCategories.isEmpty
                    ? Text(
                        context.l10n.category_hint,
                        style: TextStyle(
                          color: theme.baseColorShade3,
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                      )
                    : CategoryGridView(
                        items: state.communityCategories,
                        theme: theme,
                        onTap: (item) {
                          context
                              .read<CommunitySetupPageBloc>()
                              .add(CommunitySetupPageCategoryChangedEvent(
                                [...state.communityCategories]..remove(item),
                              ));
                        },
                      )),
            const SizedBox(width: 16),
            Icon(Icons.chevron_right, color: theme.baseColor),
          ],
        ),
        const SizedBox(height: 12),
        _getDividerWidget(),
      ],
    );
  }

  Widget _getPrivacyWidget(
      BuildContext context, CommunitySetupPageState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.settings_privacy,
          style: AmityTextStyle.titleBold(theme.baseColor),
        ),
        const SizedBox(height: 16),
        _getRadioButtonTile(
            title: context.l10n.community_public,
            description: context.l10n.community_public_description,
            iconPath: 'assets/Icons/amity_ic_public_badge.svg',
            value: state.communityPrivacy,
            groupValue: CommunityPrivacy.public,
            onChanged: (_) {
              context.read<CommunitySetupPageBloc>().add(
                  const CommunitySetupPagePrivacyChangedEvent(
                      CommunityPrivacy.public));
            }),
        _getRadioButtonTile(
            title: context.l10n.community_private,
            description: context.l10n.community_private_description,
            value: state.communityPrivacy,
            iconPath: 'assets/Icons/amity_ic_private_community.svg',
            groupValue: CommunityPrivacy.private,
            onChanged: (_) {
              context.read<CommunitySetupPageBloc>().add(
                  const CommunitySetupPagePrivacyChangedEvent(
                      CommunityPrivacy.private));
            }),
      ],
    );
  }

  Widget _getMemberWidget(BuildContext context, CommunitySetupPageState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(context.l10n.community_members,
          style: AmityTextStyle.titleBold(theme.baseColor),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            for (var member in state.communityMembers)
              GestureDetector(
                onTap: () {
                  context
                      .read<CommunitySetupPageBloc>()
                      .add(CommunitySetupPageRemoveMemberEvent(member));
                },
                child: _userItemWidget(member),
              ),
            GestureDetector(
                onTap: () {
                  _goToMemberPage(context, state);
                },
                child: _addMemberButtonWidget(context))
          ],
        )
      ],
    );
  }

  Widget _getCreateCommunityButtonWidget(
      BuildContext context, CommunitySetupPageState state) {
    return Container(
      color: theme.backgroundColor,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Row(
        children: [
          Expanded(
              child: GestureDetector(
            onTap: () {
              if (state.communityName.isNotEmpty) {
                context
                    .read<CommunitySetupPageBloc>()
                    .add(CommunitySetupPageCreateCommunityEvent(onSuccess: (community) {
                  Navigator.pop(context);
                  _goToCommunityProfilePage(context, community);
                }, toastBloc: context.read<AmityToastBloc>()));
              }
            },
            child: Container(
                decoration: BoxDecoration(
                  color: state.communityName.isEmpty
                      ? theme.primaryColor.blend(ColorBlendingOption.shade2)
                      : theme.primaryColor, // Rectangle background color
                  borderRadius: BorderRadius.circular(8.0), // Rounded corners
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Transform.translate(
                      offset: const Offset(0, 1),
                      child: SvgPicture.asset(
                        'assets/Icons/amity_ic_post_creation_button.svg',
                        width: 16,
                        height: 18,
                        color: Colors.white,
                        package: 'amity_uikit_beta_service',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Text(
                    context.l10n.community_create,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600),
                  ),
                ])),
          )),
        ],
      ),
    );
  }

  Widget _getSaveButtonWidget(
      BuildContext context, CommunitySetupPageState state) {
    return Container(
      color: theme.backgroundColor,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Row(
        children: [
          Expanded(
              child: GestureDetector(
            onTap: () {
              if (state.communityName.isNotEmpty &&
                  state.hasExistingDataChanged) {
                state.isCommunityPrivacyUpdatedToPrivate
                    ? _showPrivacyChangedDialog(context, _saveAction)
                    : _saveAction(context);
              }
            },
            child: Container(
                decoration: BoxDecoration(
                  color: state.communityName.isEmpty || !state.hasExistingDataChanged
                      ? theme.primaryColor.blend(ColorBlendingOption.shade2)
                      : theme.primaryColor, // Rectangle background color
                  borderRadius: BorderRadius.circular(8.0), // Rounded corners
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: const Center(
                  child: Text(
                    "Save",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600),
                  ),
                )),
          )),
        ],
      ),
    );
  }

  Widget _getRadioButtonTile<T>({
    required String title,
    required String description,
    required String iconPath,
    required T value,
    required T groupValue,
    required void Function(T?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            width: 40,
            decoration:
                BoxDecoration(color: Colors.grey[200], shape: BoxShape.circle),
            child: Center(
              child: SvgPicture.asset(
                iconPath,
                width: 16,
                height: 18,
                package: 'amity_uikit_beta_service',
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: theme.baseColor,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: theme.baseColorShade1,
                ),
              ),
            ],
          )),
          const SizedBox(width: 16),
          SizedBox(
              width: 24,
              height: 24,
              child: Radio<T>(
                value: value,
                groupValue: groupValue,
                onChanged: onChanged,
                activeColor: theme.primaryColor,
              )),
        ],
      ),
    );
  }

  Widget _addMemberButtonWidget(BuildContext context) {
    return ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 62, maxWidth: 62),
        child: Column(
          children: [
            Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.baseColorShade4,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/Icons/amity_ic_post_creation_button.svg',
                    width: 20,
                    height: 20,
                    color: theme.baseColor,
                    package: 'amity_uikit_beta_service',
                    fit: BoxFit.contain,
                  ),
                )),
            const SizedBox(height: 4),
            Text(context.l10n.general_add,
                style: TextStyle(
                    color: theme.baseColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w400))
          ],
        ));
  }

  Widget _userItemWidget(AmityUser user) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
          minWidth: 62, maxWidth: 62), // Set the maximum width constraint
      child: Column(
        children: [
          Stack(
            alignment: AlignmentDirectional.topEnd,
            children: [
              Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.primaryColor.blend(ColorBlendingOption.shade2),
                  ),
                  child: AmityUserAvatar(avatarUrl: user.avatarUrl, displayName: user.displayName ?? 'Unknown', isDeletedUser: false)),
              Transform.translate(
                offset: const Offset(5, -2),
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.3),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/Icons/amity_ic_close_button.svg',
                      width: 16,
                      height: 16,
                      color: Colors.white,
                      package: 'amity_uikit_beta_service',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            user.displayName ?? 'Unknown',
            style: TextStyle(
              color: theme.baseColor,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
            overflow: TextOverflow.ellipsis, // Ensure text does not overflow
            maxLines: 1, // Limit to a single line
          ),
        ],
      ),
    );
  }

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
                      context
                          .read<CommunitySetupPageBloc>()
                          .add(const CommunitySetupPageImagePickerEvent());

                      Navigator.pop(context);
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

  Widget _getDividerWidget() {
    return Padding(
        padding: EdgeInsets.zero,
        child: Divider(
          color: theme.baseColorShade4,
          thickness: 1,
          indent: 0,
          endIndent: 0,
          height: 1,
        ));
  }

  void _goToCategoryPage(BuildContext context, CommunitySetupPageState state) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => PopScope(
          canPop: true,
          child: AmityCommunityAddCategoryPage(
              categories: state.communityCategories,
              onAddedAction: (categories) {
                context
                    .read<CommunitySetupPageBloc>()
                    .add(CommunitySetupPageCategoryChangedEvent(categories));

                Navigator.pop(context);
              }),
        ),
      ),
    );
  }

  void _goToMemberPage(BuildContext context, CommunitySetupPageState state) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => PopScope(
          canPop: true,
          child: AmityCommunityAddMemberPage(
            users: state.communityMembers,
            onAddedAction: (users) {
              context
                  .read<CommunitySetupPageBloc>()
                  .add(CommunitySetupPageAddMemberEvent(users));
              Navigator.pop(context);
            },
          ),
        ),
      ),
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
          context.read<CommunitySetupPageBloc>().add(
                CommunitySetupPageCameraImageEvent(result.file),
              );
        }
      },
    );
  }

  void _saveAction(BuildContext context) {
    context
        .read<CommunitySetupPageBloc>()
        .add(CommunitySetupPageSaveCommunityEvent(
            onSuccess: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            toastBloc: context.read<AmityToastBloc>()));
  }

  void _backAction(BuildContext context) {
    ConfirmationV4Dialog().show(
        context: context,
        title: context.l10n.community_discard_confirmation,
        detailText: context.l10n.community_discard_description,
        leftButtonText: context.l10n.general_cancel,
        rightButtonText: context.l10n.general_leave,
        onConfirm: () {
          Navigator.pop(context);
        });
  }

  void _showPrivacyChangedDialog(BuildContext context, Function onConfirm) {
    ConfirmationV4Dialog().show(
        context: context,
        title: context.l10n.settings_privacy_confirmation,
        detailText: context.l10n.settings_privacy_description,
        leftButtonColor: Colors.blueAccent,
        onConfirm: () {
          onConfirm(context);
        });
  }

  void _goToCommunityProfilePage(BuildContext context, AmityCommunity community) {
    UIKitBehavior.instance.postContentComponentBehavior
        .goToCommunityProfilePage(context, community.communityId ?? '');
  }
}
