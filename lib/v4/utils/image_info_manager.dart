class ImageInfoManager {
  ImageInfoManager._internal();

  static final ImageInfoManager _instance = ImageInfoManager._internal();

  factory ImageInfoManager() {
    return _instance;
  }

  final Map<String, ImageSizeCache> messageImageCaches = {};

  void addImageData(String url, double height, double width) {
    messageImageCaches[url] = ImageSizeCache(url: url, height: height, width: width);
  }

  bool contains(String url) {
    return messageImageCaches.containsKey(url);
  }
}

class ImageSizeCache {
  final String url;
  final double height;
  final double width;

  ImageSizeCache({
    required this.url,
    required this.height,
    required this.width,
  });
}
