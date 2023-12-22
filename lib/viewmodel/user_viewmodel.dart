import 'dart:developer';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../components/alert_dialog.dart';
import '../repository/chat_repo_imp.dart';
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
      print("success");
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
    print("get user");
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
  Future<void> initUserList(String keyworkd) async {
    _amityUsersController = PagingController(
      pageFuture: (token) => AmityCoreClient.newUserRepository()
          .searchUserByDisplayName(keyworkd)
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
      print("hasmore: ${_amityUsersController.hasMoreItems}");
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

  List<AmityUser> _amityUsers = [];
  List<AmityUser> selectedUsers = [];
  late PagingController<AmityUser> _amityUsersController;

  List<AmityUser> get amityUsers => _amityUsers;

  void getUsersForCommunity(AmityUserSortOption amityUserSortOption) {
    print("getUsersForCommunity");
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
            print(_amityUsersController.error);
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
    print("sorted");
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
    //   print(item.keys.first);
    //   for (var user in item.values.first) {
    //     print(user.displayName);
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

  void setSelectedUsersList(List<AmityUser> users) {
    _selectedCommunityUsers.clear();
    for (AmityUser user in users) {
      _selectedCommunityUsers.add(user);
    }
  }
}
