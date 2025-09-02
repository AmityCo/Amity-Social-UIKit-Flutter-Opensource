import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/amity_uikit.dart';
import 'package:flutter/material.dart';

class MyCommunityVM with ChangeNotifier {
  // Existing members...

  final scrollcontroller = ScrollController();
  bool loadingNextPage = false;
  // The list of communities.
  final List<AmityCommunity> _amityCommunities = [];
  final List<AmityCommunity> _amityCommunitiesForFeed = [];
  // The controller for handling pagination.
  // late PagingController<AmityCommunity> _communityController;
  late CommunityLiveCollection communityLiveCollection;
  late CommunityLiveCollection communityFeedLiveCollection;
  // Getter for _amityCommunities for external classes to use.
  List<AmityCommunity> get amityCommunities => _amityCommunities;
  List<AmityCommunity> get amityCommunitiesForFeed => _amityCommunitiesForFeed;
  final textEditingController = TextEditingController();

  final getStoryTargets = AmityUIKit4Manager
      .freedomBehavior.createPostMenuComponentBehavior.getStoryTargets;
  final storyTargetsPageSize = AmityUIKit4Manager
      .freedomBehavior.createPostMenuComponentBehavior.storyTargetsPageSize;

  Future<void> initMyCommunity([String? keyword]) async {
    final repository = AmitySocialClient.newCommunityRepository()
        .getCommunities()
        .filter(AmityCommunityFilter.MEMBER)
        .includeDeleted(false);
    if (keyword != null && keyword.isNotEmpty) {
      repository.withKeyword(
          keyword); // Add keyword filtering only if keyword is provided and not empty
    }
    communityLiveCollection = repository.getLiveCollection(
      pageSize: storyTargetsPageSize,
    );
    communityLiveCollection.getStreamController().stream.listen((event) async {
      if (communityLiveCollection.isFetching) {
        return;
      }

      final List<AmityCommunity> storyTargets = await getStoryTargets(
        communities: event,
      );
      _amityCommunities.clear();
      _amityCommunities.addAll(storyTargets);

      notifyListeners();
    }).onError((error, stackTrace) {
      // await AmityDialog().showAlertErrorDialog(
      //     title: "Error!",
      //     message: _communityController.error.toString());
    });
    communityLiveCollection.loadNext();
    scrollcontroller.removeListener(() {});
    scrollcontroller.addListener(loadNextPage);
  }

  Future<void> initMyCommunityFeed() async {
    final repository = AmitySocialClient.newCommunityRepository()
        .getCommunities()
        .filter(AmityCommunityFilter.MEMBER)
        .sortBy(AmityCommunitySortOption.DISPLAY_NAME)
        .includeDeleted(false);

    communityFeedLiveCollection = repository.getLiveCollection(pageSize: 50);
    communityFeedLiveCollection.getStreamController().stream.listen((event) {
      _amityCommunitiesForFeed.clear();
      _amityCommunitiesForFeed.addAll(event);

      notifyListeners();
    }).onError((error, stackTrace) {
      // log("error:${error.error.toString()}");
      // await AmityDialog().showAlertErrorDialog(
      //     title: "Error!",
      //     message: _communityController.error.toString());
    });
  }

  void loadNextPage() async {
    if ((scrollcontroller.position.pixels >
        scrollcontroller.position.maxScrollExtent - 800)) {}
    if ((scrollcontroller.position.pixels >
            scrollcontroller.position.maxScrollExtent - 800) &&
        communityLiveCollection.hasNextPage() &&
        !loadingNextPage) {
      loadingNextPage = true;
      notifyListeners();

      await communityLiveCollection.loadNext().then((value) {
        loadingNextPage = false;
        notifyListeners();
      });
    }
  }
}

class SearchCommunityVM with ChangeNotifier {
  // Existing members...

  final scrollcontroller = ScrollController();
  bool loadingNextPage = false;
  // The list of communities.
  final List<AmityCommunity> _amityCommunities = [];
  // Getter for _amityCommunities for external classes to use.
  List<AmityCommunity> get amityCommunities => _amityCommunities;
  final textEditingController = TextEditingController();
  // The controller for handling pagination.
  late PagingController<AmityCommunity> communityController;
  void clearSearch() {
    amityCommunities.clear();
  }

  Future<void> initSearchCommunity([String? keyword]) async {
    communityController = PagingController(
      pageFuture: (token) {
        final repository = AmitySocialClient.newCommunityRepository()
            .getCommunities()
            .sortBy(AmityCommunitySortOption.DISPLAY_NAME)
            .filter(AmityCommunityFilter.ALL)
            .includeDeleted(false);
        if (keyword != null && keyword.isNotEmpty) {
          repository.withKeyword(
              keyword); // Add keyword filtering only if keyword is provided and not empty
        }
        return repository.getPagingData(token: token, limit: 20);
      },
      pageSize: 20,
    )..addListener(
        () async {
          if (communityController.error == null) {
            amityCommunities.clear();
            amityCommunities.addAll(communityController.loadedItems);
            // Call any additional methods like sortedUserListWithHeaders here if needed.
            notifyListeners();
          } else {
            // await AmityDialog().showAlertErrorDialog(
            //     title: "Error!", message: communityController.error.toString());
          }
        },
      );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      communityController.fetchNextPage();
    });

    scrollcontroller.removeListener(() {});
    scrollcontroller.addListener(loadNextPage);
  }

  void loadNextPage() async {
    if ((scrollcontroller.position.pixels >
        scrollcontroller.position.maxScrollExtent - 800)) {}
    if ((scrollcontroller.position.pixels >
            scrollcontroller.position.maxScrollExtent - 800) &&
        communityController.hasMoreItems &&
        !loadingNextPage) {
      loadingNextPage = true;
      notifyListeners();
      // Call any additional methods like sortedUserListWithHeaders here if needed.
      await communityController.fetchNextPage().then((value) {
        loadingNextPage = false;
        notifyListeners();
      });
    }
  }
}
