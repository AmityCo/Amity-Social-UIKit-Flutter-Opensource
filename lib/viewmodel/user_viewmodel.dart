import 'dart:developer';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../components/alert_dialog.dart';
import '../utils/env_manager.dart';

class UserVM extends ChangeNotifier {
  ///testtt
  final List<AmityUser> _userList = [];
  List<String> selectedUserList = [];
  String? accessToken;
  List<AmityUser> getUserList() {
    return _userList;
  }

  void clearSelectedUser() {
    selectedUserList.clear();
    notifyListeners();
  }

  Future<void> initAccessToken({String? apikey}) async {
    var dio = Dio();
    await dio
        .post(
      "https://api.${env!.region}.amity.co/api/v3/sessions",
      data: {
        'userId': AmityCoreClient.getUserId(),
        'deviceId': AmityCoreClient.getUserId()
      },
      options: Options(
        headers: {
          "x-api-key": env?.apikey // set content-length
        },
      ),
    )
        .then((value) {
      log("success");
      if (value.statusCode == 200) {
        accessToken = value.data["accessToken"];
      }
    }).onError((error, stackTrace) async {
      await AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
    });
  }

  Future<AmityUser?> getUserByID(String id) async {
    AmityUser? amityUser;
    await AmityCoreClient.newUserRepository().getUser(id).then((user) {
      log("IsGlobalban: ${user.isGlobalBan}");
      amityUser = user;
    }).onError((error, stackTrace) async {
      log(error.toString());
      await AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
    });
    return amityUser;
  }

  void setSelectedUserList(String id) {
    if (selectedUserList.isNotEmpty && selectedUserList.contains(id)) {
      selectedUserList.remove(id);
    } else {
      selectedUserList.add(id);
    }
  }

  bool checkIfSelected(String id) {
    return selectedUserList.contains(id);
  }

  Future<void> getUsers() async {
    log("get user");
    AmityCoreClient.newUserRepository()
        .getUsers()
        .sortBy(AmityUserSortOption.DISPLAY)
        .query()
        .then((users) async {
      _userList.clear();
      _userList.addAll(users);
      notifyListeners();
    }).catchError((error, stackTrace) async {
      log(error.toString());
      await AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
      notifyListeners();
    });
  }

  final scrollcontroller = ScrollController();
  bool loadingNexPage = false;

  void clearUserList() {
    _userList.clear();
  }

  Future<void> initUserList(String keyworkd) async {
    _amityUsersController = PagingController(
      pageFuture: (token) => AmityCoreClient.newUserRepository()
          .searchUserByDisplayName(keyworkd)
          .sortBy(AmityUserSortOption.DISPLAY)
          .getPagingData(token: token, limit: 20),
      pageSize: 20,
    )..addListener(
        () async {
          if (_amityUsersController.error == null) {
            _userList.clear();
            _userList.addAll(_amityUsersController.loadedItems);
            sortedUserListWithHeaders();
            notifyListeners();
          } else {
            log("error");
            await AmityDialog().showAlertErrorDialog(
                title: "Error!",
                message: _amityUsersController.error.toString());
          }
        },
      );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _amityUsersController.fetchNextPage();
    });

    scrollcontroller.removeListener(() {});
    scrollcontroller.addListener(loadnextpage);
  }

  void loadnextpage() async {
    if ((scrollcontroller.position.pixels >
        scrollcontroller.position.maxScrollExtent - 800)) {
      log("hasmore: ${_amityUsersController.hasMoreItems}");
    }
    if ((scrollcontroller.position.pixels >
            scrollcontroller.position.maxScrollExtent - 800) &&
        _amityUsersController.hasMoreItems &&
        !loadingNexPage) {
      loadingNexPage = true;
      notifyListeners();
      log("loading Next Page...");
      sortedUserListWithHeaders();
      await _amityUsersController.fetchNextPage().then((value) {
        loadingNexPage = false;
        notifyListeners();
      });
    }
  }

  final List<AmityUser> _amityUsers = [];
  List<AmityUser> selectedUsers = [];
  late PagingController<AmityUser> _amityUsersController;

  List<AmityUser> get amityUsers => _amityUsers;

  void getUsersForCommunity(AmityUserSortOption amityUserSortOption) {
    log("getUsersForCommunity");
    _amityUsersController = PagingController(
      pageFuture: (token) => AmityCoreClient.newUserRepository()
          .getUsers()
          .sortBy(amityUserSortOption)
          .getPagingData(token: token, limit: 20),
      pageSize: 20,
    )..addListener(
        () {
          if (_amityUsersController.error == null) {
            _amityUsers.clear();
            _amityUsers.addAll(_amityUsersController.loadedItems);
            notifyListeners();
          } else {
            // handle error
            log(_amityUsersController.error.toString());
          }
        },
      );
  }

  void selectUser(AmityUser user) {
    selectedUsers.add(user);
    notifyListeners();
  }

  List<Map<String, List<AmityUser>>> listWithHeaders = [];

  void sortedUserListWithHeaders() {
    log("sorted");
    List<AmityUser> users = _userList;

    // Step 1: Sort the users list by display name (case insensitive)
    users.sort((a, b) {
      String? nameA =
          a.displayName?.isNotEmpty == true ? a.displayName : a.userId;
      String? nameB =
          b.displayName?.isNotEmpty == true ? b.displayName : b.userId;
      return nameA!.toLowerCase().compareTo(nameB!.toLowerCase());
    });

    List<Map<String, List<AmityUser>>> currentListWithHeaders = [];
    String? currentHeader;
    List<AmityUser> currentUserList = [];

    for (var user in users) {
      String? initial;

      // Step 2: Get the initial letter of the display name (default to '#' if not a letter)
      if (user.displayName != null && user.displayName!.isNotEmpty) {
        initial = user.displayName![0].toUpperCase();
      }

      if (initial != null && !RegExp(r'[A-Z]').hasMatch(initial)) {
        initial = '#';
      }

      // Step 3: Add the header to the list if it's a new header
      if (initial != currentHeader) {
        if (currentHeader != null) {
          currentListWithHeaders.add({currentHeader: currentUserList});
        }
        currentHeader = initial;
        currentUserList = [];
      }

      // Step 4: Add the user to the list
      currentUserList.add(user);
    }

    // Add the last group of users to the list
    if (currentHeader != null) {
      currentListWithHeaders.add({currentHeader: currentUserList});
    }

    listWithHeaders = currentListWithHeaders;

    // Print for debugging
    // for (var item in listWithHeaders) {
    //   log(item.keys.first);
    //   for (var user in item.values.first) {
    //     log(user.displayName);
    //   }
    // }
  }

  void searchWithKeyword(String keyword) {
    initUserList(keyword);
  }

  final List<AmityUser> _selectedCommunityUsers = [];
  List<AmityUser> get selectedCommunityUsers => _selectedCommunityUsers;

  void clearselectedCommunityUsers() {
    _selectedCommunityUsers.clear();
  }

  void toggleUserSelection(AmityUser user) {
    if (_selectedCommunityUsers
        .any((selectedUser) => selectedUser.id == user.id)) {
      _selectedCommunityUsers
          .removeWhere((selectedUser) => selectedUser.id == user.id);
    } else {
      _selectedCommunityUsers.add(user);
    }

    notifyListeners();
  }

  void reportOrUnReportUser(AmityUser user) {
    if (user.isFlaggedByMe) {
      user.report().unflag().then((value) {
        AmitySuccessDialog.showTimedDialog("Unreport sent");
      }).onError((error, stackTrace) {
        AmityDialog()
            .showAlertErrorDialog(title: "Error", message: error.toString());
      });
    } else {
      user.report().flag().then((value) {
        AmitySuccessDialog.showTimedDialog("Report sent");
      }).onError((error, stackTrace) {
        AmityDialog()
            .showAlertErrorDialog(title: "Error", message: error.toString());
      });
    }
  }

  void setSelectedUsersList(List<AmityUser> users) {
    _selectedCommunityUsers.clear();
    for (AmityUser user in users) {
      _selectedCommunityUsers.add(user);
    }
  }

  void blockUser(String userId, Function onCallBack) {
    AmityCoreClient.newUserRepository()
        .relationship()
        .blockUser(userId)
        .then((value) {
      print(value);
      AmitySuccessDialog.showTimedDialog("Blocked user");
      notifyListeners();
      onCallBack();
    }).onError((error, stackTrace) {
      AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
    });
  }

  void unBlockUser(String userId) {
    AmityCoreClient.newUserRepository()
        .relationship()
        .unblockUser(userId)
        .then((value) {
      print(value);
      AmitySuccessDialog.showTimedDialog("Unblock user");
      notifyListeners();
    }).onError((error, stackTrace) {
      AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
    });
  }

  final _amityBlockedUsers = <AmityUser>[];
  late PagingController<AmityUser> _amityBlockedUsersController;
  final blockedUserscrollcontroller = ScrollController();

  void getBlockedUsers() {
    _amityUsersController = PagingController(
      pageFuture: (token) => AmityCoreClient.newUserRepository()
          .getBlockedUsers()
          .getPagingData(token: token, limit: 20),
      pageSize: 20,
    )..addListener(
        () async {
          if (_amityBlockedUsersController.error == null) {
            _amityBlockedUsers.clear();
            _amityBlockedUsers.addAll(_amityBlockedUsersController.loadedItems);
            sortedUserListWithHeaders();
            notifyListeners();
          } else {
            log("error");
            await AmityDialog().showAlertErrorDialog(
                title: "Error!",
                message: _amityBlockedUsersController.error.toString());
          }
        },
      );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _amityBlockedUsersController.fetchNextPage();
    });

    blockedUserscrollcontroller.removeListener(() {});
    blockedUserscrollcontroller.addListener(blockedUserloadnextpage);
  }

  void blockedUserloadnextpage() async {
    if ((blockedUserscrollcontroller.position.pixels >
        blockedUserscrollcontroller.position.maxScrollExtent - 800)) {
      log("hasmore: ${_amityBlockedUsersController.hasMoreItems}");
    }
    if ((blockedUserscrollcontroller.position.pixels >
            blockedUserscrollcontroller.position.maxScrollExtent - 800) &&
        _amityBlockedUsersController.hasMoreItems &&
        !loadingNexPage) {
      loadingNexPage = true;
      notifyListeners();
      log("loading Next Page...");
      sortedUserListWithHeaders();
      await _amityBlockedUsersController.fetchNextPage().then((value) {
        loadingNexPage = false;
        notifyListeners();
      });
    }
  }
}
