class AmityBlockRepo {
  void initRepo(String accessToken) {}
  Future<void> blockUser(
      String userId, Function(bool, String?) callback) async {}
  Future<void> unblockUser(
      String userId, Function(bool, String?) callback) async {}
  Future<void> getBlockList(Function(List, String?) callback) async {}
  Future<void> checkIsHide(
      List<String> userIdList, Function(Map, String?) callback) async {}
}
