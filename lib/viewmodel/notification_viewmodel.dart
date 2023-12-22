import 'dart:developer';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/components/alert_dialog.dart';
import 'package:amity_uikit_beta_service/model/amity_notification_model.dart';
import 'package:amity_uikit_beta_service/repository/noti_repo_imp.dart';
import 'package:amity_uikit_beta_service/utils/env_manager.dart';
import 'package:amity_uikit_beta_service/viewmodel/user_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/navigation_key.dart';

class NotificationVM extends ChangeNotifier {
  AmityNotificationRepoImp channelRepoImp = AmityNotificationRepoImp();
  AmityNotifications? notificationsObject;
  var actorMapper = {};

  void initVM() async {
    log("NotificationVM: initVM");
    var accessToken = Provider.of<UserVM>(
            NavigationService.navigatorKey.currentContext!,
            listen: false)
        .accessToken;

    if (accessToken != null) {
      channelRepoImp.initRepo(accessToken);
      log(">>>>updateNotification...");
      await updateNotification();
    } else {
      AmityDialog().showAlertErrorDialog(
          title: "Error!", message: "accessToken is null");
    }
  }

  Future<void> updateNotification() async {
    if (env!.region != null) {
      await channelRepoImp.fetchNotification((notifications, error) async {
        if (notifications != null) {
          notificationsObject = notifications;
          await addImageNotificationWorkAround(notifications);
          notifyListeners();
        } else {
          AmityDialog()
              .showAlertErrorDialog(title: "Error!", message: error.toString());
        }
      });
    } else {
      AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: ".env is missing");
    }
  }

  Future<void> mapActor(AmityNotificaion notification) async {
    if (actorMapper.containsKey(notification.actors![0].id)) {
      print(">>>>>>>>${actorMapper[notification.actors![0].id]["avatarUrl"]}");
      print(">>>>>>>>${actorMapper[notification.actors![0].id]["avatarUrl"]}");
      notification.actors?[0].imageUrl =
          actorMapper[notification.actors![0].id]["avatarUrl"];
      notification.actors?[0].name =
          actorMapper[notification.actors![0].id]["displayName"];
    } else {
      if (notification.actors![0].id != "_admin_vodworks-admin") {
        ///Add first actor image
        ///TODO: Willuse Map to make sure that each user was loaded only 1 time
        await AmityCoreClient.newUserRepository()
            .getUser(notification.actors![0].id!)
            .then((value) {
          actorMapper[notification.actors![0].id] = {
            "displayName": value.displayName,
            "avatarUrl": value.avatarUrl,
          };

          notification.actors?[0].imageUrl = value.avatarUrl;
          notification.actors?[0].name = value.displayName;
        }).onError((error, stackTrace) {
          // AmityDialog().showAlertErrorDialog(
          //     title: "Error!: getUserrrrrr", message: error.toString());
        });
      } else {
        notification.actors![0].name = "Anonymous";
      }
    }
  }

  Future<void> addImageNotificationWorkAround(
      AmityNotifications notifications) async {
    for (var i = 0; i < notifications.data!.length; i++) {
      var notification = notificationsObject?.data![i];

      if (notification != null) {
        mapActor(notification);
        if (notification.targetId != null) {
          if (notification.targetType == "community") {
            log(">>>>>>>>>>is community targetType");
            await AmitySocialClient.newCommunityRepository()
                .getCommunity(notification.targetId!)
                .then((value) {
              ///add target displayname for community
              notificationsObject!.data![i].targetDisplayName =
                  value.displayName;

              /// add target avatarUrl for community
              if (value.avatarFileId != null) {
                notificationsObject!.data![i].targetImageUrl =
                    "https://api.${env!.region}.amity.co/api/v3/files/${value.avatarFileId}/download";
              }
            }).onError((error, stackTrace) {
              log(error.toString());
              AmityDialog().showAlertErrorDialog(
                  title: "Error!:getCommunity ", message: error.toString());
            });
          } else if (notification.targetType == "post") {
            log(">>>>>>>>>>is post targetType");
            await AmitySocialClient.newPostRepository()
                .getPost(notification.targetId!)
                .then((value) {
              log(">>>>CALL BACK FROM newPostRepository");
              if (value.children != null) {
                if (value.children!.isNotEmpty) {
                  if (value.children![0].data is ImageData) {
                    var postData = value.children![0].data as ImageData;
                    log("is imageData: ${postData.fileId}");

                    /// add target imageUrl for Post if it's image post'
                    notificationsObject!.data![i].targetImageUrl =
                        "https://api.${env!.region}.amity.co/api/v3/files/${postData.fileId}/download";
                  } else if (value.children![0].data is VideoData) {
                    /// add target imageUrl for Post if it's video post
                    var postData = value.children![0].data as VideoData;
                    log("is videoData: ${postData.fileId}");
                    if (postData.thumbnail != null) {
                      var thumbnailURL = postData.thumbnail!.fileUrl;
                      notificationsObject!.data![i].targetImageUrl =
                          thumbnailURL;
                    }
                  }
                }
              }
            }).onError((error, stackTrace) {
              log(error.toString());
              AmityDialog().showAlertErrorDialog(
                  title: "Error! notification.targetType == post",
                  message: error.toString());
            });
          } else {
            log(">>>>>Unhandle tagetType");
          }
        }
      }
    }
  }

  String prefixStringBuilder(List<Actors> actors) {
    var emptyDisplayname = "Empty Name";
    var prefixString = "";
    if (actors.length == 1) {
      prefixString = actors[0].name ?? emptyDisplayname;
    } else if (actors.length == 2) {
      prefixString = actors[0].name ?? emptyDisplayname;
      prefixString +=
          " and ${prefixString = actors[1].name ?? emptyDisplayname}";
    } else if (actors.length == 3) {
      prefixString = actors[0].name ?? emptyDisplayname;
      prefixString += ", ${prefixString = actors[1].name ?? emptyDisplayname}";
      prefixString +=
          ", and ${prefixString = actors[2].name ?? emptyDisplayname}";
    } else if (actors.length > 3) {
      prefixString = actors[0].name ?? emptyDisplayname;
      prefixString += ", ${prefixString = actors[1].name ?? emptyDisplayname}";
      prefixString = actors[0].name ?? emptyDisplayname;
      prefixString += ", and ${actors.length - 2} others";
    } else {
      prefixString = "Unhandle Notification actors";
    }
    return prefixString;
  }

  String verbStringBuilder(String verb) {
    var verbString = "";
    if (verb == "post") {
      verbString = "posted";
    } else if (verb == "comment") {
      verbString = "commented";
    } else if (verb == "like") {
      verbString = "likes";
    } else {
      verbString = verb;
    }
    return verbString;
  }

  String suffixStringBuilder(String verb, String? targetDisplayname) {
    var suffix = "";
    if (verb == "post") {
      suffix = "";
    } else if (verb == "comment") {
      suffix = "on your post";
    } else if (verb == "like") {
      suffix = "your post";
    } else {
      suffix = verb;
    }
    if (targetDisplayname != null) {
      suffix += "in $targetDisplayname";
    }
    return suffix;
  }

  //TODO: create description
  List<String> extractDescription(AmityNotificaion notificaion) {
    List<String> result = [];
    switch (notificaion.verb) {
      case "post":
        {
          // statements;
          result = notificaion.description!.split("posted");
        }
        break;

      case "comment":
        {
          //statements;
          result = notificaion.description!.split("commented");
        }
        break;

      case "like":
        {
          //statements;
          result = notificaion.description!.split("likes");
        }
        break;

      default:
        {
          //statements;
        }
        break;
    }
    return result;
  }
}
