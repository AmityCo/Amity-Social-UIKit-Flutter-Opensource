import 'package:amity_sdk/amity_sdk.dart';

class UserRelationshipManager {
  // Report, Unreport

  void reportUser(String userId,
      {required Function onSuccess, required Function onError}) {
    AmityCoreClient.newUserRepository().report(userId).flag().then((value) {
      onSuccess();
    }).onError((error, stackTrace) {
      onError();
    });
  }

  void unreportUser(String userId,
      {required Function onSuccess, required Function onError}) {
    AmityCoreClient.newUserRepository().report(userId).unflag().then((value) {
      onSuccess();
    }).onError((error, stackTrace) {
      onError();
    });
  }

  // Block, Unblock

  void blockUser(String userId,
      {required Function onSuccess, required Function onError}) {
    AmityCoreClient.newUserRepository()
        .relationship()
        .blockUser(userId)
        .then((value) {
      onSuccess();
    }).onError((error, stackTrace) {
      onError();
    });
  }

  void unblockUser(String userId,
      {required Function onSuccess, required Function onError}) {
    AmityCoreClient.newUserRepository()
        .relationship()
        .unblockUser(userId)
        .then((value) {
      onSuccess();
    }).onError((error, stackTrace) {
      onError();
    });
  }

  // Follow, Unfollow, Accept Follower, Decline Follower

  void followUser(String userId,
      {required Function onSuccess, required Function(Object?) onError}) {
    AmityCoreClient.newUserRepository()
        .relationship()
        .follow(userId)
        .then((value) {
      onSuccess();
    }).onError((error, stackTrace) {
      onError(error);
    });
  }

  void unfollowUser(String userId,
      {required Function onSuccess, required Function onError}) {
    AmityCoreClient.newUserRepository()
        .relationship()
        .unfollow(userId)
        .then((value) {
      onSuccess();
    }).onError((error, stackTrace) {
      onError();
    });
  }

  void acceptFollower(String userId,
      {required Function onSuccess, required Function onError}) {
    AmityCoreClient.newUserRepository()
        .relationship()
        .acceptMyFollower(userId)
        .then((value) {
      onSuccess();
    }).onError((error, stackTrace) {
      onError();
    });
  }

  void declineFollower(String userId,
      {required Function onSuccess, required Function onError}) {
    AmityCoreClient.newUserRepository()
        .relationship()
        .declineMyFollower(userId)
        .then((value) {
      onSuccess();
    }).onError((error, stackTrace) {
      onError();
    });
  }
}
