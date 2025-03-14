import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/base_page.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/core/user_avatar.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_creation/member/community_add_member_page.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_membership/bloc/community_membership_page_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/top_search_bar/top_search_bar.dart';
import 'package:amity_uikit_beta_service/v4/social/user/profile/amity_user_profile_page.dart';
import 'package:amity_uikit_beta_service/v4/utils/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

// ignore: must_be_immutable
class AmityCommunityMembershipPage extends NewBasePage {
  late AmityCommunity community;
  final ScrollController _memberScrollController = ScrollController();
  final ScrollController _moderatorScrollController = ScrollController();
  final TextEditingController _textcontroller = TextEditingController();

  AmityCommunityMembershipPage({super.key, required this.community})
      : super(pageId: 'community_membership_page');

  @override
  Widget buildPage(BuildContext context) {
    return BlocProvider(
      create: (_) => CommunityMembershipPageBloc(
          community: community,
          memberScrollController: _memberScrollController,
          moderatorScrollController: _moderatorScrollController),
      child: BlocBuilder<CommunityMembershipPageBloc,
          CommunityMembershipPageState>(
        builder: (context, state) {
          return _getPageWidget(context, state);
        },
      ),
    );
  }

  Widget _getPageWidget(
      BuildContext context, CommunityMembershipPageState state) {
    return Scaffold(
        backgroundColor: theme.backgroundColor,
        appBar: AmityAppBar(
          title: 'All members',
          configProvider: configProvider,
          theme: theme,
          tailingButton: state.isCurrentUserModerator
              ? GestureDetector(
                  onTap: () => _goToAddMemberPage(context),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Center(
                      child: SvgPicture.asset(
                        "assets/Icons/amity_ic_post_creation_button.svg",
                        package: 'amity_uikit_beta_service',
                        colorFilter: ColorFilter.mode(
                          theme.secondaryColor,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                )
              : null,
        ),
        body: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelColor: theme.primaryColor,
                  labelStyle: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelColor: theme.baseColorShade2,
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                  indicatorColor: theme.primaryColor,
                  dividerColor: theme.baseColorShade4,
                  dividerHeight: 1.0, // Makes indicator match text width
                  tabs: const [
                    Tab(text: 'Members'),
                    Tab(text: 'Moderators'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      Column(
                        children: [
                          AmityTopSearchBarComponent(
                            textcontroller: _textcontroller,
                            hintText: 'Search member',
                            showCancelButton: false,
                            onTextChanged: (value) {
                              context.read<CommunityMembershipPageBloc>().add(
                                  CommunityMembershipPageSearchMemberEvent(
                                      value));
                            },
                          ),
                          Expanded(
                            child: ListView.builder(
                              controller: _memberScrollController,
                              itemCount: state.members.length,
                              itemBuilder: (context, index) {
                                return _getUserListItem(context, state,
                                    state.members[index], index);
                              },
                            ),
                          )
                        ],
                      ),
                      ListView.builder(
                        controller: _moderatorScrollController,
                        itemCount: state.moderators.length,
                        itemBuilder: (context, index) {
                          return _getUserListItem(
                              context, state, state.moderators[index], index);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            )));
  }

  Widget _placeholderAvatar() {
    return SvgPicture.asset(
      'assets/Icons/amity_ic_user_avatar_new_placeholder.svg',
      width: 40,
      height: 40,
      package: 'amity_uikit_beta_service',
      fit: BoxFit.contain,
    );
  }

  Widget _getUserListItem(
      BuildContext context,
      CommunityMembershipPageState state,
      AmityCommunityMember member,
      int index) {
    return Padding(
        padding: EdgeInsets.fromLTRB(16, (index == 0) ? 16 : 8, 16, 8),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                GestureDetector(
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.baseColorShade4,
                    ),
                    child: member.user != null
                        ? AmityUserAvatar(
                            avatarUrl: member.user?.avatarUrl,
                            displayName: member.user?.displayName ?? 'Unknown',
                            isDeletedUser: false)
                        : _placeholderAvatar(),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return AmityUserProfilePage(
                              userId: member.user?.userId ?? "");
                        },
                      ),
                    );
                  },
                ),
                if (member.isModerator())
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          theme.primaryColor.blend(ColorBlendingOption.shade3),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/Icons/amity_ic_community_moderator.svg',
                        width: 10,
                        height: 10,
                        package: 'amity_uikit_beta_service',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(
                width: 8), // Add some spacing between the icon and text
            Expanded(
                child: Row(
              children: [
                Flexible(
                  child: GestureDetector(
                    child: Text(
                      member.user?.displayName ?? 'Unknown',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: theme.baseColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return AmityUserProfilePage(
                                userId: member.user?.userId ?? "");
                          },
                        ),
                      );
                    },
                  ),
                ),
                if(member.user?.isBrand ?? false) brandBadge() 
              ],
            )),

            if (member.user != null &&
                member.user!.userId != AmityCoreClient.getUserId())
              GestureDetector(
                onTap: () {
                  if (member.user != null) {
                    _showBottomSheet(context, state, member);
                  }
                },
                child: SvgPicture.asset(
                  'assets/Icons/amity_ic_post_item_option.svg',
                  width: 22,
                  height: 22,
                  package: 'amity_uikit_beta_service',
                  fit: BoxFit.contain,
                ),
              )
          ],
        ));
  }

  void _showBottomSheet(BuildContext context,
      CommunityMembershipPageState state, AmityCommunityMember member) {
    print('Member isFlaggedByMe: ${member.user?.isFlaggedByMe}');
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
            height: state.isCurrentUserModerator ? 280 : 140,
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
                if (state.isCurrentUserModerator) ...[
                  _buildListTile(
                    assetPath: member.isModerator()
                        ? 'assets/Icons/amity_ic_demote_member.svg'
                        : 'assets/Icons/amity_ic_promote_moderator.svg',
                    title: member.isModerator()
                        ? 'Demote to member'
                        : 'Promote to moderator',
                    onTap: () {
                      context.read<CommunityMembershipPageBloc>().add(
                          CommunityMembershipPageBottomSheetEvent(
                              member,
                              member.isModerator()
                                  ? CommunityMembershipPageBottomSheetAction
                                      .demote
                                  : CommunityMembershipPageBottomSheetAction
                                      .promote,
                              context.read<AmityToastBloc>()));
                      Navigator.pop(context);
                    },
                  ),
                  _buildListTile(
                      assetPath: 'assets/Icons/amity_ic_flag.svg',
                      title: member.user?.isFlaggedByMe ?? false
                          ? 'Unreport user'
                          : 'Report user',
                      onTap: () {
                        context.read<CommunityMembershipPageBloc>().add(
                            CommunityMembershipPageBottomSheetEvent(
                                member,
                                member.user?.isFlaggedByMe ?? false
                                    ? CommunityMembershipPageBottomSheetAction
                                        .unreport
                                    : CommunityMembershipPageBottomSheetAction
                                        .report,
                                context.read<AmityToastBloc>()));
                        Navigator.pop(context);
                      }),
                  _buildListTile(
                      assetPath: 'assets/Icons/ic_bin_red.svg',
                      title: 'Remove from community',
                      isDestructive: true,
                      onTap: () {
                        context.read<CommunityMembershipPageBloc>().add(
                            CommunityMembershipPageBottomSheetEvent(
                                member,
                                CommunityMembershipPageBottomSheetAction.remove,
                                context.read<AmityToastBloc>()));
                        Navigator.pop(context);
                      })
                ] else ...[
                  _buildListTile(
                      assetPath: 'assets/Icons/amity_ic_flag.svg',
                      title: member.user?.isFlaggedByMe ?? false
                          ? 'Unreport user'
                          : 'Report user',
                      onTap: () {
                        context.read<CommunityMembershipPageBloc>().add(
                            CommunityMembershipPageBottomSheetEvent(
                                member,
                                member.user?.isFlaggedByMe ?? false
                                    ? CommunityMembershipPageBottomSheetAction
                                        .unreport
                                    : CommunityMembershipPageBottomSheetAction
                                        .report,
                                context.read<AmityToastBloc>()));
                        Navigator.pop(context);
                      }),
                ],
              ],
            ),
          );
        });
  }

  Widget _buildListTile({
    required String assetPath,
    required String title,
    required Function()? onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: SizedBox(
          width: 24,
          height: 24,
          child: SvgPicture.asset(
            assetPath,
            package: 'amity_uikit_beta_service',
            color: isDestructive ? theme.alertColor : theme.baseColor,
            width: 32,
            height: 32,
          )),
      title: Transform.translate(
        offset: const Offset(-5, 0),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDestructive ? theme.alertColor : theme.baseColor,
          ),
        ),
      ),
      onTap: onTap,
    );
  }

  void _goToAddMemberPage(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => AmityCommunityAddMemberPage(
            users: [],
            onAddedAction: (users) {
              context.read<CommunityMembershipPageBloc>().add(
                  CommunityMembershipPageAddMemberEvent(
                      users.map((e) => e.userId).whereType<String>().toList(),
                      context.read<AmityToastBloc>()));
              Navigator.of(context).pop();
            })));
  }
}

extension on AmityCommunityMember {
  bool isModerator() {
    if (roles != null) {
      return roles!.contains('community-moderator') ||
          roles!.contains('moderator');
    }

    return false;
  }
}

Widget brandBadge() {
  return Container(
    padding: const EdgeInsets.only(left: 4),
    child: SvgPicture.asset(
      'assets/Icons/amity_ic_brand.svg',
      package: 'amity_uikit_beta_service',
      fit: BoxFit.fill,
      width: 18,
      height: 18,
    ),
  );
}