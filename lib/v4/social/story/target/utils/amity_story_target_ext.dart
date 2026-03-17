import 'package:amity_sdk/amity_sdk.dart';

enum AmityStoryTargetRingUiState {
  SEEN,
  HAS_UNSEEN,
  SYNCING,
  FAILED,
}

extension AmityStoryTargetRingUiStateExt on AmityStoryTarget {
  AmityStoryTargetRingUiState toRingUiState() {
    if (syncingStoriesCount > 0) {
      return AmityStoryTargetRingUiState.SYNCING;
    }
    if (failedStoriesCount > 0) {
      return AmityStoryTargetRingUiState.FAILED;
    }
    if (hasUnseen) {
      return AmityStoryTargetRingUiState.HAS_UNSEEN;
    }
    return AmityStoryTargetRingUiState.SEEN;
  }
}
