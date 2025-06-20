import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/base_page.dart';
import 'package:amity_uikit_beta_service/v4/core/shared/user/user_list.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/social/top_search_bar/top_search_bar.dart';
import 'package:amity_uikit_beta_service/v4/utils/debouncer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'amity_add_group_member_cubit.dart';

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
        // Initialize user list
        context.read<AmityAddGroupMemberCubit>().queryUser('');

        return BlocBuilder<AmityAddGroupMemberCubit, AmityAddGroupMemberState>(
          builder: (context, state) {
            return Scaffold(
              backgroundColor: theme.backgroundColor,
              appBar: AppBar(
                backgroundColor: theme.backgroundColor,
                title: Text(
                  'Add Member',
                  style: AmityTextStyle.titleBold(theme.baseColor),
                ),
                leading: IconButton(
                  icon: SvgPicture.asset(
                    'assets/Icons/amity_ic_close_button.svg',
                    package: 'amity_uikit_beta_service',
                    width: 24,
                    height: 24,
                    colorFilter:
                        ColorFilter.mode(theme.baseColor, BlendMode.srcIn),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                centerTitle: true,
              ),
              body: SafeArea(
                child: Column(
                  children: [
                    AmityTopSearchBarComponent(
                      pageId: pageId,
                      textcontroller: textcontroller,
                      hintText: 'Search',
                      onTextChanged: (value) {
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
                            AmityChatClient.newChannelRepository()
                                .addMembers(channel.channelId!, [user.userId!]);
                          },
                        ),
                      ),
                      Container(
                        height: 1,
                        color: theme.baseColorShade4,
                      ),
                    ],
                    Expanded(child: userContainer(context, state)),
                    Container(
                      height: 1,
                      color: theme.baseColorShade4,
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: state.selectedUsers.isNotEmpty 
                            ? () {
                                Navigator.pop(context, state.selectedUsers);
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: state.selectedUsers.isNotEmpty 
                            ? theme.primaryColor
                            : theme.primaryColor.blend(ColorBlendingOption.shade2),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          disabledBackgroundColor: theme.primaryColor.blend(ColorBlendingOption.shade2),
                        ),
                        child: Text(
                          'Add Member',
                          style: AmityTextStyle.bodyBold(Colors.white),
                        ),
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
    if (state.isFetching == true && state.users.isEmpty) {
      return userSkeletonList(theme, configProvider, itemCount: 10);
    } else if (state.isFetching == false && state.users.isEmpty) {
      return Container();
    } else {
      if (state.users.isEmpty) {
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
                'No results found',
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