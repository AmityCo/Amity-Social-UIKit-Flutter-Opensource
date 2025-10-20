import 'package:palette_generator/palette_generator.dart';

/// Global singleton cache for story palettes
/// Persists across communities and page transitions for instant color display
class StoryPaletteCache {
  StoryPaletteCache._internal();
  static final StoryPaletteCache _instance = StoryPaletteCache._internal();
  factory StoryPaletteCache() => _instance;
  
  // Cache key format: "storyId" for globally unique identification
  final Map<String, PaletteGenerator> _cache = {};
  
  // Maximum cache size to prevent memory bloat
  static const int _maxCacheSize = 50;
  
  /// Get cached palette for a story
  PaletteGenerator? get(String storyId) {
    return _cache[storyId];
  }
  
  /// Store palette for a story
  void set(String storyId, PaletteGenerator palette) {
    // Implement LRU-like behavior: remove oldest if cache is full
    if (_cache.length >= _maxCacheSize) {
      // Remove first (oldest) entry
      final firstKey = _cache.keys.first;
      _cache.remove(firstKey);
    }
    
    _cache[storyId] = palette;
  }
  
  /// Check if palette exists in cache
  bool has(String storyId) {
    return _cache.containsKey(storyId);
  }
  
  /// Remove palette from cache
  void remove(String storyId) {
    _cache.remove(storyId);
  }
  
  /// Clear entire cache
  void clear() {
    _cache.clear();
  }
  
  /// Get cache size
  int get size => _cache.length;
}
