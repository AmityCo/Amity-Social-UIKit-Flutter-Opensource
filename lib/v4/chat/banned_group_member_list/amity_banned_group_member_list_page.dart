import 'dart:async';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/chat/group_message/components/amity_group_member_action_component.dart';
import 'package:amity_uikit_beta_service/v4/core/base_page.dart';
import 'package:amity_uikit_beta_service/v4/core/shared/user/user_list.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/amity_uikit_toast.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/top_search_bar/top_search_bar.dart';
import 'package:amity_uikit_beta_service/v4/utils/amity_dialog.dart';
import 'package:amity_uikit_beta_service/v4/utils/debouncer.dart';
import 'package:flutter/material.dart';
import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:equatable/equatable.dart';

part 'amity_banned_group_member_list_state.dart';
part 'amity_banned_group_member_list_cubit.dart';

class AmityBannedGroupMemberListPage extends NewBasePage {
  final AmityChannel channel;

  AmityBannedGroupMemberListPage({
    Key? key,
    required this.channel,
  }) : super(key: key, pageId: 'bannedd_group_member_list_page');

  final ScrollController scrollController = ScrollController();
  final ScrollController horizontalScrollController = ScrollController();
  final TextEditingController textController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 300);

  @override
  Widget buildPage(BuildContext context) {
    
    return BlocProvider(
      create: (context) {
        final cubit = AmityBannedGroupMemberListCubit(
          channel: channel, 
          toastBloc: context.read<AmityToastBloc>()
        );
        return cubit;
      },
      child: Builder(builder: (context) {
            
        return BlocBuilder<AmityBannedGroupMemberListCubit, AmityBannedGroupMemberListState>(
          builder: (context, state) {
            return Stack(
              children: [
                Scaffold(
                  backgroundColor: theme.backgroundColor,
              appBar: AppBar(
                backgroundColor: theme.backgroundColor,
                title: Text(
                  context.l10n.settings_banned_users,
                  style: AmityTextStyle.titleBold(theme.baseColor),
                ),
                leading: IconButton(
                  icon: SvgPicture.asset(
                    'assets/Icons/amity_ic_back_button.svg',
                    package: 'amity_uikit_beta_service',
                    colorFilter: ColorFilter.mode(theme.baseColor, BlendMode.srcIn),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                centerTitle: true,
              ),
              body: Column(
                children: [
                  // Search bar for banned users
                  AmityTopSearchBarComponent(
                    pageId: pageId,
                    textcontroller: textController,
                    hintText: context.l10n.general_search_hint,
                    onTextChanged: (value) {
                      _debouncer.run(() {
                        context
                            .read<AmityBannedGroupMemberListCubit>()
                            .searchBannedUsers(value);
                      });
                    },
                    showCancelButton: false,
                  ),
                  Expanded(child: _buildBannedUsersList(context, state))
                ],
              ),
                ),
                // Add the toast widget to show notifications
                AmityToast(pageId: pageId, elementId: 'group_banned_users_toast'),
              ],
            );
          },
        );
      }),
    );
  }

  Widget _buildBannedUsersList(BuildContext context, AmityBannedGroupMemberListState state) {
    if (state.isLoading && state.bannedUsers.isEmpty) {
      return userSkeletonList(theme, configProvider, itemCount: 10);
    } else if (!state.isLoading && state.bannedUsers.isEmpty) {
      return _buildEmptyState(context);
    } else {
      return _buildBannedUsersListView(context, state);
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/Icons/amity_ic_banned_member_not_found.svg',
            package: 'amity_uikit_beta_service',
            colorFilter:
                ColorFilter.mode(theme.baseColorShade4, BlendMode.srcIn),
            width: 60,
            height: 60,
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.banned_users_empty_state,
            style: AmityTextStyle.titleBold(theme.baseColorShade3),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBannedUsersListView(
      BuildContext context, AmityBannedGroupMemberListState state) {
    final currentUserId = AmityCoreClient.getUserId();
    final isCurrentUserModerator =
        state.currentUserRoles.contains('moderator') ||
            state.currentUserRoles.contains('community-moderator') ||
            state.currentUserRoles.contains('channel-moderator');

    return userList(
      context: context,
      scrollController: scrollController,
      users: state.bannedUsers,
      theme: theme,
      memberRoles: null,
      loadMore: () {
        context.read<AmityBannedGroupMemberListCubit>().loadMoreBannedUsers();
      },
      onTap: (user) {
        if (user.userId != currentUserId && isCurrentUserModerator) {
          _showBannedUserActions(context, user);
        }
      },
      excludeCurrentUser: false,
      onActionTap: (user) {
        _showBannedUserActions(context, user);
      },
      hideActionForCurrentUser: true,
      isLoadingMore: state.isLoading == true && state.bannedUsers.isNotEmpty,
    );
  }

  void _showBannedUserActions(BuildContext context, AmityUser user) {
    final state = context.read<AmityBannedGroupMemberListCubit>().state;
    final cubit = context.read<AmityBannedGroupMemberListCubit>();
    
    final isCurrentUserModerator =
        state.currentUserRoles.contains('moderator') ||
            state.currentUserRoles.contains('channel-moderator');

    if (!isCurrentUserModerator) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (BuildContext bottomSheetContext) {
        return BlocProvider.value(
          value: cubit,
          child: AmityGroupMemberActionComponent(
            user: user,
            isCurrentUserModerator: isCurrentUserModerator,
            isSelectedUserModerator: false,
            isBannedUser: true,
            onUnbanUserTap: () {
              _confirmUnbanUser(context, user);
            },
          ),
        );
      },
    );
  }

  void _confirmUnbanUser(BuildContext context, AmityUser user) {
    final cubit = context.read<AmityBannedGroupMemberListCubit>();


    ConfirmationV4Dialog().show(
      context: context,
      title: context.l10n.user_unban_confirm_title,
      detailText: context.l10n.user_unban_confirm_description,
      leftButtonText: context.l10n.general_cancel,
      leftButtonColor: theme.primaryColor,
      rightButtonText: context.l10n.user_unban_button,
      onConfirm: () {
        cubit.unbanUser(
          user.userId!,
          successMessage: context.l10n.toast_user_unbanned,
          errorMessage: context.l10n.toast_user_unban_error,
        );
      },
    );

  }
}