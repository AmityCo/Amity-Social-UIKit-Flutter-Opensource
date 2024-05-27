import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/components/theme_config.dart';
import 'package:amity_uikit_beta_service/view/UIKit/social/post_target_page.dart';
import 'package:amity_uikit_beta_service/view/UIKit/social/search_communities.dart';
import 'package:amity_uikit_beta_service/view/social/community_feedV2.dart';
import 'package:amity_uikit_beta_service/view/social/global_feed.dart';
import 'package:amity_uikit_beta_service/viewmodel/community_feed_viewmodel.dart';
import 'package:amity_uikit_beta_service/viewmodel/configuration_viewmodel.dart';
import 'package:amity_uikit_beta_service/viewmodel/explore_page_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CommunityPage extends StatefulWidget {
  final bool showAppBarTop;
  final bool isShowMyCommunity;
  final bool showPostToButton;
  final bool canCreateCommunity;
  final bool canSearchCommunities;

  const CommunityPage({
    super.key,
    this.showAppBarTop = true,
    this.isShowMyCommunity = true,
    this.showPostToButton = true,
    this.canCreateCommunity = true,
    this.canSearchCommunities = true,
  });

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  @override
  void initState() {
    super.initState();
    var explorePageVM = Provider.of<ExplorePageVM>(context, listen: false);
    explorePageVM.getRecommendedCommunities();
    explorePageVM.getTrendingCommunities();
    explorePageVM.queryCommunityCategories(
        sortOption: AmityCommunityCategorySortOption.FIRST_CREATED);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: ThemeConfig(
        child: Scaffold(
          backgroundColor:
              Provider.of<AmityUIConfiguration>(context).appColors.baseShade4,
          appBar: AppBar(
            toolbarHeight: widget.showAppBarTop ? kToolbarHeight : 0,
            // Add this line to remove the shadow
            elevation: 0.05,
            backgroundColor: Provider.of<AmityUIConfiguration>(context)
                .appColors
                .baseBackground,
            leading: widget.showAppBarTop
                ? IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Provider.of<AmityUIConfiguration>(context)
                          .appColors
                          .base,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                : null,
            // centerTitle: false,
            automaticallyImplyLeading: false,
            title: widget.showAppBarTop
                ? Text(
                    "Community",
                    style: Provider.of<AmityUIConfiguration>(context)
                        .titleTextStyle
                        .copyWith(
                          color: Provider.of<AmityUIConfiguration>(context)
                              .appColors
                              .base,
                        ),
                  )
                : null,
            actions: widget.showAppBarTop
                ? [
                    IconButton(
                      icon: Icon(
                        Icons.search,
                        color: Provider.of<AmityUIConfiguration>(context)
                            .appColors
                            .base,
                      ),
                      onPressed: () {
                        // Implement search functionality
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                const SearchCommunitiesScreen(),
                          ),
                        );
                      },
                    )
                  ]
                : null,
            bottom: PreferredSize(
              // Provide a height for the AppBar's bottom
              preferredSize: const Size.fromHeight(48.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      TabBar(
                        tabAlignment: TabAlignment.start,
                        // Ensure that the TabBar is scrollable
                        isScrollable: true,
                        dividerColor: Provider.of<AmityUIConfiguration>(context)
                            .appColors
                            .baseBackground,
                        labelColor: Provider.of<AmityUIConfiguration>(context)
                            .appColors
                            .primary,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor:
                            Provider.of<AmityUIConfiguration>(context)
                                .appColors
                                .primary,
                        labelStyle: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'SF Pro Text',
                        ),
                        tabs: const [
                          Tab(text: "Newsfeed"),
                          Tab(text: "Explore"),
                        ],
                      ),
                    ],
                  ),
                  // Divider(
                  //   color: Colors.grey,
                  //   height: 0,
                  // )
                ],
              ),
            ),
          ),
          body: TabBarView(
            children: [
              Scaffold(
                floatingActionButton: widget.showPostToButton
                    ? FloatingActionButton(
                        shape: const CircleBorder(),
                        onPressed: () {
                          // Navigate or perform action based on 'Newsfeed' tap
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const ThemeConfig(
                                child: Scaffold(
                                  body: PostToPage(),
                                ),
                              ),
                            ),
                          );
                        },
                        backgroundColor:
                            Provider.of<AmityUIConfiguration>(context)
                                .appColors
                                .primary,
                        child: Provider.of<AmityUIConfiguration>(context)
                            .iconConfig
                            .postIcon(iconSize: 28, color: Colors.white),
                      )
                    : null,
                body: GlobalFeedScreen(
                  isShowMyCommunity: widget.isShowMyCommunity,
                  canCreateCommunity: widget.canCreateCommunity,
                  canSearchCommunities: widget.canSearchCommunities,
                ),
              ),
              const ExplorePage(),
            ],
          ),
        ),
      ),
    );
  }
}

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        RecommendationSection(),
        TrendingSection(),
        CategorySection(),
      ],
    );
  }
}

class RecommendationSection extends StatelessWidget {
  const RecommendationSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ExplorePageVM>(
      builder: (context, vm, _) {
        return Container(
          padding: const EdgeInsets.only(bottom: 24),
          color:
              Provider.of<AmityUIConfiguration>(context).appColors.baseShade4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 20),
                child: Text(
                  'Recommended for you',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Provider.of<AmityUIConfiguration>(context)
                          .appColors
                          .base),
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              SizedBox(
                height: 194,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: vm.recommendedCommunities.length,
                  itemBuilder: (context, index) {
                    final community = vm.recommendedCommunities[index];
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  CommunityScreen(community: community)));
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(4), // No border radius
                          ),
                          color: Provider.of<AmityUIConfiguration>(context)
                              .appColors
                              .baseBackground,
                          child: Container(
                            width: 131,
                            height: 194,
                            margin: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                community.avatarImage == null
                                    ? CircleAvatar(
                                        backgroundColor:
                                            Provider.of<AmityUIConfiguration>(
                                                    context)
                                                .appColors
                                                .primaryShade3,
                                        child: const Icon(Icons.people,
                                            color: Colors.white))
                                    : CircleAvatar(
                                        backgroundColor:
                                            Provider.of<AmityUIConfiguration>(
                                                    context)
                                                .appColors
                                                .primaryShade3,
                                        backgroundImage: NetworkImage(
                                            community.avatarImage!.fileUrl!),
                                        radius:
                                            20, // Adjusted the radius to get 40x40 size
                                      ),
                                const SizedBox(height: 8.0),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        "${community.displayName}  ",
                                        style: TextStyle(
                                          color:
                                              Provider.of<AmityUIConfiguration>(
                                                      context)
                                                  .appColors
                                                  .base,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                        overflow: TextOverflow
                                            .ellipsis, // Handle text overflow
                                      ),
                                    ),
                                    community.isOfficial!
                                        ? Provider.of<AmityUIConfiguration>(
                                                context)
                                            .iconConfig
                                            .officialIcon(
                                              iconSize: 17,
                                              color: Provider.of<
                                                          AmityUIConfiguration>(
                                                      context)
                                                  .primaryColor,
                                            )
                                        : const SizedBox(),
                                  ],
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                community.categories!.isEmpty
                                    ? const Text(
                                        '',
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 13),
                                        overflow: TextOverflow
                                            .ellipsis, // Handle text overflow
                                      )
                                    : Text(
                                        '${community.categories?[0]?.name}',
                                        style: TextStyle(
                                            color: Provider.of<
                                                        AmityUIConfiguration>(
                                                    context)
                                                .appColors
                                                .base,
                                            fontSize: 13),
                                        overflow: TextOverflow
                                            .ellipsis, // Handle text overflow
                                      ),
                                const SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  '${community.membersCount} ${community.membersCount == 1 ? 'Member' : 'Members'}',

                                  style:
                                      const TextStyle(color: Color(0xff636878)),
                                  overflow: TextOverflow
                                      .ellipsis, // Handle text overflow
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                Expanded(
                                  child: Text(
                                    community.description ?? '',
                                    softWrap: true,
                                    style: TextStyle(
                                        fontSize: 13,
                                        color:
                                            Provider.of<AmityUIConfiguration>(
                                                    context)
                                                .appColors
                                                .base),

                                    overflow: TextOverflow
                                        .ellipsis, // Handle text overflow
                                    maxLines: 3, // Display up to two lines
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class TrendingSection extends StatelessWidget {
  const TrendingSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ExplorePageVM>(
      builder: (context, vm, _) {
        return Container(
          color: Provider.of<AmityUIConfiguration>(context)
              .appColors
              .baseBackground,
          padding: const EdgeInsets.only(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 20),
                child: Text(
                  'Today\'s Trending',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Provider.of<AmityUIConfiguration>(context)
                          .appColors
                          .base),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: vm.trendingCommunities.length,
                itemExtent: 60.0, // <-- Set this to your desired height
                itemBuilder: (context, index) {
                  final community = vm.trendingCommunities[index];
                  return ListTile(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ChangeNotifierProvider(
                                create: (context) => CommuFeedVM(),
                                child: CommunityScreen(
                                  isFromFeed: true,
                                  community: community,
                                ),
                              )));
                    },
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: Provider.of<AmityUIConfiguration>(context)
                                .appColors
                                .primaryShade3,
                            shape: BoxShape.circle,
                          ),
                          child: community.avatarImage != null
                              ? CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      community.avatarImage?.fileUrl ?? ''),
                                )
                              : const Icon(Icons.people, color: Colors.white),
                        ),
                        const SizedBox(width: 15),
                        Text("${index + 1}",
                            style: TextStyle(
                                fontSize: 20,
                                color:
                                    Provider.of<AmityUIConfiguration>(context)
                                        .appColors
                                        .primary,
                                fontWeight: FontWeight.bold)), // Ranking number
                        // Spacing between rank and avatar
                      ],
                    ),
                    title: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            "${community.displayName}  ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Provider.of<AmityUIConfiguration>(context)
                                  .appColors
                                  .base,
                              fontSize: 15,
                            ),
                            overflow:
                                TextOverflow.ellipsis, // Handle text overflow
                          ),
                        ),
                        community.isOfficial!
                            ? Provider.of<AmityUIConfiguration>(context)
                                .iconConfig
                                .officialIcon(
                                  iconSize: 17,
                                  color:
                                      Provider.of<AmityUIConfiguration>(context)
                                          .primaryColor,
                                )
                            : const SizedBox(),
                      ],
                    ),
                    subtitle: community.categories!.isEmpty
                        ? Text(
                            'no category • ${community.membersCount} ${community.membersCount == 1 ? "member" : "members"}',
                            style: const TextStyle(
                                fontSize: 13, color: Color(0xff636878)),
                          )
                        : Text(
                            '${community.categories?[0]?.name ?? ""} • ${community.membersCount} ${community.membersCount == 1 ? "member" : "members"}',
                            style: const TextStyle(
                                fontSize: 13, color: Color(0xff636878)),
                          ),
                  );
                },
              )
            ],
          ),
        );
      },
    );
  }
}

class CategorySection extends StatelessWidget {
  const CategorySection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ExplorePageVM>(
      builder: (context, vm, _) {
        return Container(
          padding: const EdgeInsets.only(left: 16, top: 20, bottom: 25),
          color: Provider.of<AmityUIConfiguration>(context)
              .appColors
              .baseBackground,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 12,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Categories',
                    style: Provider.of<AmityUIConfiguration>(context)
                        .titleTextStyle
                        .copyWith(
                            color: Provider.of<AmityUIConfiguration>(context)
                                .appColors
                                .base),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CategoryListPage()),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(right: 14.0),
                      child: Icon(
                        Icons.chevron_right,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 13,
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 5,
                  mainAxisSpacing: 16, // Add spacing between rows
                ),
                itemCount: vm.amityCategories.length > 8
                    ? 8
                    : vm.amityCategories
                        .length, // Limit to maximum 8 items (2x4 grid)
                itemBuilder: (context, index) {
                  final category = vm.amityCategories[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CommunityListPage(
                                  category: category,
                                )),
                      );
                    },
                    child: SizedBox(
                      child: Row(
                        children: [
                          Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                                color:
                                    Provider.of<AmityUIConfiguration>(context)
                                        .appColors
                                        .primaryShade3,
                                shape: BoxShape.circle),
                            child: const Icon(
                              Icons.category,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              category.name ?? '',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color:
                                      Provider.of<AmityUIConfiguration>(context)
                                          .appColors
                                          .base,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class CategoryListPage extends StatefulWidget {
  const CategoryListPage({super.key});

  @override
  State<CategoryListPage> createState() => _CategoryListPageState();
}

class _CategoryListPageState extends State<CategoryListPage> {
  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      var explorePageVM = Provider.of<ExplorePageVM>(context, listen: false);

      explorePageVM.queryCommunityCategories(
          sortOption: AmityCommunityCategorySortOption.NAME,
          enablenotifylistener: true);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeConfig(
      child: Scaffold(
        backgroundColor:
            Provider.of<AmityUIConfiguration>(context).appColors.baseBackground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0, // Remove shadow
          title: Text(
            "Category",
            style: Provider.of<AmityUIConfiguration>(context).titleTextStyle,
          ),
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: Consumer<ExplorePageVM>(
          builder: (context, vm, _) {
            return ListView.builder(
              itemCount: vm.amityCategories.length,
              itemBuilder: (context, index) {
                final category = vm.amityCategories[index];
                return ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CommunityListPage(
                                category: category,
                              )),
                    );
                  },
                  leading: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Provider.of<AmityUIConfiguration>(context)
                          .appColors
                          .primaryShade3,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.category,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(category.name ?? ''),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class CommunityListPage extends StatefulWidget {
  final AmityCommunityCategory category;

  const CommunityListPage({required this.category, Key? key}) : super(key: key);

  @override
  _CommunityListPageState createState() => _CommunityListPageState();
}

class _CommunityListPageState extends State<CommunityListPage> {
  late final ExplorePageVM _viewModel;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _viewModel = Provider.of<ExplorePageVM>(context, listen: false);
      _viewModel.getCommunitiesInCategory(
          categoryId: widget.category.categoryId!, enableNotifyListener: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ThemeConfig(
      child: Scaffold(
        backgroundColor:
            Provider.of<AmityUIConfiguration>(context).appColors.baseBackground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0, // Remove shadow

          title: Text(
            widget.category.name ?? "Community",
            style: Provider.of<AmityUIConfiguration>(context).titleTextStyle,
          ),
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: Consumer<ExplorePageVM>(
          builder: (context, vm, _) {
            return ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: vm.amityCommunities.length,
              controller: vm.communityScrollcontroller,
              itemBuilder: (context, index) {
                final community = vm.amityCommunities[index];
                return ListTile(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            CommunityScreen(community: community)));
                  },
                  leading: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Provider.of<AmityUIConfiguration>(context)
                          .appColors
                          .primaryShade3,
                      shape: BoxShape.circle,
                    ),
                    child: community.avatarImage != null
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(
                                community.avatarImage?.fileUrl ?? ''),
                          )
                        : const Icon(
                            Icons.people,
                            color: Colors.white,
                          ),
                  ),
                  title: Text(community.displayName ?? ''),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
