import 'dart:async';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:amity_uikit_beta_service/v4/chat/add_group_member/amity_add_group_member_page.dart';
import 'package:amity_uikit_beta_service/v4/chat/group_message/components/amity_group_member_action_component.dart';
import 'package:amity_uikit_beta_service/v4/core/base_page.dart';
import 'package:amity_uikit_beta_service/v4/core/shared/user/user_list.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/amity_uikit_toast.dart';
import 'package:amity_uikit_beta_service/v4/social/top_search_bar/top_search_bar.dart';
import 'package:amity_uikit_beta_service/v4/utils/amity_dialog.dart';
import 'package:amity_uikit_beta_service/v4/utils/debouncer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:equatable/equatable.dart';

part 'amity_group_member_list_state.dart';
part 'amity_group_member_list_cubit.dart';

class AmityGroupMemberListPage extends NewBasePage {
  final AmityChannel channel;

  AmityGroupMemberListPage({
    Key? key,
    required this.channel,
  }) : super(key: key, pageId: 'group_member_list_page');

  final ScrollController memberScrollController = ScrollController();
  final ScrollController moderatorScrollController = ScrollController();
  final ScrollController horizontalScrollController = ScrollController();
  final textController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 300);

  @override
  Widget buildPage(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = AmityGroupMemberListCubit(
            channel: channel, toastBloc: context.read<AmityToastBloc>());
        return cubit;
      },
      child: BlocBuilder<AmityGroupMemberListCubit, AmityGroupMemberListState>(
        builder: (context, state) {
          return DefaultTabController(
            length: 2,
            child: Builder(
              builder: (context) {
                final TabController tabController =
                    DefaultTabController.of(context);

                // Listen to tab changes
                tabController.addListener(() {
                  if (!tabController.indexIsChanging) {
                    final cubit = context.read<AmityGroupMemberListCubit>();
                    final newTab =
                        tabController.index == 0 ? 'all' : 'moderators';
                    cubit.changeTab(newTab);
                    // Clear search when switching tabs
                    textController.clear();
                  }
                });

                return Scaffold(
                  backgroundColor: theme.backgroundColor,
                  appBar: AppBar(
                    backgroundColor: theme.backgroundColor,
                    title: Text(
                      context.l10n.community_all_members,
                      style: AmityTextStyle.titleBold(theme.baseColor),
                    ),
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    centerTitle: true,
                    actions: state.isCurrentUserModerator
                        ? [
                            GestureDetector(
                              onTap: () => _navigateToSelectUsers(context),
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
                          ]
                        : [],
                  ),
                  body: Column(
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
                        dividerHeight: 1.0,
                        tabs: [
                          Tab(text: context.l10n.community_members),
                          Tab(text: context.l10n.community_moderators),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildTabContent(
                                context, state, memberScrollController),
                            _buildTabContent(
                                context, state, moderatorScrollController),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabContent(BuildContext context, AmityGroupMemberListState state,
      ScrollController scrollController) {
    return Column(
      children: [
        AmityTopSearchBarComponent(
          pageId: pageId,
          textcontroller: textController,
          hintText: context.l10n.community_search_member_hint,
          showCancelButton: false,
          onTextChanged: (value) {
            _debouncer.run(() {
              context.read<AmityGroupMemberListCubit>().searchMembers(value);
            });
          },
        ),
        Expanded(
          child: _buildMembersList(context, state, scrollController),
        )
      ],
    );
  }

  Widget _buildMembersList(BuildContext context,
      AmityGroupMemberListState state, ScrollController scrollController) {
    // Since the cubit already filters data based on activeTab, we just use state.members directly
    final filteredMembers = state.members;

    if (state.isLoading && filteredMembers.isEmpty) {
      return userSkeletonList(theme, configProvider, itemCount: 10);
    } else if (!state.isLoading && filteredMembers.isEmpty) {
      return _buildEmptyState(context);
    } else {
      return _buildMembersListView(context, state, scrollController);
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/Icons/amity_ic_search_not_found.svg',
            package: 'amity_uikit_beta_service',
            colorFilter:
                ColorFilter.mode(theme.baseColorShade4, BlendMode.srcIn),
            width: 47,
            height: 47,
          ),
          const SizedBox(height: 10),
          Text(
            context.l10n.search_no_members_found,
            style: TextStyle(
              color: theme.baseColorShade3,
              fontWeight: FontWeight.w600,
              fontSize: 17,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMembersListView(BuildContext context,
      AmityGroupMemberListState state, ScrollController scrollController) {
    final currentUserId = AmityCoreClient.getUserId();

    return groupUserList(
      context: context,
      scrollController: scrollController,
      users: state.members,
      theme: theme,
      memberRoles: state.memberRoles,
      mutedUsers: state.mutedUsers,
      loadMore: () {
        context.read<AmityGroupMemberListCubit>().loadMoreMembers();
      },
      onTap: (user) {
        if (user.userId != currentUserId) {
          _showMemberActions(context, user);
        }
      },
      excludeCurrentUser: false,
      onActionTap: (user) {
        if (user.userId != currentUserId) {
          _showMemberActions(context, user);
        }
      },
      hideActionForCurrentUser: true,
      currentUserId: currentUserId,
      isCurrentUserModerator: state.isCurrentUserModerator,
      isLoadingMoreMember: state.isLoading,
    );
  }

  void _navigateToSelectUsers(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AmityAddGroupMemberPage(
          channel: channel,
        ),
      ),
    );

    if (result != null && result is List<AmityUser> && context.mounted) {
      context.read<AmityGroupMemberListCubit>().addMembersToChannel(result);
    }
  }

  void _showMemberActions(BuildContext context, AmityUser user) {
    final state = context.read<AmityGroupMemberListCubit>().state;
    final cubit = context.read<AmityGroupMemberListCubit>();
    final isUserModerator =
        state.memberRoles[user.userId]?.contains('channel-moderator') ?? false;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext bottomSheetContext) {
        return BlocProvider.value(
          value: cubit,
          child: AmityGroupMemberActionComponent(
            user: user,
            isCurrentUserModerator: state.isCurrentUserModerator,
            isSelectedUserModerator: isUserModerator,
            isMuted: state.mutedUsers[user.userId!] ?? false,
            onRemoveTap: () {
              _confirmRemoveMember(context, user);
            },
            onModeratorToggleTap: () {
              if (isUserModerator) {
                _confirmDemoteModerator(context, user);
              } else {
                _confirmPromoteModerator(context, user);
              }
            },
            onBanUserTap: () {
              _confirmBanUser(context, user);
            },
            onReportUserTap: () {
              _reportUser(context, user);
            },
            onMuteToggleTap: () {
              _toggleMuteUser(context, user);
            },
          ),
        );
      },
    );
  }

  void _confirmPromoteModerator(BuildContext context, AmityUser user) {
    final cubit = context.read<AmityGroupMemberListCubit>();
    ConfirmationV4Dialog().show(
      context: context,
      title: context.l10n.moderator_promotion_title,
      detailText: context.l10n.moderator_promotion_description,
      leftButtonText: context.l10n.general_cancel,
      leftButtonColor: theme.primaryColor,
      rightButtonText: context.l10n.moderator_promote_button,
      onConfirm: () {
        cubit.addModerator(user.userId!);
      },
    );
  }

  void _confirmDemoteModerator(BuildContext context, AmityUser user) {
    final cubit = context.read<AmityGroupMemberListCubit>();
    ConfirmationV4Dialog().show(
      context: context,
      title: context.l10n.moderator_demotion_title,
      detailText: context.l10n.moderator_demotion_description,
      leftButtonText: context.l10n.general_cancel,
      rightButtonText: context.l10n.moderator_demote_button,
      onConfirm: () {
        cubit.removeModerator(user.userId!);
      },
    );
  }

  void _confirmRemoveMember(BuildContext context, AmityUser user) {
    final cubit = context.read<AmityGroupMemberListCubit>();
    ConfirmationV4Dialog().show(
      context: context,
      title: context.l10n.member_removal_confirm_title,
      detailText: context.l10n.member_removal_confirm_description,
      leftButtonText: context.l10n.general_cancel,
      rightButtonText: context.l10n.member_remove_button,
      leftButtonColor: theme.alertColor,
      onConfirm: () {
        cubit.removeMember(user.userId!);
      },
    );
  }

  void _confirmBanUser(BuildContext context, AmityUser user) {
    final cubit = context.read<AmityGroupMemberListCubit>();
    ConfirmationV4Dialog().show(
      context: context,
      title: context.l10n.user_ban_confirm_title,
      detailText: context.l10n.user_ban_confirm_description,
      leftButtonText: context.l10n.general_cancel,
      rightButtonText: context.l10n.user_ban_button,
      onConfirm: () {
        cubit.banUser(user.userId!);
      },
    );
  }

  void _reportUser(BuildContext context, AmityUser user) {
    final cubit = context.read<AmityGroupMemberListCubit>();
    cubit.reportUser(user);
  }

  void _toggleMuteUser(BuildContext context, AmityUser user) {
    if (user.userId == null) return;

    // Check if user is currently muted
    final cubit = context.read<AmityGroupMemberListCubit>();
    final isMuted = cubit.state.mutedUsers[user.userId!] ?? false;

    // Show appropriate confirmation dialog
    if (isMuted) {
      _confirmUnmuteUser(context, user);
    } else {
      _confirmMuteUser(context, user);
    }
  }

  void _confirmMuteUser(BuildContext context, AmityUser user) {
    final cubit = context.read<AmityGroupMemberListCubit>();
    ConfirmationV4Dialog().show(
      context: context,
      title: 'Confirm mute',
      detailText:
          "Are you sure you want to mute this user? They will no longer be able to send or react to messages.",
      leftButtonText: 'Cancel',
      rightButtonText: 'Mute',
      leftButtonColor: theme.alertColor,
      onConfirm: () {
        cubit.toggleMuteUser(user.userId!);
      },
    );
  }

  void _confirmUnmuteUser(BuildContext context, AmityUser user) {
    final cubit = context.read<AmityGroupMemberListCubit>();
    ConfirmationV4Dialog().show(
      context: context,
      title: 'Confirm unmute',
      detailText:
          "Are you sure you want to unmute this user? They can now send or react to messages.",
      leftButtonText: 'Cancel',
      rightButtonText: 'Unmute',
      onConfirm: () {
        cubit.toggleMuteUser(user.userId!);
      },
    );
  }
}
