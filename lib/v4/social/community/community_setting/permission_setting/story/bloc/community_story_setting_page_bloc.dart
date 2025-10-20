import 'dart:async';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:amity_uikit_beta_service/v4/utils/bloc_extension.dart';

part 'community_story_setting_page_event.dart';
part 'community_story_setting_page_state.dart';

class CommunityStorySettingPageBloc extends Bloc<CommunityStorySettingPageEvent,
    CommunityStorySettingPageState> {
  late AmityCommunity community;
  late StreamSubscription<AmityCommunity> communityStream;

  CommunityStorySettingPageBloc({required this.community})
      : super(CommunityStorySettingPageState()) {
    communityStream = AmitySocialClient.newCommunityRepository()
        .live
        .getCommunity(community.communityId ?? '')
        .listen((community) {
      addEvent(CommunityStorySettingPageEvent(
          isCommentEnabled: community.allowCommentInStory ?? false));
    });

    on<CommunityStorySettingPageEvent>((event, emit) {
      emit(state.copyWith(isCommentEnabled: event.isCommentEnabled));
    });

    on<CommunityStorySettingChangedEvent>((event, emit) {
      AmitySocialClient.newCommunityRepository()
          .updateCommunity(community.communityId ?? '')
          .storySettings(
              AmityCommunityStorySettings(allowComment: event.isCommentEnabled))
          .update();

      emit(state.copyWith(isCommentEnabled: event.isCommentEnabled));
    });
  }
}
