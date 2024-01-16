import 'dart:convert';

import 'package:amity_uikit_beta_service/repository/block_repo.dart';
import 'package:dio/dio.dart';

class AmityBlockRepoInp implements AmityBlockRepo {
  String? accessToken;

  @override
  void initRepo(String accessToken) {
    this.accessToken = accessToken;
  }

  @override
  Future<void> blockUser(
      Object userId, Function(bool p1, String? p2) callback) {
    // TODO: implement blockUser
    throw UnimplementedError();
  }

  @override
  Future<void> checkIsHide(List<String> userIdList,
      Function(Map isBlockMap, String? error) callback) async {
    var dio = Dio();
    String url = "https://beta.amity.services/block/members";
    for (var i = 0; i < userIdList.length; i++) {
      if (i == 0) {
        url += "?checkList=${userIdList[i]}";
      } else {
        url += "&checkList=${userIdList[i]}";
      }
    }
    final response = await dio.delete(
      url,
      options: Options(
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken" // set content-length
        },
      ),
    );

    if (response.statusCode == 200) {
      callback(jsonDecode(response.data), null);
    } else {
      callback(
        {},
        response.data["message"],
      );
    }
  }

  @override
  Future<void> getBlockList(Function(List, String? p2) callback) async {}

  @override
  Future<void> unblockUser(
      String userId, Function(bool p1, String? p2) callback) {
    // TODO: implement unblockUser
    throw UnimplementedError();
  }
}
