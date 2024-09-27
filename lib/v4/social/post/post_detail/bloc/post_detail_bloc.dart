import 'package:amity_sdk/amity_sdk.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'post_detail_events.dart';
part 'post_detail_state.dart';

class PostDetailBloc extends Bloc<PostDetailEvent, PostDetailState> {
  PostDetailBloc({required postId, AmityPost? post})
      : super(post != null
            ? PostDetailStateLoaded(post: post)
            : PostDetailStateInitial(postId: postId)) {
    AmitySocialClient.newPostRepository().live.getPost(postId).listen((event) {
      if (!isClosed) {
        emit(PostDetailStateLoaded(post: event));
      }
    });

    on<PostDetailLoad>((event, emit) async {
      final post =
          await AmitySocialClient.newPostRepository().getPost(event.postId);
      emit(PostDetailStateLoaded(post: post));
    });

    on<PostDetailReplyComment>((event, emit) async {
      if (state is PostDetailStateLoaded) {
        emit(PostDetailStateLoaded(
            post: (state as PostDetailStateLoaded).post,
            replyTo: event.replyTo));
      }
    });
  }
}
