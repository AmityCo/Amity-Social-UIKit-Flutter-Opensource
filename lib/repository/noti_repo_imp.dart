import 'package:amity_uikit_beta_service/model/amity_notification_model.dart';
import 'package:dio/dio.dart';

import 'noti_repo.dart';

class AmityNotificationRepoImp implements AmityNotificationRepo {
  String? accessToken;

  @override
  void initRepo(String accessToken) {
    this.accessToken = accessToken;
  }

  @override
  Future<void> fetchNotification(
      Function(AmityNotifications? notifications, String? error)
          callback) async {
    var dio = Dio();
    final response = await dio.get(
      "https://beta.amity.services/notifications/history",
      options: Options(
        headers: {
          "Authorization": "Bearer $accessToken" // set content-length
        },
      ),
    );

    if (response.statusCode == 200) {
      var amityPushNotification = AmityNotifications.fromJson(response.data);
      callback(amityPushNotification, null);
    } else {
      callback(
        null,
        response.data["message"],
      );
    }
  }

  @override
  Future<void> markLastRead(Function(String? data, String? errpr) callback) {
    // TODO: implement markLastRead
    throw UnimplementedError();
  }

  @override
  Future<void> readNotification(
      {String? targetId,
      String? targetGroup,
      required Function(String? data, String? errpr) callback}) {
    // TODO: implement readNotification
    throw UnimplementedError();
  }
}
