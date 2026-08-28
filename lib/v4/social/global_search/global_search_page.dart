import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:amity_uikit_beta_service/v4/core/base_page.dart';
import 'package:amity_uikit_beta_service/v4/social/community_search_result/community_search_result.dart';
import 'package:amity_uikit_beta_service/v4/social/global_search/bloc/global_search_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/global_search/view_model/global_search_view_model.dart';
import 'package:amity_uikit_beta_service/v4/social/post_search_result/post_search_result.dart';
import 'package:amity_uikit_beta_service/v4/social/top_search_bar/top_search_bar.dart';
import 'package:amity_uikit_beta_service/v4/social/user_search_result/user_search_result.dart';
import 'package:amity_uikit_beta_service/v4/utils/config_provider.dart';
import 'package:amity_uikit_beta_service/v4/utils/debouncer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

class AmitySocialGlobalSearchPage extends NewBasePage {
  AmitySocialGlobalSearchPage({Key? key, String? pageId})
      : super(key: key, pageId: 'social_global_search_page');

  @override
  Widget buildPage(BuildContext context) {
    return BlocProvider(
      create: (_) => GlobalSearchBloc(),
      child: _GlobalSearchBody(pageId: pageId),
    );
  }
}

class _GlobalSearchBody extends StatefulWidget {
  final String pageId;

  const _GlobalSearchBody({required this.pageId});

  @override
  State<_GlobalSearchBody> createState() => _GlobalSearchBodyState();
}

class _GlobalSearchBodyState extends State<_GlobalSearchBody>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _communityScrollController = ScrollController();
  final ScrollController _userScrollController = ScrollController();
  final ScrollController _postScrollController = ScrollController();
  final _debouncer = Debouncer(milliseconds: 300);

  late final AmityGlobalSearchViewModel _communitySearchViewModel;
  late final AmityGlobalSearchViewModel _userSearchViewModel;
  late final AmityGlobalSearchViewModel _postSearchViewModel;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _communitySearchViewModel = AmityGlobalSearchViewModel(
        searchType: AmityGlobalSearchType.community,
        scrollController: _communityScrollController);
    _userSearchViewModel = AmityGlobalSearchViewModel(
        searchType: AmityGlobalSearchType.user,
        scrollController: _userScrollController);
    _postSearchViewModel = AmityGlobalSearchViewModel(
        searchType: AmityGlobalSearchType.post,
        scrollController: _postScrollController);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _textController.dispose();
    _communityScrollController.dispose();
    _userScrollController.dispose();
    _postScrollController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    if (_textController.text.isNotEmpty) {
      _triggerSearch(_textController.text);
    } else {
      setState(() {});
    }
  }

  // Results are tagged with the keyword they were fetched for. A search that
  // resolves after the user has typed further is no longer current, and must
  // not overwrite the view model.
  bool _isCurrent(String searchText) => searchText == _textController.text;

  void _markActiveTabFetching() {
    switch (_tabController.index) {
      case 0:
        _postSearchViewModel.isPostsFetching = true;
        break;
      case 1:
        _communitySearchViewModel.isCommunitiesFetching = true;
        break;
      case 2:
        _userSearchViewModel.isUsersFetching = true;
        break;
    }
    setState(() {});
  }

  void _onTextChanged(String text) {
    if (text.isEmpty) {
      _postSearchViewModel.hasSearched = false;
      _communitySearchViewModel.hasSearched = false;
      _userSearchViewModel.hasSearched = false;
      setState(() {});
      return;
    }
    _markActiveTabFetching();
    _debouncer.run(() {
      if (_textController.text.isEmpty) return;
      _triggerSearch(_textController.text);
    });
  }

  void _triggerSearch(String text) {
    final bloc = context.read<GlobalSearchBloc>();
    switch (_tabController.index) {
      case 0:
        _postSearchViewModel.hasSearched = true;
        _postSearchViewModel.isPostsFetching = true;
        setState(() {});
        bloc.add(SearchPostsEvent(text));
        break;
      case 1:
        _communitySearchViewModel.hasSearched = true;
        _communitySearchViewModel.isCommunitiesFetching = true;
        setState(() {});
        bloc.add(SearchCommunitiesEvent(text));
        break;
      case 2:
        _userSearchViewModel.hasSearched = true;
        _userSearchViewModel.isUsersFetching = true;
        setState(() {});
        bloc.add(SearchUsersEvent(text));
        break;
    }
  }

  String _hintText(BuildContext context) {
    return _tabController.index == 0
        ? context.l10n.global_search_hint
        : context.l10n.search_community_user_hint;
  }

  Widget _buildPostTab(BuildContext context) {
    return BlocBuilder<GlobalSearchBloc, GlobalSearchState>(
      buildWhen: (previous, current) => current is GlobalPostSearchLoaded,
      builder: (context, state) {
        if (state is GlobalPostSearchLoaded && _isCurrent(state.searchText)) {
          _postSearchViewModel.updatePostModel(
              posts: state.posts,
              isFetching: state.isFetching,
              loadMore: () {
                context
                    .read<GlobalSearchBloc>()
                    .add(const GlobalPostSearchLoadMoreEvent());
              });
        }
        return AmityPostSearchResultComponent(
            pageId: widget.pageId, viewModel: _postSearchViewModel);
      },
    );
  }

  Widget _buildCommunityTab(BuildContext context) {
    return BlocBuilder<GlobalSearchBloc, GlobalSearchState>(
      buildWhen: (previous, current) => current is GlobalSearchLoaded,
      builder: (context, state) {
        if (state is GlobalSearchLoaded && _isCurrent(state.searchText)) {
          _communitySearchViewModel.updateCommunityModel(
              communities: state.communities,
              isFetching: state.isFetching,
              loadMore: () {
                context
                    .read<GlobalSearchBloc>()
                    .add(const GlobalSearchLoadMoreEvent());
              });
        }
        return AmityCommunitySearchResultComponent(
            pageId: widget.pageId, viewModel: _communitySearchViewModel);
      },
    );
  }

  Widget _buildUserTab(BuildContext context) {
    return BlocBuilder<GlobalSearchBloc, GlobalSearchState>(
      buildWhen: (previous, current) => current is GlobalUserSearchLoaded,
      builder: (context, state) {
        if (state is GlobalUserSearchLoaded && _isCurrent(state.searchText)) {
          _userSearchViewModel.updateUserModel(
              users: state.users,
              isFetching: state.isFetching,
              loadMore: () {
                context
                    .read<GlobalSearchBloc>()
                    .add(const GlobalUserSearchLoadMoreEvent());
              });
        }
        return AmityUserSearchResultComponent(
            pageId: widget.pageId, viewModel: _userSearchViewModel);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ConfigProvider>(
      builder: (context, configProvider, _) {
        final theme = configProvider.getTheme(widget.pageId, '');

        return Scaffold(
          backgroundColor: theme.backgroundColor,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                AmityTopSearchBarComponent(
                  pageId: widget.pageId,
                  textcontroller: _textController,
                  hintText: _hintText(context),
                  onTextChanged: _onTextChanged,
                ),
                Container(
                  color: theme.backgroundColor,
                  child: TabBar(
                    controller: _tabController,
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
                      fontWeight: FontWeight.w400,
                      color: theme.baseColorShade1,
                      fontFamily: 'SF Pro Text',
                    ),
                    tabs: [
                      Tab(text: context.l10n.title_posts),
                      Tab(text: context.l10n.title_communities),
                      Tab(text: context.l10n.title_users),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPostTab(context),
                      _buildCommunityTab(context),
                      _buildUserTab(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
