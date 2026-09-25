import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:amity_uikit_beta_service/v4/chat/create/bloc/channel_create_conversation_bloc.dart';
import 'package:amity_uikit_beta_service/v4/chat/message/chat_page.dart';
import 'package:amity_uikit_beta_service/v4/core/base_page.dart';
import 'package:amity_uikit_beta_service/v4/core/shared/user/user_list.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/core/ui/atoms/amity_empty_state.dart';
import 'package:amity_uikit_beta_service/v4/social/top_search_bar/top_search_bar.dart';
import 'package:amity_uikit_beta_service/v4/utils/debouncer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:amity_uikit_beta_service/v4/core/theme/amity_color_token.dart';

class AmityChannelCreateConversationPage extends NewBasePage {
  AmityChannelCreateConversationPage({Key? key})
      : super(key: key, pageId: 'create_conversation_page');
  final ScrollController scrollController = ScrollController();
  final textcontroller = TextEditingController();
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
              backgroundColor: token(AmityColorToken.surfacePageBackgroundDefault),
              appBar: AppBar(
                backgroundColor: token(AmityColorToken.surfacePageBackgroundDefault),
                title: Text(
                  context.l10n.chat_new_conversation,
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
              ),
              body: Column(
                children: [
                  AmityTopSearchBarComponent(
                    pageId: pageId,
                    textcontroller: textcontroller,
                    hintText: context.l10n.general_search_hint,
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
      if (state.isFetching && state.list.isEmpty) {
        return userSkeletonList(theme, configProvider, itemCount: 10);
      } else {
        if (state.list.isEmpty) {
            final isInitialSearch = state.searchText.isNotEmpty && state.searchText.length < 3;
            
            return AmityEmptyState(
              variant: AmityEmptyStateVariant.icon,
              asset: isInitialSearch
                  ? 'assets/Icons/amity_ic_search_user.svg'
                  : 'assets/Icons/amity_ic_search_cross_l.svg',
              title: isInitialSearch
                  ? context.l10n.search_minimum_characters
                  : context.l10n.search_no_results,
            );
        } else {
          return userList(
            context: context,
            scrollController: scrollController,
            users: state.list,
            theme: theme,
            memberRoles: null,
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
                  isJustCreated: true,
                ),
              ));
            },
            excludeCurrentUser: true,
            isLoadingMore: state.isFetching == true && state.list.isNotEmpty,
          );
        }
      }
    } else {
      return Container();
    }
  }
}
