part of 'post_composer_bloc.dart';

class PostComposerState extends Equatable {
  const PostComposerState();

  @override
  List<Object?> get props => [];
}

class PostComposerSelectedFiles extends PostComposerState {
  final Map<String, AmityFileInfoWithUploadStatus> selectedFiles;
  final List<AmityVideo> currentVideos;

  const PostComposerSelectedFiles({
    required this.selectedFiles,
    this.currentVideos = const [],
  });

  PostComposerSelectedFiles copyWith({
    Map<String, AmityFileInfoWithUploadStatus> selectedFiles = const {},
    List<AmityVideo> currentVideos = const [],
  }) {
    return PostComposerSelectedFiles(
      selectedFiles: selectedFiles,
      currentVideos: currentVideos,
    );
  }

  @override
  List<Object> get props => [selectedFiles];
}

class PostComposerTextChangeState extends PostComposerState {
  PostComposerTextChangeState({required this.text});

  final String text;

  @override
  List<Object> get props => [text];
}
