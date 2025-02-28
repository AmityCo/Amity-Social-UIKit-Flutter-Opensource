import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/components/alert_dialog.dart';
import 'package:flutter/material.dart';

import 'configuration_viewmodel.dart';

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
          .includeDeleted(false)
          .roles([]).getPagingData(token: token, limit: 20),
      pageSize: 20,
    )..addListener(_handleMemberControllerUpdates);
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
          .includeDeleted(false)
          .roles(["community-moderator"]).getPagingData(
              token: token, limit: 20),
      pageSize: 20,
    )..addListener(_handleModeratorControllerUpdates);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _amityModeratorsController.fetchNextPage();
    });

    // Considering that you might want a separate scrollController for moderators
    // to manage their pagination independently.
    scrollController.addListener(loadNextPage);
  }

  bool isLoading = false;

  Future<void> _handleMemberControllerUpdates() async {
    if (_amityUsersController.error == null) {
      // final newMember= await AmityUIConfiguration.onCustomMember(_amityUsersController.loadedItems);
      final users = await AmityUIConfiguration.onCustomMember(
          _amityUsersController.loadedItems);
      users.removeWhere(
        (user) => user.userId == AmityUIConfiguration.globalAdminId,
      );
      _userList.clear();
      _userList.addAll(users);
      notifyListeners();
    } else {
      // Handle the error appropriately
      // Show a dialog, log the error, etc.
    }
  }

  Future<void> _handleModeratorControllerUpdates() async {
    if (_amityModeratorsController.error == null) {
      final users = await AmityUIConfiguration.onCustomMember(
          _amityModeratorsController.loadedItems);
      users.removeWhere(
        (user) => user.userId == AmityUIConfiguration.globalAdminId,
      );
      _moderatorList.clear();
      _moderatorList.addAll(users);

      notifyListeners();
    } else {
      // Handle the error appropriately
      // Show a dialog, log the error, etc.
    }
  }

  void loadNextPage() async {
    if (scrollController.position.pixels >
        scrollController.position.maxScrollExtent - 800) {}
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
    AmityLoadingDialog.runWithLoadingDialog(() async {
      await AmitySocialClient.newCommunityRepository()
          .moderation(communityId)
          .addRole('community-moderator', userIds)
          .then((value) {
        // handle result
      }).onError((error, stackTrace) async {
        AmityDialog()
            .showAlertErrorDialog(title: "Error!", message: error.toString());
      });
    });

    notifyListeners();
  }

  // Method to demote user(s) from moderator
  Future<void> demoteFromModerator(
      String communityId, List<String> userIds) async {
    AmityLoadingDialog.showLoadingDialog();
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
      // AmityDialog()
      //     .showAlertErrorDialog(title: "Error!", message: error.toString());
    });
  }

  List<AmityCommunityMember> get userList => _userList;
  List<AmityCommunityMember> get moderatorList => _moderatorList;
}
