import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/utils/bloc_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'post_detail_events.dart';
part 'post_detail_state.dart';

class PostDetailBloc extends Bloc<PostDetailEvent, PostDetailState> {
  PostDetailBloc({ required postId, AmityPost? post })
      : super(post != null ? PostDetailStateLoaded(post: post) : PostDetailStateInitial(postId: postId)) {
    AmitySocialClient
      .newPostRepository()
      .live
      .getPost(postId)
      .listen(
        (event) {
          addEvent(PostDetailLoaded(post: event));
        },
        onError: (error) {
          addEvent(PostDetailError(message: error.toString()));
        },
      );

      on<PostDetailLoad>((event, emit) async {
        try {
          final post = await AmitySocialClient
            .newPostRepository()
            .getPost(event.postId);
          
          // Check if post is deleted
          if (post.isDeleted ?? false) {
            emit(PostDetailStateError(message: 'Post has been deleted'));
            return;
          }
          
          emit(PostDetailStateLoaded(post: post));
        } catch (error) {
          emit(PostDetailStateError(message: error.toString()));
        }
      });

      on<PostDetailLoaded>((event, emit) async {
        // Check if post is deleted
        if (event.post.isDeleted ?? false) {
          emit(PostDetailStateError(message: 'Post has been deleted'));
          return;
        }
        
        emit(PostDetailStateLoaded(post: event.post));
      });

      on<PostDetailReplyComment>((event, emit) async {
        if (state is PostDetailStateLoaded) {
          emit(PostDetailStateLoaded(post: (state as PostDetailStateLoaded).post, replyTo: event.replyTo));
        }
      });

      on<PostDetailError>((event, emit) async {
        emit(PostDetailStateError(message: event.message));
      });
  }
}