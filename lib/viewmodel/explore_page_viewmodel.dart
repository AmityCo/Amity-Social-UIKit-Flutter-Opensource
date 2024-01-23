import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/components/alert_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ExplorePageVM with ChangeNotifier {
  List<AmityCommunity> _recommendedCommunities = [];
  List<AmityCommunity> _trendingCommunities = [];
  List<AmityCommunityCategory> _categories = [];

  List<AmityCommunity> get recommendedCommunities => _recommendedCommunities;
  List<AmityCommunity> get trendingCommunities => _trendingCommunities;
  List<AmityCommunityCategory> get amityCategories => _categories;

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

  List<AmityCommunity> communities = [];

  void getCommunitiesInCategory(String categoryId) {
    communities.clear();
    AmitySocialClient.newCommunityRepository()
        .getCommunities()
        .categoryId(categoryId)
        .getPagingData(token: null)
        .then((value) {
      communities = value.data;
      notifyListeners();
    }).onError((error, stackTrace) async {
      await AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
    });
  }

  final List<String> _categoryIds = [];
  void queryCommunityCategories(
      AmityCommunityCategorySortOption sortOption) async {
    AmitySocialClient.newCommunityRepository()
        .getCategories()
        .sortBy(sortOption)
        .includeDeleted(false)
        .getPagingData(token: null, limit: 20)
        .then((communityCategories) {
      _categories = communityCategories.data;
      for (var category in _categories) {
        _categoryIds.add(category.categoryId!);
      }

      notifyListeners();
    }).onError((error, stackTrace) async {
      await AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
    });
  }
}
