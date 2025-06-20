import 'dart:async';

import 'package:amity_sdk/amity_sdk.dart';
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
                final TabController tabController = DefaultTabController.of(context);
                
                // Listen to tab changes
                tabController.addListener(() {

                  if (!tabController.indexIsChanging) {
                    final cubit = context.read<AmityGroupMemberListCubit>();
                    final newTab = tabController.index == 0 ? 'all' : 'moderators';
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
                      'All members',
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
                        tabs: const [
                          Tab(text: 'Members'),
                          Tab(text: 'Moderators'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildTabContent(context, state, memberScrollController),
                            _buildTabContent(context, state, moderatorScrollController),
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

  Widget _buildTabContent(BuildContext context, AmityGroupMemberListState state, ScrollController scrollController) {
    return Column(
      children: [
        AmityTopSearchBarComponent(
          pageId: pageId,
          textcontroller: textController,
          hintText: 'Search member',
          showCancelButton: false,
          onTextChanged: (value) {
            _debouncer.run(() {
              context
                  .read<AmityGroupMemberListCubit>()
                  .searchMembers(value);
            });
          },
        ),
        Expanded(
          child: _buildMembersList(context, state, scrollController),
        )
      ],
    );
  }

  Widget _buildMembersList(BuildContext context, AmityGroupMemberListState state, ScrollController scrollController) {
    // Since the cubit already filters data based on activeTab, we just use state.members directly
    final filteredMembers = state.members;

    if (state.isLoading && filteredMembers.isEmpty) {
      return userSkeletonList(theme, configProvider, itemCount: 10);
    } else if (!state.isLoading && filteredMembers.isEmpty) {
      return _buildEmptyState();
    } else {
      return _buildMembersListView(context, state, scrollController);
    }
  }

  Widget _buildEmptyState() {
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
            'No members found',
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

  Widget _buildMembersListView(
      BuildContext context, AmityGroupMemberListState state, ScrollController scrollController) {
    final currentUserId = AmityCoreClient.getUserId();

    return groupUserList(
      context: context,
      scrollController: scrollController,
      users: state.members,
      theme: theme,
      memberRoles: state.memberRoles,
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
          ),
        );
      },
    );
  }

  void _confirmPromoteModerator(BuildContext context, AmityUser user) {
    final cubit = context.read<AmityGroupMemberListCubit>();
    ConfirmationV4Dialog().show(
      context: context,
      title: 'Moderator promotion',
      detailText:
          "Are you sure you want to promote this member to Moderator? They will gain access to all moderator features.",
      leftButtonText: 'Cancel',
      leftButtonColor: theme.primaryColor,
      rightButtonText: 'Promote',
      onConfirm: () {
        cubit.addModerator(user.userId!);
      },
    );
  }

  void _confirmDemoteModerator(BuildContext context, AmityUser user) {
    final cubit = context.read<AmityGroupMemberListCubit>();
    ConfirmationV4Dialog().show(
      context: context,
      title: 'Moderator demotion',
      detailText:
          "Are you sure you want to demote this Moderator? They will lose access to all moderator features.",
      leftButtonText: 'Cancel',
      rightButtonText: 'Demote',
      onConfirm: () {
        cubit.removeModerator(user.userId!);
      },
    );
  }

  void _confirmRemoveMember(BuildContext context, AmityUser user) {
    final cubit = context.read<AmityGroupMemberListCubit>();
    ConfirmationV4Dialog().show(
      context: context,
      title: 'Confirm removal',
      detailText:
          "Are you sure you want to remove this member from the group? They will be aware of their removal.",
      leftButtonText: 'Cancel',
      rightButtonText: 'Remove',
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
      title: 'Confirm ban',
      detailText:
          "Are you sure you want to ban this user? They will be removed from the group and won't be able to find it or rejoin unless they are unbanned.",
      leftButtonText: 'Cancel',
      rightButtonText: 'Ban',
      onConfirm: () {
        cubit.banUser(user.userId!);
      },
    );
  }

  void _reportUser(BuildContext context, AmityUser user) {
    final cubit = context.read<AmityGroupMemberListCubit>();
    cubit.reportUser(user);
  }
}
