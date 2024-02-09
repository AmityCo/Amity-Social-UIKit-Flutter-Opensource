import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/components/alert_dialog.dart';
import 'package:flutter/material.dart';

class MemberManagementVM extends ChangeNotifier {
  final ScrollController scrollController = ScrollController();
  bool loadingNextPage = false;
  final ScrollController scrollControllerForModerator = ScrollController();
  bool loadingNextPageForModerator = false;
  late PagingController<AmityCommunityMember> _amityUsersController;
  late PagingController<AmityCommunityMember> _amityModeratorsController;
  final List<AmityCommunityMember> _userList = [];
  final List<AmityCommunityMember> _moderatorList = [];

  late String communityId;

  Future<void> initMember({
    required String communityId,
  }) async {
    this.communityId = communityId;
    _amityUsersController = PagingController(
      pageFuture: (token) => AmitySocialClient.newCommunityRepository()
          .membership(communityId)
          .getMembers()
          .filter(AmityCommunityMembershipFilter.MEMBER)
          .roles([]).getPagingData(token: token, limit: 20),
      pageSize: 20,
    )..addListener(_handleMemberControllerUpdates);
    print("initMember");
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _amityUsersController.fetchNextPage();
    });

    scrollController.addListener(loadNextPage);
  }

  Future<void> initModerators({
    required String communityId,
  }) async {
    this.communityId = communityId;
    _amityModeratorsController = PagingController(
      pageFuture: (token) => AmitySocialClient.newCommunityRepository()
          .membership(communityId)
          .getMembers()
          .filter(AmityCommunityMembershipFilter.MEMBER)
          .roles(["community-moderator"]).getPagingData(
              token: token, limit: 20),
      pageSize: 20,
    )..addListener(_handleModeratorControllerUpdates);
    print("initModerators");
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _amityModeratorsController.fetchNextPage();
    });

    // Considering that you might want a separate scrollController for moderators
    // to manage their pagination independently.
    scrollController.addListener(loadNextPage);
  }

  void _handleMemberControllerUpdates() {
    if (_amityUsersController.error == null) {
      _userList.clear();
      _userList.addAll(_amityUsersController.loadedItems);
      notifyListeners();
    } else {
      // Handle the error appropriately
      // Show a dialog, log the error, etc.
    }
  }

  void _handleModeratorControllerUpdates() {
    if (_amityModeratorsController.error == null) {
      _moderatorList.clear();
      _moderatorList.addAll(_amityModeratorsController.loadedItems);

      notifyListeners();
    } else {
      // Handle the error appropriately
      // Show a dialog, log the error, etc.
    }
  }

  void loadNextPage() async {
    if (scrollController.position.pixels >
        scrollController.position.maxScrollExtent - 800) {
      print("hasMore: ${_amityUsersController.hasMoreItems}");
    }
    if ((scrollController.position.pixels >
            scrollController.position.maxScrollExtent - 800) &&
        _amityUsersController.hasMoreItems &&
        !loadingNextPage) {
      loadingNextPage = true;
      notifyListeners();
      await _amityUsersController.fetchNextPage().then((value) {
        loadingNextPage = false;
        notifyListeners();
      });
    }
  }

  // Method to promote user(s) to moderator
  Future<void> promoteToModerator(
      String communityId, List<String> userIds) async {
    print("promoteToModerator");
    AmityLoadingDialog.runWithLoadingDialog(() async {
      await AmitySocialClient.newCommunityRepository()
          .moderation(communityId)
          .addRole('community-moderator', userIds)
          .then((value) {
        // handle result
        print("promoteToModerator: success");
      }).onError((error, stackTrace) async {
        print("promoteToModerator: fail");
        AmityDialog()
            .showAlertErrorDialog(title: "Error!", message: error.toString());
      });
      print("finish loading...");
    });

    notifyListeners();
  }

  // Method to demote user(s) from moderator
  Future<void> demoteFromModerator(
      String communityId, List<String> userIds) async {
    AmityLoadingDialog.showLoadingDialog();
    print("demoteFromModerator");
    await AmitySocialClient.newCommunityRepository()
        .moderation(communityId)
        .removeRole('community-moderator', userIds)
        .then((value) {
      AmityLoadingDialog.hideLoadingDialog();
    }).onError((error, stackTrace) async {
      AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
    });

    notifyListeners();
  }

  // Method to remove member(s) from the community
  Future<void> removeMembers(
      String communityId, List<String> removingMemberIds) async {
    AmityLoadingDialog.showLoadingDialog();
    AmitySocialClient.newCommunityRepository()
        .membership(communityId)
        .removeMembers(removingMemberIds)
        .then((value) {
      _amityUsersController
          .removeWhere((element) => removingMemberIds.contains(element.userId));
      AmityLoadingDialog.hideLoadingDialog();
    }).onError((error, stackTrace) async {
      AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
    });
    notifyListeners();
  }

  // Method to report a user
  Future<void> reportUser(AmityUser user) async {
    await user.report().flag().then((value) {
      print(value);
      AmitySuccessDialog.showTimedDialog("Report sent");
    }).onError((error, stackTrace) {
      AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
    });
    notifyListeners();
  }

  // Method to report a user
  Future<void> undoReportUser(AmityUser user) async {
    await user.report().unflag().then((value) {
      print(value);
      AmitySuccessDialog.showTimedDialog("Unreport sent");
    }).onError((error, stackTrace) {
      AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
    });
    notifyListeners();
  }

  // Method to block a user
  Future<void> blockUser(AmityUser user) async {
    await user.blockUser().then((value) {
      print(value);
      AmitySuccessDialog.showTimedDialog("Block user");
    }).onError((error, stackTrace) {
      AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
    });
    notifyListeners();
  }

  // Method to block a user
  Future<void> unBlockUser(AmityUser user) async {
    await user.unblockUser().then((value) {
      print(value);
      AmitySuccessDialog.showTimedDialog("Unblock user");
    }).onError((error, stackTrace) {
      AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
    });
    notifyListeners();
  }

  List<String> currentUserRoles = [];

  Future<void> checkCurrentUserRole(String communityId) async {
    await AmitySocialClient.newCommunityRepository()
        .getCommunity(communityId)
        .then((community) async {
      // I'm assuming that `getCurentUserRoles()` returns a List<String>
      // representing the roles of the current user in the community.
      // If it doesn’t, you might need to adjust this.
      currentUserRoles = await community.getCurentUserRoles();

      notifyListeners();
    }).onError((error, stackTrace) {
      print("$error,$stackTrace");
      // AmityDialog()
      //     .showAlertErrorDialog(title: "Error!", message: error.toString());
    });
  }

  List<AmityCommunityMember> get userList => _userList;
  List<AmityCommunityMember> get moderatorList => _moderatorList;
}
