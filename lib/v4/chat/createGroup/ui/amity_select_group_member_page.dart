import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/chat/createGroup/ui/amity_create_group_page.dart';
import 'package:amity_uikit_beta_service/v4/core/base_page.dart';
import 'package:amity_uikit_beta_service/v4/core/shared/user/user_list.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/core/theme/amity_color_token.dart';
import 'package:amity_uikit_beta_service/v4/core/ui/atoms/amity_empty_state.dart';
import 'package:amity_uikit_beta_service/v4/social/top_search_bar/top_search_bar.dart';
import 'package:amity_uikit_beta_service/v4/utils/debouncer.dart';
import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import '../bloc/amity_select_group_member_cubit.dart';

class AmitySelectGroupMemberPage extends NewBasePage {
  AmitySelectGroupMemberPage._({
    Key? key, 
    required this.isModifyMember, 
    required this.selectedGroupMember,
    this.onMembersSelected,
  }) : super(key: key, pageId: 'select_group_member_page');
  
  factory AmitySelectGroupMemberPage({
    Key? key,
    bool? isModifyMember,
    List<dynamic>? selectedGroupMember,
    Function(List<AmityUser>)? onMembersSelected,
  }) {
    return AmitySelectGroupMemberPage._(
      key: key,
      isModifyMember: isModifyMember ?? false,
      selectedGroupMember: selectedGroupMember ?? const [],
      onMembersSelected: onMembersSelected,
    );
  }
  
  final bool isModifyMember;
  final List<dynamic> selectedGroupMember;
  final Function(List<AmityUser>)? onMembersSelected;
  final scrollController = ScrollController();
  final horizontalScrollController = ScrollController();
  final textcontroller = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 300);

  @override
  Widget buildPage(BuildContext context) {
    // Process selectedGroupMember to ensure we have valid AmityUser objects
    final List<AmityUser> initialSelectedUsers = [];
    for (var member in selectedGroupMember) {
      if (member is AmityUser) {
        initialSelectedUsers.add(member);
      }
    }

    return BlocProvider(
      create: (context) {
        final cubit = AmitySelectGroupMemberCubit();
        // Initialize state with selected users
        if (initialSelectedUsers.isNotEmpty) {
          cubit.initializeSelectedUsers(initialSelectedUsers);
        }
        return cubit;
      },
      child: Builder(builder: (context) {
        // Initialize user list
        context.read<AmitySelectGroupMemberCubit>().queryUser('');

        return BlocBuilder<AmitySelectGroupMemberCubit, AmitySelectGroupMemberState>(
          builder: (context, state) {
            return Scaffold(
              backgroundColor: token(AmityColorToken.surfacePageBackgroundDefault),
              appBar: AppBar(
                backgroundColor: token(AmityColorToken.surfacePageBackgroundDefault),
                title: Text(
                  context.l10n.chat_select_member_title,
                  style: AmityTextStyle.titleBold(token(AmityColorToken.textListHeaderDefaultDefault)),
                ),
                leading: IconButton(
                  icon: SvgPicture.asset(
                    'assets/Icons/amity_ic_close_button.svg',
                    package: 'amity_uikit_beta_service',
                    width: 24,
                    height: 24,
                    colorFilter:
                        ColorFilter.mode(token(AmityColorToken.textListHeaderDefaultDefault), BlendMode.srcIn),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    // Handle the close action
                  },
                ),
                centerTitle: true,
                actions: [
                  TextButton(
                    onPressed: state.selectedUsers.isEmpty 
                        ? null 
                        : () {
                      if (state.selectedUsers.isEmpty) {
                        // Don't navigate if no users are selected
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(context.l10n.chat_select_member_error)),
                        );
                        return;
                      }

                      if (isModifyMember) {
                        // Return selected members to previous page
                        Navigator.pop(context, state.selectedUsers);
                        // Also call the callback if provided
                        onMembersSelected?.call(state.selectedUsers);
                      } else {
                        // Original flow for creating new group
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AmityCreateGroupChatPage(
                              selectedUsers: state.selectedUsers,
                              onUserRemoved: (user) {
                                // If you need to handle removed users
                              },
                            ),
                          ),
                        );
                      }
                    },
                    child: Text(
                      context.l10n.general_next,
                      style: AmityTextStyle.body(state.selectedUsers.isEmpty
                          ? token(AmityColorToken.surfaceMainButtonDefaultFilledPrimaryDisabled)
                          : token(AmityColorToken.textBaseHighlight)),
                    ),
                  ),
                ],
              ),
              body: Column(
                children: [
                  AmityTopSearchBarComponent(
                    pageId: pageId,
                    textcontroller: textcontroller,
                    hintText: context.l10n.general_search_hint,
                    onTextChanged: (value) {
                      _debouncer.run(() {
                        context.read<AmitySelectGroupMemberCubit>().queryUser(value);
                      });
                    },
                    showCancelButton: false,
                  ),
                  if (state.selectedUsers.isNotEmpty) ...[
                    Container(
                      height: 106,
                      child: horizontalUserList(
                        context: context,
                        scrollController: horizontalScrollController,
                        users: state.selectedUsers,
                        theme: theme,
                        loadMore: () {
                          // No need to load more for selected users
                        },
                        onTap: (user) {
                          // Remove user from selection when tapped
                          context
                              .read<AmitySelectGroupMemberCubit>()
                              .updateSelectedUsers(user);
                        },
                      ),
                    ),
                    Container(
                      height: 1,
                      color: token(AmityColorToken.lineDividerContentDefault),
                    ),
                  ],
                  Expanded(child: userContainer(context, state))
                ],
              ),
            );
          },
        );
      }),
    );
  }

  Widget userContainer(BuildContext context, AmitySelectGroupMemberState state) {
    if (state.isFetching == true && state.users.isEmpty) {
      return userSkeletonList(theme, configProvider, itemCount: 10);
    } else if (state.isFetching == false && state.users.isEmpty) {
      return Container();
    } else {
      if (state.users.isEmpty) {
        // EmptyState atom, icon variant: 64 `search-cross-l` on
        // `Icon/EmptyState/Icon/Default` — the light-weight glyph Android draws.
        return AmityEmptyState(
          variant: AmityEmptyStateVariant.icon,
          asset: 'assets/Icons/amity_ic_search_cross_l.svg',
          title: context.l10n.search_no_results,
        );
      } else {
        return multiSelectUserList(
          context: context,
          scrollController: scrollController,
          users: state.users,
          theme: theme,
          loadMore: () {
            // Implement load more functionality with cubit if needed
            context.read<AmitySelectGroupMemberCubit>().loadmoreUsers();
          },
          onSelectUser: (user) {
            context.read<AmitySelectGroupMemberCubit>().updateSelectedUsers(user);
            // Handle user tap
          },
          excludeCurrentUser: true,
          selectedUsers: state.selectedUsers,
          isLoadingMore: state.isFetching == true && state.users.isNotEmpty,
        );
      }
    }
  }
}
