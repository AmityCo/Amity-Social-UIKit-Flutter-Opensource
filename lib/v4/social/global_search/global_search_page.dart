import 'package:amity_uikit_beta_service/v4/core/base_page.dart';
import 'package:amity_uikit_beta_service/v4/social/community_search_result/community_search_result.dart';
import 'package:amity_uikit_beta_service/v4/social/global_search/bloc/global_search_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/global_search/view_model/global_search_view_model.dart';
import 'package:amity_uikit_beta_service/v4/social/top_search_bar/top_search_bar.dart';
import 'package:amity_uikit_beta_service/v4/social/user_search_result/user_search_result.dart';
import 'package:amity_uikit_beta_service/v4/utils/debouncer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AmitySocialGlobalSearchPage extends NewBasePage {
  AmitySocialGlobalSearchPage({Key? key, String? pageId})
      : super(key: key, pageId: 'social_global_search_page');
  var textcontroller = TextEditingController();
  final ScrollController communityScrollController = ScrollController();
  final ScrollController userScrollController = ScrollController();

  final _debouncer = Debouncer(milliseconds: 300);

  bool isLoaded = false;
  late AmityGlobalSearchViewModel communitySearchViewModel;
  late AmityGlobalSearchViewModel userSearchViewModel;

  @override
  Widget buildPage(BuildContext context) {
    communitySearchViewModel = AmityGlobalSearchViewModel(
        searchType: AmityGlobalSearchType.community,
        scrollController: communityScrollController);
    userSearchViewModel = AmityGlobalSearchViewModel(
        searchType: AmityGlobalSearchType.user,
        scrollController: userScrollController);

    return BlocProvider(
      create: (_) => GlobalSearchBloc(),
      child: BlocBuilder<GlobalSearchBloc, GlobalSearchState>(
        builder: (context, state) {
          if (state is GlobalSearchLoaded) {
            isLoaded = true;
            communitySearchViewModel.updateCommunityModel(
                communities: state.communities,
                isFetching: state.isFetching,
                loadMore: () {
                  context
                      .read<GlobalSearchBloc>()
                      .add(const GlobalSearchLoadMoreEvent());
                });
          } else if (state is GlobalUserSearchLoaded) {
            isLoaded = true;
            userSearchViewModel.updateUserModel(
                users: state.users,
                isFetching: state.isFetching,
                loadMore: () {
                  context
                      .read<GlobalSearchBloc>()
                      .add(const GlobalUserSearchLoadMoreEvent());
                });
          }

          return DefaultTabController(
            length: 2,
            child: Scaffold(
              backgroundColor: theme.backgroundColor,
              body: SafeArea(
                bottom: false,
                child: Stack(
                  children: [
                    Column(
                      children: [
                        AmityTopSearchBarComponent(
                          pageId: pageId,
                          textcontroller: textcontroller,
                          hintText: 'Search community and user',
                          onTextChanged: (value) {
                            _debouncer.run(() {
                              context
                                  .read<GlobalSearchBloc>()
                                  .add(SearchCommunitiesEvent(value));
                              context
                                  .read<GlobalSearchBloc>()
                                  .add(SearchUsersEvent(value));
                            });
                          },
                        ),
                        if (textcontroller.text.isEmpty && !isLoaded)
                          const SizedBox()
                        else
                          Container(
                            color: theme.backgroundColor,
                            child: TabBar(
                              dividerHeight: 0.2,
                              dividerColor: theme.baseColorShade3,
                              tabAlignment: TabAlignment.start,
                              isScrollable: true,
                              labelColor: theme.primaryColor,
                              indicator: UnderlineTabIndicator(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  width: 2.0,
                                  color: theme.primaryColor,
                                ),
                              ),
                              indicatorColor: Colors.transparent,
                              labelStyle: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: theme.primaryColor,
                                fontFamily: 'SF Pro Text',
                              ),
                              unselectedLabelStyle: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: theme.baseColorShade3,
                                fontFamily: 'SF Pro Text',
                              ),
                              tabs: const [
                                Tab(text: "Communities"),
                                Tab(text: "Users"),
                              ],
                            ),
                          ),
                        if (isLoaded)
                          Expanded(
                            child: TabBarView(
                              children: [
                                AmityCommunitySearchResultComponent(
                                    pageId: pageId,
                                    viewModel: communitySearchViewModel),
                                AmityUserSearchResultComponent(
                                    pageId: pageId,
                                    viewModel: userSearchViewModel)
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
