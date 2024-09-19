import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/utils/bloc_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'community_pin_events.dart';
part 'community_pin_state.dart';

class CommunityPinBloc extends Bloc<CommunityPinEvent, CommunityPinState> {
  final String communityId;
  final ScrollController scrollController;
  late final PinnedPostLiveCollection announcementLiveCollection;
  late final PinnedPostLiveCollection pinLiveCollection;

  CommunityPinBloc({required this.communityId, required this.scrollController})
      : super(CommunityPinState()) {

    on<CommunityPinEventAnnouncementUpdated>((event, emit) async {
      emit(state.copyWith(announcements: event.announcements));
    });

    on<CommunityPinEventPinUpdated>((event, emit) async {
      emit(state.copyWith(pins: event.pins));
    });

    announcementLiveCollection = AmitySocialClient.newPostRepository()
        .getPinnedPosts(
          communityId: communityId,
          placement:"announcement"
        );

    pinLiveCollection = AmitySocialClient.newPostRepository()
        .getPinnedPosts(
          communityId: communityId,
          placement:"default"
        );

    announcementLiveCollection.loadNext();
    pinLiveCollection.loadNext();

    announcementLiveCollection.getStreamController().stream.listen((announcements) {
      addEvent(CommunityPinEventAnnouncementUpdated(announcements: announcements));
    });

    pinLiveCollection.getStreamController().stream.listen((pins) {
      addEvent(CommunityPinEventPinUpdated(pins: pins));
    });
  }

  @override
  Future<void> close() {
    announcementLiveCollection.dispose();
    pinLiveCollection.dispose();
    return super.close();
  }
}
