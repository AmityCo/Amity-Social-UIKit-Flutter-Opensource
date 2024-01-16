import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/viewmodel/user_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../components/alert_dialog.dart';

enum CommunityListType { my, recommend, trending }

enum CommunityFeedMenuOption { edit, members }

enum CommunityType { public, private }

class CommunityVM extends ChangeNotifier {
  var _amityTrendingCommunities = <AmityCommunity>[];
  var _amityRecommendCommunities = <AmityCommunity>[];
  var _amityMyCommunities = <AmityCommunity>[];

  List<AmityCommunity> getAmityTrendingCommunities() {
    return _amityTrendingCommunities;
  }

  List<AmityCommunity> getAmityRecommendCommunities() {
    return _amityRecommendCommunities;
  }

  List<AmityCommunity> getAmityMyCommunities() {
    return _amityMyCommunities;
  }

  void initAmityTrendingCommunityList() async {
    log("initAmityTrendingCommunityList");

    if (_amityTrendingCommunities.isNotEmpty) {
      _amityTrendingCommunities.clear();
      notifyListeners();
    }

    AmitySocialClient.newCommunityRepository()
        .getTrendingCommunities()
        .then((List<AmityCommunity> trendingCommunites) {
      _amityTrendingCommunities = trendingCommunites;
      notifyListeners();
    }).onError((error, stackTrace) async {
      await AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
    });
  }
//ป่าวๆ

  Future<void> createCommunity({
    required BuildContext context,
    required String name,
    required String description,
    required AmityImage? avatar,
    List<String>? tags,
    required List<String> categoryIds,
    required bool isPublic,
    Map<String, String>? metadata,
    List<String>? userIds,
  }) async {
    final communityBuilder = AmitySocialClient.newCommunityRepository()
        .createCommunity(name)
        .description(description)
        .categoryIds(categoryIds);

    if (isPublic) {
      communityBuilder.isPublic(true);
    } else {
      communityBuilder.isPublic(false);
      communityBuilder.userIds(userIds!);
    }

    if (avatar != null) {
      communityBuilder.avatar(avatar);
    }

    await communityBuilder.create();

    notifyListeners();
    Navigator.of(context).pop();
    final userProvider = Provider.of<UserVM>(context, listen: false);
    userProvider.clearselectedCommunityUsers();
  }

  Future<void> updateCommunity(
      String communityId,
      AmityImage? avatar,
      String displayName,
      String description,
      List<String> categoryIds,
      bool isPublic) async {
    if (avatar != null) {
      await AmitySocialClient.newCommunityRepository()
          .updateCommunity(communityId)
          .avatar(avatar)
          .displayName(displayName)
          .description(description)
          .categoryIds(categoryIds)
          .isPublic(isPublic)
          .update()
          .then((value) => notifyListeners())
          .onError((error, stackTrace) async {
        await AmityDialog()
            .showAlertErrorDialog(title: "Error!", message: error.toString());
      });
    } else {
      await AmitySocialClient.newCommunityRepository()
          .updateCommunity(communityId)
          .displayName(displayName)
          .description(description)
          .categoryIds(categoryIds)
          .isPublic(isPublic)
          .update()
          .then((value) => notifyListeners())
          .onError((error, stackTrace) async {
        await AmityDialog()
            .showAlertErrorDialog(title: "Error!", message: error.toString());
      });
    }
  }

  void initAmityRecommendCommunityList() async {
    log("initAmityRecommendCommunityList");
    if (_amityRecommendCommunities.isNotEmpty) {
      _amityRecommendCommunities.clear();
      notifyListeners();
    }

    AmitySocialClient.newCommunityRepository()
        .getRecommendedCommunities()
        .then((List<AmityCommunity> recommendCommunites) async {
      _amityRecommendCommunities = recommendCommunites;
      notifyListeners();
    }).onError((error, stackTrace) async {
      await AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
    });
  }

  void joinCommunity(String communityId, {CommunityListType? type}) async {
    AmitySocialClient.newCommunityRepository()
        .joinCommunity(communityId)
        .then((value) {
      if (type != null) {
        refreshCommunity(type);
      }

      notifyListeners();
    }).onError((error, stackTrace) async {
      await AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
    });
  }

  Future<void> leaveCommunity(String communityId,
      {CommunityListType? type,
      required void Function(bool isSuccess) callback}) async {
    AmitySocialClient.newCommunityRepository()
        .leaveCommunity(communityId)
        .then((value) {
      if (type != null) {
        refreshCommunity(type);
      }
      AmitySuccessDialog.showTimedDialog("Leave community");
      notifyListeners();
      callback(true); // Calling the callback with success status
    }).onError((error, stackTrace) async {
      await AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
      callback(false); // Calling the callback with failure status
    });
  }

  void refreshCommunity(CommunityListType type) {
    switch (type) {
      case CommunityListType.my:
        initAmityMyCommunityList();
        break;
      case CommunityListType.recommend:
        initAmityRecommendCommunityList();
        break;
      case CommunityListType.trending:
        initAmityTrendingCommunityList();
        break;
      default:
        break;
    }
  }

  void initAmityMyCommunityList() async {
    log("initAmityMyCommunityList");
    if (_amityMyCommunities.isNotEmpty) {
      _amityMyCommunities.clear();
      notifyListeners();
    }

    AmitySocialClient.newCommunityRepository()
        .getCommunities()
        .filter(AmityCommunityFilter.MEMBER)
        .sortBy(AmityCommunitySortOption.LAST_CREATED)
        .includeDeleted(false)
        .getPagingData(limit: 100)
        .then((value) {
      _amityMyCommunities = value.data;
      notifyListeners();
    });
  }

  Future<AmityCommunity> getAmityCommunity(String communityId) async {
    var commuObj = await AmitySocialClient.newCommunityRepository()
        .getCommunity(communityId);
    return commuObj;
  }

  AmityImage? amityImages;
  File? pickedFile;

  Future addFile() async {
    final XFile? xFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (xFile != null) {
      pickedFile = File(xFile.path);
      notifyListeners();
      AmityLoadingDialog.showLoadingDialog();
      //log(xFile.path);

      AmityCoreClient.newFileRepository()
          .uploadImage(pickedFile!)
          .stream
          .listen((amityUploadResult) {
        amityUploadResult.when(
          progress: (uploadInfo, cancelToken) {
            int progress = uploadInfo.getProgressPercentage();
            log(progress.toString());
          },
          complete: (file) {
            //check if the upload result is complete
            log("complete");
            AmityLoadingDialog.hideLoadingDialog();
            final AmityImage uploadedImage = file;
            amityImages = uploadedImage;
            //proceed result with uploadedImage
          },
          error: (error) async {
            final AmityException amityException = error;
            //handle error
            await AmityDialog().showAlertErrorDialog(
                title: "Error!", message: error.toString());
          },
          cancel: () {
            //upload is cancelled
          },
        );
      });
    }
  }

  XFile? _seletedFIle;
  Future selectFile() async {
    _seletedFIle = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (_seletedFIle != null) {
      pickedFile = File(_seletedFIle!.path);
      notifyListeners();

      //log(xFile.path);
    }
  }

  Future<void> uploadSelectedFileToAmity() async {
    final completer = Completer<void>();
    if (pickedFile != null) {
      AmityCoreClient.newFileRepository()
          .uploadImage(pickedFile!)
          .stream
          .listen(
        (amityUploadResult) {
          amityUploadResult.when(
            progress: (uploadInfo, cancelToken) {
              int progress = uploadInfo.getProgressPercentage();
              log(progress.toString());
            },
            complete: (file) {
              //check if the upload result is complete
              log("complete");
              final AmityImage uploadedImage = file;
              amityImages = uploadedImage;
              //proceed result with uploadedImage
              completer.complete();
            },
            error: (error) async {
              final AmityException amityException = error;
              //handle error
              await AmityDialog().showAlertErrorDialog(
                title: "Error!",
                message: error.toString(),
              );
              completer.completeError(error);
            },
            cancel: () {
              //upload is cancelled
              completer.completeError(Exception('Upload cancelled'));
            },
          );
        },
      );
    } else {
      completer.complete();
    }

    // Wait for the completer to complete, which happens in the listener above.
    return completer.future;
  }

  void deleteCommunity(String communityId, {required Function(bool) callback}) {
    AmitySocialClient.newCommunityRepository()
        .deleteCommunity(communityId)
        .then((value) {
      //success
      _amityMyCommunities
          .removeWhere((element) => element.communityId == communityId);
      AmitySuccessDialog.showTimedDialog("Community deleted");
      notifyListeners(); // To update the UI after removing the community

      callback(true); // Success status
    }).onError((error, stackTrace) async {
      //handle error
      await AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
      callback(false); // Failure status
    });
  }

  void configPostReview(
      {required String communityId,
      required bool isEnabled,
      required bool ispublic,
      required}) {
    AmitySocialClient.newCommunityRepository()
        .updateCommunity(communityId)
        .isPublic(ispublic)
        .isPostReviewEnabled(isEnabled)
        .update()
        .then((value) {
      //handle result
      log("success");
    }).onError((error, stackTrace) async {
      //handle error
      await AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
    });
  }

  Future<void> addMembers(String communityId, List<String> userIds) async {
    await AmitySocialClient.newCommunityRepository()
        .membership(communityId)
        .addMembers(userIds)
        .then((members) {})
        .onError((error, stackTrace) async {
      //handle error
      await AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
    });
  }
}
