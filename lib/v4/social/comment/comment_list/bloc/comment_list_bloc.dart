import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'comment_list_events.dart';
part 'comment_list_state.dart';

class CommentListBloc extends Bloc<CommentListEvent, CommentListState> {
  var commentCount = 0;

  CommentListBloc(
    String referenceId,
    AmityCommentReferenceType referenceType,
    String? parentId,
  ) : super(CommentListStateInitial(
            referenceId: referenceId, referenceType: referenceType)) {
    CommentLiveCollection liveCollection =
        getNewLiveCollection(referenceId, referenceType, parentId);

    liveCollection.getStreamController().stream.listen((event) {
      if (!isClosed) {
        commentCount = event.length;
        add(CommentListEventChanged(
            comments: event, isFetching: liveCollection.isFetching));
      }
    });

    on<CommentListEventRefresh>((event, emit) async {
      emit(CommentListStateChanged(
        referenceId: state.referenceId,
        referenceType: state.referenceType,
        comments: const [],
        isFetching: true,
        hasNextPage: true,
        expandedId: const [],
      ));
      try {
        liveCollection.reset();
        liveCollection.loadNext();
        Future.delayed(const Duration(seconds: 2), () {
          // Workaround after 2 second will emit empty events.
          if (!liveCollection.isFetching && commentCount == 0) {
            add(CommentListEventChanged(
                comments: const [], isFetching: liveCollection.isFetching));
          }
        });
      } catch (e) {
        emit(CommentListStateChanged(
          referenceId: state.referenceId,
          referenceType: state.referenceType,
          comments: const [],
          isFetching: false,
          hasNextPage: false,
          expandedId: const [],
        ));

        if (e is AmityException) {
          event.toastBloc
              .add(AmityToastShort(message: "Couldn’t load comment"));
        }
      }
    });

    on<CommentListEventChanged>((event, emit) async {
      emit(state.copyWith(
        comments: event.comments,
        isFetching: event.isFetching,
        hasNextPage: liveCollection.hasNextPage(),
      ));
    });

    on<CommentListEventExpandItem>((event, emit) async {
      if (!state.expandedId.contains(event.commentId)) {
        emit(
            state.copyWith(expandedId: [...state.expandedId, event.commentId]));
      }
    });

    on<CommentListEventLoadMore>((event, emit) async {
      try {
        await liveCollection.loadNext();
      } catch (e) {
        if (e is AmityException) {
          event.toastBloc
              .add(AmityToastShort(message: "Couldn’t load comment"));
        }
      }
    });

    on<CommentListEventDisposed>((event, emit) async {
      liveCollection.getStreamController().close();
    });
  }

  CommentLiveCollection getNewLiveCollection(String referenceId,
      AmityCommentReferenceType referenceType, String? parentId) {
    if (referenceType == AmityCommentReferenceType.POST) {
      return AmitySocialClient.newCommentRepository()
          .getComments()
          .post(referenceId)
          .parentId(parentId)
          .sortBy(AmityCommentSortOption.LAST_CREATED)
          .dataTypes(null)
          .includeDeleted(false)
          .getLiveCollection();
    }
    if (referenceType == AmityCommentReferenceType.STORY) {
      return AmitySocialClient.newCommentRepository()
          .getComments()
          .story(referenceId)
          .parentId(parentId)
          .sortBy(AmityCommentSortOption.LAST_CREATED)
          .dataTypes(null)
          .includeDeleted(false)
          .getLiveCollection();
    }
    else {
      return AmitySocialClient.newCommentRepository()
          .getComments()
          .content(referenceId)
          .parentId(parentId)
          .sortBy(AmityCommentSortOption.LAST_CREATED)
          .dataTypes(null)
          .includeDeleted(false)
          .getLiveCollection();
    }
  }
}
