import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/amity_uikit.dart';
import 'package:amity_uikit_beta_service/v4/core/base_page.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/core/user_avatar.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_creation/member/bloc/community_add_member_page_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/top_search_bar/top_search_bar.dart';
import 'package:amity_uikit_beta_service/v4/utils/app_bar.dart';
import 'package:amity_uikit_beta_service/v4/utils/debouncer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';

// ignore: must_be_immutable
class AmityCommunityAddMemberPage extends NewBasePage {
  final TextEditingController _textcontroller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Debouncer _debouncer = Debouncer(milliseconds: 300);
  Function(List<AmityUser>) onAddedAction;
  List<AmityUser> users;

  AmityCommunityAddMemberPage(
      {super.key, required this.users, required this.onAddedAction})
      : super(pageId: 'community_add_member_page');

  @override
  Widget buildPage(BuildContext context) {
    return BlocProvider(
      create: (_) => CommunityAddMemberPageBloc(
          scrollController: _scrollController, selectedUsers: users),
      child:
          BlocBuilder<CommunityAddMemberPageBloc, CommunityAddMemberPageState>(
        builder: (context, state) {
          return _getPageWidget(context, state);
        },
      ),
    );
  }

  Widget _getPageWidget(
      BuildContext context, CommunityAddMemberPageState state) {
    return Scaffold(
        backgroundColor: theme.backgroundColor,
        appBar: AmityAppBar(
          title: context.l10n.member_add,
          configProvider: configProvider,
          theme: theme,
        ),
        body: Column(
          children: [
            AmityTopSearchBarComponent(
              pageId: pageId,
              textcontroller: _textcontroller,
              hintText: context.l10n.search_user_hint,
              showCancelButton: false,
              onTextChanged: (value) {
                _debouncer.run(() {
                  context
                      .read<CommunityAddMemberPageBloc>()
                      .add(CommunityAddMemberPageSearchUserEvent(value));
                });
              },
            ),
            if (state.selectedUsers.isNotEmpty) ...[
              SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(16),
                    itemCount: state.selectedUsers.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                          onTap: () {
                            context.read<CommunityAddMemberPageBloc>().add(
                                CommunityAddMemberPageSelectUserEvent(
                                    state.selectedUsers[index]));
                          },
                          child: _userItemWidget(context, state.selectedUsers[index]));
                    },
                  )),
              _getDividerWidget()
            ] else ...[
              Container()
            ],
            Expanded(
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: () {
                            context.read<CommunityAddMemberPageBloc>().add(
                                CommunityAddMemberPageSelectUserEvent(
                                    state.users[index]));
                          },
                          child:
                              _getUserListItem(context, state, state.users[index]),
                        );
                      },
                      childCount: state.users.length,
                    ),
                  ),
                ],
              ),
            ),
            _getDividerWidget(),
            _getAddMemberButton(context, state)
          ],
        ));
  }

  Widget _getUserListItem(
      BuildContext context, CommunityAddMemberPageState state, AmityUser user) {
    final bool usePublicProfile = AmityUIKit4Manager
        .freedomBehavior.postContentComponentBehavior.usePublicProfile;
    final getUserPublicProfile = AmityUIKit4Manager
        .freedomBehavior.postContentComponentBehavior.getUserPublicProfile;
    final imageUrl = usePublicProfile ? getUserPublicProfile(user: user) : user.avatarUrl;

    return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Row(children: [
          Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.baseColorShade4,
              ),
              child:  AmityUserAvatar(avatarUrl: imageUrl, displayName: user.displayName ?? context.l10n.user_profile_unknown_name, isDeletedUser: false)),
          const SizedBox(
              width: 8), // Add some spacing between the icon and text
          Expanded(
            child: Text(
              user.displayName ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: theme.baseColor,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: state.selectedUsers.map((e) => e.id).contains(user.id),
              onChanged: (value) {
                context
                    .read<CommunityAddMemberPageBloc>()
                    .add(CommunityAddMemberPageSelectUserEvent(user));
              },
              shape: const CircleBorder(),
              activeColor: theme.primaryColor,
            ),
          )
        ]));
  }

  Widget _userItemWidget(BuildContext context, AmityUser user) {
    final bool usePublicProfile = AmityUIKit4Manager
        .freedomBehavior.postContentComponentBehavior.usePublicProfile;
    final getUserPublicProfile = AmityUIKit4Manager
        .freedomBehavior.postContentComponentBehavior.getUserPublicProfile;
    final imageUrl = usePublicProfile ? getUserPublicProfile(user: user) : user.avatarUrl;

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
                  child:  AmityUserAvatar(avatarUrl: imageUrl, displayName: user.displayName ?? context.l10n.user_profile_unknown_name, isDeletedUser: false)),
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
            user.displayName ?? context.l10n.user_profile_unknown_name,
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

  Widget _getAddMemberButton(
      BuildContext context, CommunityAddMemberPageState state) {
    return Container(
      color: theme.backgroundColor,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Row(
        children: [
          Expanded(
              child: GestureDetector(
            onTap: () {
              if (state.selectedUsers.isNotEmpty) {
                onAddedAction.call(state.selectedUsers);
              }
            },
            child: Container(
                decoration: BoxDecoration(
                  color: state.selectedUsers.isEmpty
                      ? theme.primaryColor.blend(ColorBlendingOption.shade2)
                      : theme.primaryColor, // Rectangle background color
                  borderRadius: BorderRadius.circular(8.0), // Rounded corners
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Text(
                    context.l10n.member_add,
                    style: const TextStyle(
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
}
