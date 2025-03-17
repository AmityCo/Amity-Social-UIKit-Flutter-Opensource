import 'package:amity_sdk/amity_sdk.dart';

enum AmityErrorCode {
  BAN_WORD_FOUND,
  TARGET_NOT_FOUND,
  NO_USER_ACCESS_PERMISSION,
}

extension AmityExceptionExtension on AmityException {
  int getErrorCode(AmityErrorCode error) {
    switch (error) {
      case AmityErrorCode.BAN_WORD_FOUND:
        return 400308;
      case AmityErrorCode.TARGET_NOT_FOUND:
        return 400400;
      case AmityErrorCode.NO_USER_ACCESS_PERMISSION:
        return 400301;
    }
  }

  // Compares `code` property from AmityException with the given error code
  bool isAmityErrorWithCode(AmityErrorCode code) {
    return this.code == getErrorCode(code);
  }
}
