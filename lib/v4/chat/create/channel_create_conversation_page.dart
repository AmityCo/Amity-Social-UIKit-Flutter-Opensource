import 'package:amity_uikit_beta_service/v4/chat/create/bloc/channel_create_conversation_bloc.dart';
import 'package:amity_uikit_beta_service/v4/chat/message/chat_page.dart';
import 'package:amity_uikit_beta_service/v4/core/base_page.dart';
import 'package:amity_uikit_beta_service/v4/core/shared/user/user_list.dart';
import 'package:amity_uikit_beta_service/v4/social/top_search_bar/top_search_bar.dart';
import 'package:amity_uikit_beta_service/v4/utils/debouncer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class AmityChannelCreateConversationPage extends NewBasePage {
  AmityChannelCreateConversationPage({Key? key})
      : super(key: key, pageId: 'create_conversation_page');
  final ScrollController scrollController = ScrollController();
  var textcontroller = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 300);

  @override
  Widget buildPage(BuildContext context) {
    return BlocProvider(
      create: (context) => ChannelCreateConversationBloc(),
      child: Builder(builder: (context) {
        context
            .read<ChannelCreateConversationBloc>()
            .add(ChannelCreateConversationEventInitial());

        return BlocBuilder<ChannelCreateConversationBloc,
            ChannelCreateConversationState>(
          builder: (context, state) {
            return Scaffold(
              backgroundColor: theme.backgroundColor,
              appBar: AppBar(
                backgroundColor: theme.backgroundColor,
                title: const Text(
                  'New conversation',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
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
                    // Handle the close action
                  },
                ),
                centerTitle: true,
              ),
              body: Column(
                children: [
                  AmityTopSearchBarComponent(
                    pageId: pageId,
                    textcontroller: textcontroller,
                    hintText: 'Search',
                    onTextChanged: (value) {
                      _debouncer.run(() {
                        context
                            .read<ChannelCreateConversationBloc>()
                            .add(SearchUsersEvent(value));
                      });
                    },
                    showCancelButton: false,
                  ),
                  Expanded(child: userContainer(context, state))
                ],
              ),
            );
          },
        );
      }),
    );
  }

  Widget userContainer(
      BuildContext context, ChannelCreateConversationState state) {
    if (state is ChannelCreateConversationLoaded) {
      if (state.isFetching) {
        return userSkeletonList(theme, configProvider, itemCount: 10);
      } else {
        if (state.list.isEmpty) {
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
                ),
              ],
            ),
          );
        } else {
          return userList(
            context: context,
            scrollController: scrollController,
            users: state.list,
            theme: theme,
            loadMore: () {
              context
                  .read<ChannelCreateConversationBloc>()
                  .add(ChannelCreateConversationEventLoadMore());
            },
            onTap: (user) {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => AmityChatPage(
                  key: Key("${user.userId}"),
                  userId: user.userId,
                  userDisplayName: user.displayName,
                  avatarUrl: user.avatarUrl ?? "",
                ),
              ));
            },
            excludeCurrentUser: true,
          );
        }
      }
    } else {
      return Container();
    }
  }
}
