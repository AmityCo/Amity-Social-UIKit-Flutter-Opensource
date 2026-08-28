import 'dart:async';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:amity_uikit_beta_service/v4/social/story/utils/story_creation_rule.dart';

part 'community_feed_story_event.dart';
part 'community_feed_story_state.dart';

class CommunityFeedStoryBloc
    extends Bloc<CommunityFeedStoryEvent, CommunityFeedStoryState> {
  late StoryLiveCollection storyLiveCollection;
  final AmityStorySortingOrder _sortOption =
      AmityStorySortingOrder.LAST_CREATED;
  late StreamSubscription<List<AmityStory>> _subscriptionStories;
  late StreamSubscription<AmityStoryTarget> _subscriptionTarget;
  StreamSubscription<AmityStorySettings>? _subscriptionStorySettings;
  String? _communityId;
  // Upper bound on the number of times we'll re-verify the permission off
  // the back of incoming data events, so a slow/misbehaving stream can't
  // cause this to re-check indefinitely even while permission stays false.
  static const int _maxPermissionRecheckCount = 4;
  CommunityFeedStoryBloc() : super(CommunityFeedStoryState()) {
    on<CheckMangeStoryPermissionEvent>((event, emit) {
      // This is a synchronous, local-cache read (see
      // CommunityMemberPermissionCheckUsecase): if the member/permission
      // entity for this community hasn't been cached yet, it resolves to
      // false even for a member who does have the permission. We therefore
      // don't treat a single reading as final - see the re-checks dispatched
      // from NewStoryTargetEvent/StoriesFetchedEvent below, which re-run this
      // once the community/story data (and, by then, member/permission
      // cache) has actually arrived.
      var canManageStories =
          AmityCoreClient.hasPermission(AmityPermission.MANAGE_COMMUNITY_STORY)
              .atCommunity(event.communityId)
              .check();
      // Network-level story settings are also a local cache read (warmed at
      // session establish) that can be cold on the very first check, so it
      // rides along on the same re-check cadence/loop-guard as the
      // permission check above rather than needing its own event stream.
      var allowAllUserToCreateStory =
          AmitySocialClient.getStorySettings()?.allowAllUserToCreateStory ??
              false;
      emit(state.copywith(
          haveStoryPermission: canManageStories,
          allowAllUserToCreateStory: allowAllUserToCreateStory,
          permissionCheckCount: state.permissionCheckCount + 1));
    });

    on<StorySettingsUpdated>((event, emit) {
      emit(state.copywith(
          allowAllUserToCreateStory: event.allowAllUserToCreateStory));
    });

    on<ObserveStoryTargetEvent>((event, emit) async {
      _communityId = event.communityId;
      _watchStorySettings();
      _subscriptionTarget = AmitySocialClient.newStoryRepository()
          .live
          .getStoryTaregt(
              targetType: AmityStoryTargetType.COMMUNITY,
              targetId: event.communityId)
          .asBroadcastStream()
          .listen((eventStoryTrget) {
        if (!isClosed) {
          add(NewStoryTargetEvent(storyTarget: eventStoryTrget));
        }
      });
    });

    on<StoriesFetchedEvent>((event, emit) {
      emit(state.copywith(stories: event.stories));
      // The stories collection can settle before or after the community
      // member/permission cache is warm, depending on network timing. If we
      // haven't yet confirmed the permission, re-check now that a data
      // update has actually happened rather than trusting the original
      // (possibly cold-cache) read from initState. Bounded and guarded by
      // haveStoryPermission so this can't loop: once permission resolves
      // true it never re-fires, and it stops re-checking after a handful of
      // data updates either way.
      _maybeRecheckPermission();
    });

    on<SubscribeToCommunityEvent>((event, emit) {
      event.community
          .subscription(AmityCommunityEvents.STORIES_AND_COMMENTS)
          .subscribeTopic()
          .then((value) {
        add(OnEventSubscribedEvent());
      }).onError((error, stackTrace) {
        emit(state.copywith(isEventSubscribed: false));
      });
    });

    on<OnEventSubscribedEvent>((event, emit) {
      emit(state.copywith(isEventSubscribed: true));
    });

    on<NewStoryTargetEvent>((event, emit) {
      // if(state.storyTarget!.syncingStoriesCount>0 && state.storyTarget!.syncingStoriesCount >= event.storyTarget.syncingStoriesCount){
      //   // Show the SnackBar
      // }

      if (event.storyTarget is AmityStoryTargetCommunity) {
        var storyTarget = event.storyTarget as AmityStoryTargetCommunity;
        if (state.isEventSubscribed == false) {
          add(SubscribeToCommunityEvent(community: storyTarget.community!));
          emit(state.copywith(isEventSubscribed: true, isLoading: false));
        }
        emit(state.copywith(
            storyTarget: event.storyTarget,
            community: storyTarget.community,
            isLoading: false));
      } else {
        emit(state.copywith(storyTarget: event.storyTarget, isLoading: false));
      }
      // The community (and its member/permission cache) has just arrived or
      // updated - this is the natural point to resync the permission flag,
      // since the very first check in initState can race the local cache
      // warming up. See _maybeRecheckPermission for the loop guard.
      _maybeRecheckPermission();
    });

    on<FetchStories>((event, emit) async {
      _communityId = event.communityId;
      storyLiveCollection = StoryLiveCollection(
          request: () => AmitySocialClient.newStoryRepository()
              .getActiveStories(
                  targetId: event.communityId,
                  targetType: AmityStoryTargetType.COMMUNITY,
                  orderBy: _sortOption)
              .build());
      _subscriptionStories = storyLiveCollection
          .getStreamController()
          .stream
          .asBroadcastStream()
          .listen((event) {
        if (!isClosed) {
          add(StoriesFetchedEvent(stories: event));
        }
      });
      storyLiveCollection.getData();
    });
  }

  /// Re-dispatches [CheckMangeStoryPermissionEvent] when community/story data
  /// has just changed, so a member who genuinely has
  /// MANAGE_COMMUNITY_STORY (or is covered by the network-level
  /// `allowAllUserToCreateStory` setting) isn't stuck on the stale `false`
  /// produced by the very first (cache-cold) check.
  ///
  /// Guarded against infinite loops in two ways:
  /// - it never re-fires once the effective create permission
  ///   (`haveStoryPermission || allowAllUserToCreateStory`) is already true,
  ///   and
  /// - it stops after [_maxPermissionRecheckCount] attempts regardless, so a
  ///   member who truly lacks the permission (or a non-member) settles to a
  ///   final `false` instead of re-checking forever.
  void _watchStorySettings() {
    _subscriptionStorySettings ??=
        AmitySocialClient.observeStorySettings().listen((settings) {
      if (!isClosed) {
        add(StorySettingsUpdated(
            allowAllUserToCreateStory: settings.allowAllUserToCreateStory));
      }
    });
    _primeStorySettings();
  }

  Future<void> _primeStorySettings() async {
    final cached = AmitySocialClient.getStorySettings();
    if (cached != null) {
      if (!isClosed) {
        add(StorySettingsUpdated(
            allowAllUserToCreateStory: cached.allowAllUserToCreateStory));
      }
      return;
    }
    try {
      final settings = await AmitySocialClient.fetchStorySettings();
      if (!isClosed) {
        add(StorySettingsUpdated(
            allowAllUserToCreateStory: settings.allowAllUserToCreateStory));
      }
    } catch (_) {
    }
  }

  void _maybeRecheckPermission() {
    final communityId = _communityId;
    if (communityId == null) return;
    if (state.haveStoryPermission || state.allowAllUserToCreateStory) return;
    if (state.permissionCheckCount >= _maxPermissionRecheckCount) return;
    if (!isClosed) {
      add(CheckMangeStoryPermissionEvent(communityId: communityId));
    }
  }

  @override
  Future<void> close() {
    _subscriptionStories.cancel();
    _subscriptionTarget.cancel();
    _subscriptionStorySettings?.cancel();
    return super.close();
  }
}
