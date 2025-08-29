import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/amity_uikit.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'view_story_event.dart';
part 'view_story_state.dart';

class ViewStoryBloc extends Bloc<ViewStoryEvent, ViewStoryState> {
  late StoryLiveCollection storyLiveCollection;
    AmityStorySortingOrder _sortOption = AmityStorySortingOrder.FIRST_CREATED;
    late StreamSubscription<List<AmityStory>> _subscription;
    late StreamSubscription<AmityStoryTarget> _subscriptionTarget;
    final bool handleNoStoriesState = AmityUIKit4Manager
      .freedomBehavior.viewStoryPageBehavior.handleNoStoriesState;

  ViewStoryBloc()
      : super(
          const ViewStoryInitial(
            community: null,
            stories: null,
            currentStory: null,
            jumpToUnSeen: 0,
            isCommunityJoined: null,
            storyTarget: null,
            shouldPause: false,
            hasManageStoryPermission: false,
          ),
        ) {
    
    on<ViewStoryEvent>(
      (event, emit) {},
    );

    on<ShoudPauseEvent>(
      (event, emit) {
        emit(
          ShouldPauseState(
            community: state.community,
            stories: state.stories,
            jumpToUnSeen: state.jumpToUnSeen,
            currentStory: state.currentStory,
            isCommunityJoined: state.isCommunityJoined,
            storyTarget: state.storyTarget,
            shouldPause: event.shouldPause,
            hasManageStoryPermission: state.hasManageStoryPermission,
          ),
        );
      },
    );

    on<DeleteStoryEvent>(
      (event, emit) async {
        await AmitySocialClient.newStoryRepository()
            .hardDeleteStory(
          storyId: event.storyId,
        )
            .then(
          (value) {
            add(
              const StoryDeletedEvent(),
            );
          },
        ).onError(
          (error, stackTrace) {
            print("Error in deleting story: $error");
          },
        );
      },
    );

    on<StoryDeletedEvent>(
      (event, emit) async {
        emit(
          StoryDeletedState(
            community: state.community,
            stories: state.stories,
            currentStory: state.currentStory,
            isCommunityJoined: state.isCommunityJoined,
            storyTarget: state.storyTarget,
            jumpToUnSeen: state.jumpToUnSeen,
            shouldPause: state.shouldPause,
            hasManageStoryPermission: state.hasManageStoryPermission,
          ),
        );
      },
    );

    on<StoryRetryEvent>(
      (event, emit) async {
        add(
          DeleteStoryEvent(storyId: event.amityStory.storyId!),
        );
        if (event.amityStory.data is ImageStoryData) {
          AmitySocialClient.newStoryRepository()
              .createImageStory(
                targetType: state.storyTarget!.targetType,
                targetId: state.storyTarget!.targetId,
                imageFile: (event.amityStory.data as ImageStoryData).image.hasLocalPreview != null ? File((event.amityStory.data as ImageStoryData).image.getFilePath!) : File(""),
                storyItems: event.amityStory.storyItems,
                imageDisplayMode: (event.amityStory.data as ImageStoryData).imageDisplayMode,
              )
              .then(
                (value) => null,
              )
              .onError(
                (error, stackTrace) => null,
              );
        } else if (event.amityStory.data is VideoStoryData) {
          final data = event.amityStory.data as VideoStoryData;
          AmitySocialClient.newStoryRepository()
              .createVideoStory(
                targetType: state.storyTarget!.targetType,
                targetId: state.storyTarget!.targetId,
                videoFile: data.video.hasLocalPreview != null ? File((event.amityStory.data as VideoStoryData).video.getFilePath!) : File(""),
                storyItems: event.amityStory.storyItems,
              )
              .then(
                (value) => null,
              )
              .onError(
                (error, stackTrace) => null,
              );
        }
      },
    );

    on<NewCurrentStory>((event, emit) {
      emit(NewCurrentStoryState(community: state.community, stories: state.stories, shouldPause: state.shouldPause, currentStory: event.currentStroy, jumpToUnSeen: state.jumpToUnSeen, isCommunityJoined: state.isCommunityJoined, storyTarget: state.storyTarget, hasManageStoryPermission: state.hasManageStoryPermission));
    });

    on<FetchManageStoryPermission>((event, emit) {
      var canManageStories = AmityCoreClient.hasPermission(AmityPermission.MANAGE_COMMUNITY_STORY).atCommunity(event.communityId).check();
      add(ManageStoryPermissionFetched(hasManageStoryPermission: canManageStories));
    });

    on<AddReactionEvent>((event, emit) {
      AmitySocialClient.newReactionRepository().addReaction(
        AmityStoryReactionReference(referenceId: event.storyId),
        'like',
      );
    });

    on<RemoveReactionEvent>((event, emit) {
      AmitySocialClient.newReactionRepository().removeReaction(
        AmityStoryReactionReference(referenceId: event.storyId),
        'like',
      );
    });

    on<MarkStoryAsViewedEvent>((event, emit) {
      event.story.analytics().markAsSeen();
    });

    on<MarkStoryLinkAsClickedEvent>((event, emit) {
      event.story.analytics().markLinkAsClicked();
    });

    on<ManageStoryPermissionFetched>(
      (event, emit) {
        emit(
          ManagerStoryPermissionFetchedState(
            community: state.community,
            stories: state.stories,
            shouldPause: state.shouldPause,
            jumpToUnSeen: state.jumpToUnSeen,
            currentStory: state.currentStory,
            isCommunityJoined: state.isCommunityJoined,
            storyTarget: state.storyTarget,
            hasManageStoryPermission: event.hasManageStoryPermission,
          ),
        );
      },
    );

    on<StoryTargetFetched>(
      (event, emit) {
        if (event.storyTarget is AmityStoryTargetCommunity) {
          emit(ViewStoryTargetFetched(storyTarget: event.storyTarget, community: (event.storyTarget as AmityStoryTargetCommunity).community, stories: state.stories, shouldPause: state.shouldPause, jumpToUnSeen: state.jumpToUnSeen, hasManageStoryPermission: state.hasManageStoryPermission, currentStory: state.currentStory, isCommunityJoined: state.isCommunityJoined));
        } else {
          AmityCommunity? commnunity = (state.storyTarget as AmityStoryTargetCommunity).community;
          emit(
            ViewStoryTargetFetched(
              storyTarget: event.storyTarget,
              community: state.storyTarget != null ? (state.storyTarget as AmityStoryTargetCommunity).community : null,
              stories: state.stories,
              shouldPause: state.shouldPause,
              jumpToUnSeen: state.jumpToUnSeen,
              hasManageStoryPermission: state.hasManageStoryPermission,
              currentStory: state.currentStory,
              isCommunityJoined: commnunity != null ? commnunity.isJoined : state.isCommunityJoined,
            ),
          );
        }
      },
    );

    on<FetchStoryTarget>(
      (event, emit) {
       _subscriptionTarget =  AmitySocialClient.newStoryRepository()
            .live
            .getStoryTaregt(
              targetType: AmityStoryTargetType.COMMUNITY,
              targetId: event.communityId,
            )
            .asBroadcastStream()
            .listen(
          (storyTarget) {
            add(
              StoryTargetFetched(
                storyTarget: storyTarget,
              ),
            );
          },
        );
      },
    );

    on<JumpToUnSeen>(
      (event, emit) {
        emit(
          JumpToUnSeenState(
            community: state.community,
            stories: state.stories,
            currentStory: state.currentStory,
            isCommunityJoined: state.isCommunityJoined,
            storyTarget: state.storyTarget,
            shouldPause: state.shouldPause,
            jumpToUnSeen: event.jumpToPosition,
            hasManageStoryPermission: state.hasManageStoryPermission,
          ),
        );
      },
    );

    on<FetchActiveStories>((event, emit) {
      storyLiveCollection = StoryLiveCollection(request: () => AmitySocialClient.newStoryRepository().getActiveStories(targetId: event.communityId, targetType: AmityStoryTargetType.COMMUNITY, orderBy: _sortOption).build());
      _subscription =  storyLiveCollection.getStreamController().stream.asBroadcastStream().listen((stoies) {
        add(ActiveStoriesFetched(stories: stoies));
      });
      storyLiveCollection.getData().catchError((_) {
        if (handleNoStoriesState) {
          add(const ActiveStoriesFailed());
        }
        return <AmityStory>[];
      });
    });

    on<ActiveStoriesFetched>(
      (event, emit) {
        if (event.stories.isNotEmpty) {
          AmityCommunity? commnunity = state.storyTarget != null ? (state.storyTarget as AmityStoryTargetCommunity).community ?? null : null;
          emit(
            ActiveStoriesFetchedState(
              storyTarget: state.storyTarget,
              shouldPause: state.shouldPause,
              community: state.storyTarget != null ? (state.storyTarget as AmityStoryTargetCommunity).community : null,
              stories: event.stories,
              hasManageStoryPermission: state.hasManageStoryPermission,
              currentStory: state.currentStory,
              jumpToUnSeen: state.jumpToUnSeen,
              isCommunityJoined: commnunity != null ? commnunity.isJoined : state.isCommunityJoined,
            ),
          );

          if (event.stories.isNotEmpty) {
            var firstUnseenIndex = state.stories?.indexWhere((element) => element.isSeen() == false);
            if (firstUnseenIndex != null) {
              if (firstUnseenIndex != -1) {
                print("Jumping to unseen story at index: $firstUnseenIndex");
                add(
                  JumpToUnSeen(
                    jumpToPosition: firstUnseenIndex,
                  ),
                );
              }
            }
          }
        }
      },
    );

    on<ActiveStoriesFailed>(
      (event, emit) {
        emit(
          ErrorState(
            community: state.community,
            stories: state.stories,
            currentStory: state.currentStory,
            isCommunityJoined: state.isCommunityJoined,
            storyTarget: state.storyTarget,
            shouldPause: state.shouldPause,
            jumpToUnSeen: state.jumpToUnSeen,
            hasManageStoryPermission: state.hasManageStoryPermission,
          ),
        );
      },
    );
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    _subscriptionTarget.cancel();
    return super.close();
  }
}
