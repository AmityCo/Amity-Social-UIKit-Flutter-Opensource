import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/base_page.dart';
import 'package:amity_uikit_beta_service/v4/core/shared/user/user_list.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/core/theme/amity_color_token.dart';
import 'package:amity_uikit_beta_service/v4/social/top_search_bar/top_search_bar.dart';
import 'package:amity_uikit_beta_service/v4/utils/debouncer.dart';
import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'amity_add_group_member_cubit.dart';

/// Shared chat search threshold: below this the prompt state shows instead of a query.
const int _minimumSearchLength = 3;

class AmityAddGroupMemberPage extends NewBasePage {
  AmityAddGroupMemberPage({
    Key? key,
    required this.channel,
  }) : super(key: key, pageId: 'add_group_member_page');
  
  final AmityChannel channel;
  final scrollController = ScrollController();
  final horizontalScrollController = ScrollController();
  final textcontroller = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 300);

  @override
  Widget buildPage(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = AmityAddGroupMemberCubit();
        return cubit;
      },
      child: Builder(builder: (context) {
        return BlocBuilder<AmityAddGroupMemberCubit, AmityAddGroupMemberState>(
          builder: (context, state) {
            return Scaffold(
              backgroundColor: token(AmityColorToken.surfacePageBackgroundDefault),
              appBar: AppBar(
                backgroundColor: token(AmityColorToken.surfacePageBackgroundDefault),
                title: Text(
                  context.l10n.chat_add_member,
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
                  },
                ),
                centerTitle: true,
                actions: [
                  TextButton(
                    onPressed: state.selectedUsers.isNotEmpty
                        ? () {
                            Navigator.pop(context, state.selectedUsers);
                          }
                        : null,
                    child: Text(
                      context.l10n.general_add,
                      style: AmityTextStyle.body(
                        state.selectedUsers.isNotEmpty
                            ? token(AmityColorToken.textMainButtonDefaultGhostPrimaryEnabled)
                            : token(AmityColorToken.textMainButtonDefaultGhostPrimaryDisabled),
                      ),
                    ),
                  ),
                ],
              ),
              body: SafeArea(
                child: Column(
                  children: [
                    AmityTopSearchBarComponent(
                      pageId: pageId,
                      textcontroller: textcontroller,
                      hintText: context.l10n.general_search_hint,
                      onTextChanged: (value) {
                        // Below the minimum keyword length the prompt state shows
                        // instead of a live query, so don't hit the SDK at all.
                        if (value.trim().length < _minimumSearchLength) return;
                        _debouncer.run(() {
                          context.read<AmityAddGroupMemberCubit>().queryUser(value);
                        });
                      },
                      showCancelButton: false,
                    ),
                    if (state.selectedUsers.isNotEmpty) ...[
                      Container(
                        height: 93,
                        child: horizontalUserList(
                          context: context,
                          scrollController: horizontalScrollController,
                          users: state.selectedUsers,
                          theme: theme,
                          loadMore: () {
                            // No need to load more for selected users
                          },
                          onTap: (user) {
                            // The chip's close badge deselects the user; membership
                            // is only submitted once the header action confirms.
                            context
                                .read<AmityAddGroupMemberCubit>()
                                .updateSelectedUsers(user);
                          },
                        ),
                      ),
                      Container(
                        height: 1,
                        color: token(AmityColorToken.lineDividerPostDefault),
                      ),
                    ],
                    Expanded(
                      child: ValueListenableBuilder<TextEditingValue>(
                        valueListenable: textcontroller,
                        builder: (context, value, _) =>
                            userContainer(context, state),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget userContainer(BuildContext context, AmityAddGroupMemberState state) {
    if (textcontroller.text.trim().length < _minimumSearchLength) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            context.l10n.search_minimum_chars,
            textAlign: TextAlign.center,
            style: AmityTextStyle.bodyBold(token(AmityColorToken.textBaseSubdue)),
          ),
        ),
      );
    }
    if (state.isFetching == true && state.users.isEmpty) {
      return userSkeletonList(theme, configProvider, itemCount: 10);
    } else {
      if (state.users.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/Icons/amity_ic_search_cross_l.svg',
                package: 'amity_uikit_beta_service',
                colorFilter:
                    ColorFilter.mode(token(AmityColorToken.iconEmptyStateIconDefault), BlendMode.srcIn),
                width: 64,
                height: 64,
              ),
              const SizedBox(height: 10),
              Text(
                'No results found',
                style: TextStyle(
                  color: token(AmityColorToken.textBaseSubdue),
                  fontWeight: FontWeight.w600,
                  fontSize: 17,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      } else {
        return multiSelectUserList(
          context: context,
          scrollController: scrollController,
          users: state.users,
          theme: theme,
          loadMore: () {
            // Implement load more functionality with cubit if needed
            context.read<AmityAddGroupMemberCubit>().loadmoreUsers();
          },
          onSelectUser: (user) {
            context.read<AmityAddGroupMemberCubit>().updateSelectedUsers(user);
          },
          excludeCurrentUser: true,
          selectedUsers: state.selectedUsers,
          isLoadingMore: state.isFetching == true && state.users.isNotEmpty,
        );
      }
    }
  }
}