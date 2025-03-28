class ProcessedTextCache {
  ProcessedTextCache._();

  static final ProcessedTextCache _instance = ProcessedTextCache._();

  factory ProcessedTextCache() => _instance;

  final Map<String, List<Map<String, dynamic>>> _processedTextCache = {};

  List<Map<String, dynamic>>? get(String key) => _processedTextCache[key];

  void put(String key, List<Map<String, dynamic>> entities) {
    _ensureCapacity(80);
    _processedTextCache[key] = entities;
  }

  bool contains(String key) => _processedTextCache.containsKey(key);

  void clear() => _processedTextCache.clear();

  void _ensureCapacity(int maxEntries) {
    if (_processedTextCache.length > maxEntries) {
      // Remove oldest entries (simple approach - remove first entries)
      final entriesToRemove = _processedTextCache.length - maxEntries;
      final keysToRemove =
          _processedTextCache.keys.take(entriesToRemove).toList();
      for (final key in keysToRemove) {
        _processedTextCache.remove(key);
      }
    }
  }
}
