import 'package:amity_sdk/amity_sdk.dart';

enum AmityErrorCode { BAN_WORD_FOUND }

extension AmityExceptionExtension on AmityException {
  

  int getErrorCode(AmityErrorCode error) {
    if (error == AmityErrorCode.BAN_WORD_FOUND) {
      return 400308;
    } else {
      return 800000; // Unknown error
    }
  }
}