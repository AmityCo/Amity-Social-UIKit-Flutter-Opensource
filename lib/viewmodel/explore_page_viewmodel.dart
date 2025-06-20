import 'package:amity_sdk/amity_sdk.dart';
import 'package:flutter/material.dart';

class ExplorePageVM with ChangeNotifier {
  List<AmityCommunity> _recommendedCommunities = [];
  List<AmityCommunity> _trendingCommunities = [];

  List<AmityCommunity> get recommendedCommunities => _recommendedCommunities;
  List<AmityCommunity> get trendingCommunities => _trendingCommunities;

  final amityCategories = <AmityCommunityCategory>[];
  late PagingController<AmityCommunityCategory> _communityCategoryController;
  final categoryScrollcontroller = ScrollController();

  void getRecommendedCommunities() async {
    print("getRecommendedCommunities...");
    await AmitySocialClient.newCommunityRepository()
        .getRecommendedCommunities()
        .then((List<AmityCommunity> communities) {
      _recommendedCommunities = communities.take(5).toList();
      print(_recommendedCommunities);
      notifyListeners();
    }).onError((error, stackTrace) {
      // handle error
    });
  }

  void getTrendingCommunities() {
    print("getTrendingCommunities...");
    AmitySocialClient.newCommunityRepository()
        .getTrendingCommunities()
        .then((List<AmityCommunity> communities) => {
              _trendingCommunities = communities.take(5).toList(),
              notifyListeners(),
            })
        .onError((error, stackTrace) => {
              // handle error
            });
  }

  final amityCommunities = <AmityCommunity>[];
  late PagingController<AmityCommunity> _communityController;
  final communityScrollcontroller = ScrollController();
  void getCommunitiesInCategory(
      {required String categoryId, bool enableNotifyListener = false}) {
    _communityController = PagingController(
      pageFuture: (token) => AmitySocialClient.newCommunityRepository()
          .getCommunities()
          .filter(AmityCommunityFilter.ALL)
          .sortBy(AmityCommunitySortOption.DISPLAY_NAME)
          .includeDeleted(false)
          .categoryId(
              categoryId) //optional filter communities based on community categories
          .getPagingData(token: token, limit: 20),
      pageSize: 20,
    )..addListener(
        () {
          if (_communityController.error == null) {
            //handle results, we suggest to clear the previous items
            //and add with the latest _controller.loadedItems
            amityCommunities.clear();
            amityCommunities.addAll(_communityController.loadedItems);
            //update widgets
            if (enableNotifyListener) {
              notifyListeners();
            }
          } else {
            //error on pagination controller
            //update widgets
          }
        },
      );

    _communityController.fetchNextPage();

    communityScrollcontroller.addListener(communityPagination);
  }

  void communityPagination() {
    if ((communityScrollcontroller.position.pixels >=
        (communityScrollcontroller.position.maxScrollExtent - 100))) {
      if (isLoadingFinish) {
        print("load more");
        _communityController.fetchNextPage();
        isLoadingFinish = false;
        notifyListeners();
      }
    }
  }

  void queryCommunityCategories(
      {required AmityCommunityCategorySortOption sortOption,
      bool enablenotifylistener = false}) async {
    _communityCategoryController = PagingController(
      pageFuture: (token) => AmitySocialClient.newCommunityRepository()
          .getCategories()
          .sortBy(sortOption)
          .includeDeleted(false)
          .getPagingData(token: token, limit: 20),
      pageSize: 20,
    )..addListener(
        () {
          if (_communityCategoryController.error == null) {
            //handle results, we suggest to clear the previous items
            //and add with the latest _controller.loadedItems
            amityCategories.clear();
            amityCategories.addAll(_communityCategoryController.loadedItems);
            if (enablenotifylistener) {
              notifyListeners();
            }
            isLoadingFinish = true;
            //update widgets
          } else {
            //error on pagination controller
            //update widgets
          }
        },
      );

    // fetch the data for the first page
    _communityCategoryController.fetchNextPage();

    categoryScrollcontroller.addListener(categoryPagination);
  }

  var isLoadingFinish = true;
  void categoryPagination() {
    if ((categoryScrollcontroller.position.pixels >=
        (categoryScrollcontroller.position.maxScrollExtent - 100))) {
      if (isLoadingFinish) {
        print("load more");
        _communityCategoryController.fetchNextPage();
        isLoadingFinish = false;
        notifyListeners();
      }
    }
  }
}
