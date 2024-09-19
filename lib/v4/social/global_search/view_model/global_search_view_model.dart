import 'package:amity_sdk/amity_sdk.dart';
import 'package:flutter/material.dart';

class AmityGlobalSearchViewModel {
  AmityGlobalSearchType searchType;
  ScrollController scrollController;

  List<AmityCommunity> communities = [];
  bool isCommunitiesFetching = false;

  List<AmityUser> users = [];
  bool isUsersFetching = false;

  void Function()? onLoadMore;

  AmityGlobalSearchViewModel({
    required this.searchType,
    required this.scrollController,
  });

  void updateCommunityModel(
      {required List<AmityCommunity> communities,
      required bool isFetching,
      required void Function() loadMore}) {
    this.communities = communities;
    isCommunitiesFetching = isFetching;
    onLoadMore = loadMore;
  }

  void updateUserModel(
      {required List<AmityUser> users,
      required bool isFetching,
      required void Function() loadMore}) {
    this.users = users;
    isUsersFetching = isFetching;
    onLoadMore = loadMore;
  }
}

enum AmityGlobalSearchType {
  community,
  myCommunity,
  user,
}
