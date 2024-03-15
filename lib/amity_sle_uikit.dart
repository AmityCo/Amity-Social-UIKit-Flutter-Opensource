// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/utils/navigation_key.dart';
import 'package:amity_uikit_beta_service/viewmodel/category_viewmodel.dart';
import 'package:amity_uikit_beta_service/viewmodel/chat_room_viewmodel.dart';
import 'package:amity_uikit_beta_service/viewmodel/community_feed_viewmodel.dart';
import 'package:amity_uikit_beta_service/viewmodel/community_member_viewmodel.dart';
import 'package:amity_uikit_beta_service/viewmodel/component_size_viewmodel.dart';
import 'package:amity_uikit_beta_service/viewmodel/create_postV2_viewmodel.dart';
import 'package:amity_uikit_beta_service/viewmodel/explore_page_viewmodel.dart';
import 'package:amity_uikit_beta_service/viewmodel/media_viewmodel.dart';
import 'package:amity_uikit_beta_service/viewmodel/my_community_viewmodel.dart';
import 'package:amity_uikit_beta_service/viewmodel/notification_viewmodel.dart';
import 'package:amity_uikit_beta_service/viewmodel/pending_request_viewmodel.dart';
import 'package:amity_uikit_beta_service/viewmodel/reply_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'viewmodel/amity_viewmodel.dart';
import 'viewmodel/channel_list_viewmodel.dart';
import 'viewmodel/community_viewmodel.dart';
import 'viewmodel/configuration_viewmodel.dart';
import 'viewmodel/create_post_viewmodel.dart';
import 'viewmodel/custom_image_picker.dart';
import 'viewmodel/feed_viewmodel.dart';
import 'viewmodel/post_viewmodel.dart';
import 'viewmodel/user_feed_viewmodel.dart';
import 'viewmodel/user_viewmodel.dart';

enum AmityRegion {
  sg,
  eu,
  us,
  custom; // Added for custom URLs
}

class AmitySLEUIKit {
  Future<void> initUIKit(
      {required String apikey,
      required AmityRegion region,
      String? customEndpoint}) async {
    AmityRegionalHttpEndpoint? amityEndpoint;

    switch (region) {
      case AmityRegion.custom:
        if (customEndpoint != null) {
          amityEndpoint = AmityRegionalHttpEndpoint.custom(customEndpoint);
        } else {
          log("please provide custom Endpoint");
        }

        break;
      case AmityRegion.sg:
        {
          amityEndpoint = AmityRegionalHttpEndpoint.SG;
        }

        break;
      case AmityRegion.eu:
        {
          amityEndpoint = AmityRegionalHttpEndpoint.EU;
        }

        break;
      case AmityRegion.us:
        {
          amityEndpoint = AmityRegionalHttpEndpoint.US;
        }
    }

    await AmityCoreClient.setup(
        option:
            AmityCoreClientOption(apiKey: apikey, httpEndpoint: amityEndpoint!),
        sycInitialization: true);
  }

  Future<void> registerDevice(
      {required BuildContext context,
      required String userId,
      String? displayName,
      String? authToken,
      Function(bool isSuccess, String? error)? callback}) async {
    await Provider.of<AmityVM>(context, listen: false)
        .login(userID: userId, displayName: displayName, authToken: authToken)
        .then((value) async {
      log("login success");
      await Provider.of<UserVM>(context, listen: false)
          .initAccessToken()
          .then((value) {
        log("initAccessToken success");
        if (Provider.of<UserVM>(context, listen: false).accessToken != null ||
            Provider.of<UserVM>(context, listen: false).accessToken != "") {
          if (callback != null) {
            callback(true, null);
          }
        } else {
          if (callback != null) {
            callback(false, "Initialize accesstoken fail...");
          }
        }
      }).onError((error, stackTrace) {
        log("initAccessToken fail...");
        log(error.toString());
        if (callback != null) {
          callback(true, error.toString());
        }
      });
    }).onError((error, stackTrace) {
      log("registerDevice...Error:$error");
      if (callback != null) {
        callback(false, "Initialize accesstoken fail...");
      }
    });
  }

  Future<void> registerNotification(
      String fcmToken, Function(bool isSuccess, String? error) callback) async {
    // example of getting token from firebase
    // FirebaseMessaging messaging = FirebaseMessaging.instance;
    // final fcmToken = await messaging.getToken();
    // await AmityCoreClient.unregisterDeviceNotification();
    // log("unregisterDeviceNotification");
    await AmityCoreClient.registerDeviceNotification(fcmToken).then((value) {
      log("registerNotification succesfully ✅");
      callback(true, null);
    }).onError((error, stackTrace) {
      callback(false, "Initialize push notification fail...❌");
    });
  }

  void configAmityThemeColor(
      BuildContext context, Function(AmityUIConfiguration config) config) {
    var provider = Provider.of<AmityUIConfiguration>(context, listen: false);
    config(provider);
  }

  AmityUser getCurrentUser() {
    return AmityCoreClient.getCurrentUser();
  }

  void unRegisterDevice() {
    AmityCoreClient.unregisterDeviceNotification();
    AmityCoreClient.logout();
  }

  Future<void> joinInitialCommunity(List<String> communityIds) async {
    for (var i = 0; i < communityIds.length; i++) {
      AmitySocialClient.newCommunityRepository()
          .joinCommunity(communityIds[i])
          .then((value) {
        log("join community:${communityIds[i]} success");
      }).onError((error, stackTrace) {
        log(error.toString());
      });
    }
  }
}

class AmitySLEProvider extends StatelessWidget {
  final Widget child;
  const AmitySLEProvider({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ReplyVM>(create: ((context) => ReplyVM())),
        ChangeNotifierProvider<SearchCommunityVM>(
            create: ((context) => SearchCommunityVM())),
        ChangeNotifierProvider<CompoentSizeVM>(
            create: ((context) => CompoentSizeVM())),
        ChangeNotifierProvider<UserVM>(create: ((context) => UserVM())),
        ChangeNotifierProvider<AmityVM>(create: ((context) => AmityVM())),
        ChangeNotifierProvider<FeedVM>(create: ((context) => FeedVM())),
        ChangeNotifierProvider<CommunityVM>(
            create: ((context) => CommunityVM())),
        ChangeNotifierProvider<PostVM>(create: ((context) => PostVM())),
        ChangeNotifierProvider<UserFeedVM>(create: ((context) => UserFeedVM())),
        ChangeNotifierProvider<ImagePickerVM>(
            create: ((context) => ImagePickerVM())),
        ChangeNotifierProvider<CreatePostVM>(
            create: ((context) => CreatePostVM())),
        ChangeNotifierProvider<CreatePostVMV2>(
            create: ((context) => CreatePostVMV2())),
        ChangeNotifierProvider<ChannelVM>(create: ((context) => ChannelVM())),
        ChangeNotifierProvider<AmityUIConfiguration>(
            create: ((context) => AmityUIConfiguration())),
        ChangeNotifierProvider<NotificationVM>(
            create: ((context) => NotificationVM())),
        ChangeNotifierProvider<CategoryVM>(create: ((context) => CategoryVM())),
        ChangeNotifierProvider<PendingVM>(create: ((context) => PendingVM())),
        ChangeNotifierProvider<MyCommunityVM>(
            create: ((context) => MyCommunityVM())),
        ChangeNotifierProvider<CommuFeedVM>(
            create: ((context) => CommuFeedVM())),
        ChangeNotifierProvider<ExplorePageVM>(
            create: ((context) => ExplorePageVM())),
        ChangeNotifierProvider<MemberManagementVM>(
            create: ((context) => MemberManagementVM())),
        ChangeNotifierProvider<MediaPickerVM>(
            create: ((context) => MediaPickerVM())),
        ChangeNotifierProvider<ChatRoomVM>(create: ((context) => ChatRoomVM())),
      ],
      child: Builder(
        builder: (context) => MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: NavigationService.navigatorKey,
          home: DefaultTextStyle(
              style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 8),
              child: child),
        ),
      ),
    );
  }
}
