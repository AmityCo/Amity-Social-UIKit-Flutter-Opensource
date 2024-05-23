import 'package:amity_sdk/amity_sdk.dart';
import 'package:flutter/material.dart';

class CategoryVM extends ChangeNotifier {
  final _selectedCategories = <String>[];
  final _amityCategories = <AmityCommunityCategory>[];
  late PagingController<AmityCommunityCategory> _communityCategoryController;
  final _categoryIds = <String>[];
  AmityCommunity? _community;
  List<AmityCommunityCategory> getCategories() {
    return _amityCategories;
  }

  AmityCommunity? getCommunity() {
    return _community;
  }

  void setCommunity(AmityCommunity community) {
    _community = community;
  }

  void clear() {
    _amityCategories.clear();
    _selectedCategories.clear();
    _community = null;
  }

  List<String> getCategoryIds() {
    return _categoryIds;
  }

  void addCategoryId(String id) {
    _categoryIds.add(id);
    notifyListeners();
  }

  List<String> getSelectedCategory() {
    return _selectedCategories;
  }

  String getSelectedCommunityName(String id) {
    for (var category in _amityCategories) {
      if (category.categoryId! == id) {
        return category.name!;
      }
    }
    return "";
  }

  void setSelectedCategory(String id) {
    _selectedCategories.clear();
    _selectedCategories.add(id);

    notifyListeners();
  }

  final scrollcontroller = ScrollController();

  void initCategoryList({List<String>? ids}) async {
    print("initCategoryList");
    _communityCategoryController = PagingController(
      pageFuture: (token) => AmitySocialClient.newCommunityRepository()
          .getCategories()
          .sortBy(AmityCommunityCategorySortOption.NAME)
          .includeDeleted(false)
          .getPagingData(token: token, limit: 20),
      pageSize: 20,
    )..addListener(
        () {
          if (_communityCategoryController.error == null) {
            //handle results, we suggest to clear the previous items
            //and add with the latest _controller.loadedItems
            _amityCategories.clear();
            _amityCategories.addAll(_communityCategoryController.loadedItems);
            //update widgets
            print(
                "has more item: ${_communityCategoryController.hasMoreItems}");
            notifyListeners();
          } else {
            //error on pagination controller
            //update widgets
          }
        },
      );

    // fetch the data for the first page
    _communityCategoryController.fetchNextPage();

    scrollcontroller.addListener(pagination);
  }

  bool checkIfSelected(String id) {
    return _selectedCategories.contains(id);
  }

  void pagination() {
    // print("pag");
    // print(scrollcontroller.position.pixels);
    // print(scrollcontroller.position.maxScrollExtent);
    // print(_communityCategoryController.hasMoreItems);
    if ((scrollcontroller.position.pixels >=
        (scrollcontroller.position.maxScrollExtent - 100))) {
      print("load more");
      _communityCategoryController.fetchNextPage();
      notifyListeners();
    }
  }

  void selectCategory() async {}
}
