import 'package:amity_sdk/amity_sdk.dart';
import 'package:equatable/equatable.dart';

class PendingPostsState extends Equatable {
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;
  final List<AmityPost> posts;
  final bool loadingMore;
  final bool hasMoreData;
  final String communityId;
  final bool isCheckingRole;
  final bool isModerator;

  const PendingPostsState({
    required this.isLoading,
    required this.hasError,
    this.errorMessage,
    required this.posts,
    this.loadingMore = false,
    this.hasMoreData = true,
    required this.communityId,
    this.isCheckingRole = false,
    this.isModerator = false,
  });

  bool get isEmpty => !isLoading && posts.isEmpty && !hasError && !isCheckingRole;
  bool get showLoading => (isLoading || isCheckingRole) && posts.isEmpty;

  @override
  List<Object?> get props => [
    isLoading, 
    hasError, 
    errorMessage, 
    posts, 
    loadingMore, 
    hasMoreData, 
    communityId,
    isCheckingRole,
    isModerator
  ];

  PendingPostsState copyWith({
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
    List<AmityPost>? posts,
    bool? loadingMore,
    bool? hasMoreData,
    String? communityId,
    bool? isCheckingRole,
    bool? isModerator,
  }) {
    return PendingPostsState(
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      posts: posts ?? this.posts,
      loadingMore: loadingMore ?? this.loadingMore,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      communityId: communityId ?? this.communityId,
      isCheckingRole: isCheckingRole ?? this.isCheckingRole,
      isModerator: isModerator ?? this.isModerator,
    );
  }
}
