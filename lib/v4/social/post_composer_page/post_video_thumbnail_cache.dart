import 'dart:typed_data';

/// A singleton cache that stores locally-extracted video thumbnails
/// keyed by child post ID. This is used as a fallback when the server
/// hasn't yet generated the thumbnail for a newly created video post.
class PostVideoThumbnailCache {
  PostVideoThumbnailCache._();
  static final PostVideoThumbnailCache instance = PostVideoThumbnailCache._();

  final Map<String, Uint8List> _cache = {};

  void set(String postId, Uint8List thumbnail) {
    _cache[postId] = thumbnail;
  }

  Uint8List? get(String postId) {
    return _cache[postId];
  }

  void remove(String postId) {
    _cache.remove(postId);
  }

  void clear() {
    _cache.clear();
  }
}
