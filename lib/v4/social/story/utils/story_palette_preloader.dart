import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/social/story/utils/story_palette_cache.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

/// Proactive palette preloader for visible story targets
/// Preloads palettes in background to ensure instant display on first tap
class StoryPalettePreloader {
  StoryPalettePreloader._internal();
  static final StoryPalettePreloader _instance = StoryPalettePreloader._internal();
  factory StoryPalettePreloader() => _instance;
  
  final _globalCache = StoryPaletteCache();
  final Set<String> _preloadingStories = {}; // Track stories currently being preloaded
  final Queue<_PaletteJob> _queue = Queue();
  final Map<String, _PaletteJob> _pendingJobs = {};
  int _runningJobs = 0;

  /// Limit concurrent palette generation so we don't overwhelm the UI thread.
  /// This can be tuned if needed for wider devices.
  static const int _maxConcurrentJobs = 1;
  
  /// Preload palettes for a list of stories
  /// Call this when stories are displayed/visible to the user
  void preloadStories(List<AmityStory> stories, {int limit = 2}) {
    if (stories.isEmpty) return;

    final effectiveLimit = limit.clamp(0, stories.length).toInt();
    for (final story in stories.take(effectiveLimit)) {
      preloadStory(story);
    }
  }
  
  /// Preload palette for a single story
  Future<void> preloadStory(AmityStory story) async {
    final storyId = story.storyId ?? '';
    if (storyId.isEmpty) return;
    
    // Skip if already cached or currently preloading
    if (_globalCache.has(storyId)) return;
    if (_preloadingStories.contains(storyId)) return;
    
    // Only preload image stories
    if (story.dataType != AmityStoryDataType.IMAGE) return;
    if (story.data == null) return;
    
    final imageData = story.data as ImageStoryData;
    if (imageData.imageDisplayMode == AmityStoryImageDisplayMode.FILL) {
      return;
    }
    _scheduleJob(
      storyId: storyId,
      providerFactory: () => _resolveImageProvider(imageData),
    );
    _processQueue();
  }

  /// Ensure palette exists for provided image data and receive callback when ready.
  Future<PaletteGenerator?> ensurePaletteForImageData({
    required String storyId,
    required ImageStoryData imageData,
  }) {
    if (storyId.isEmpty) return Future.value(null);
    if (imageData.imageDisplayMode == AmityStoryImageDisplayMode.FILL) {
      return Future.value(null);
    }
    if (_globalCache.has(storyId)) {
      return Future.value(_globalCache.get(storyId));
    }

    final job = _scheduleJob(
      storyId: storyId,
      providerFactory: () => _resolveImageProvider(imageData),
    );

    final completer = Completer<PaletteGenerator?>();
    job.addListener((palette) {
      if (!completer.isCompleted) {
        completer.complete(palette);
      }
    });

    _processQueue();
    return completer.future;
  }
  
  /// Get number of stories currently being preloaded
  int get preloadingCount => _preloadingStories.length;
  
  /// Check if a story is currently being preloaded
  bool isPreloading(String storyId) => _preloadingStories.contains(storyId);

  void _processQueue() {
    if (_runningJobs >= _maxConcurrentJobs) return;
    if (_queue.isEmpty) return;

    final job = _queue.removeFirst();
    _runningJobs++;

    _runJob(job).whenComplete(() {
      _runningJobs--;
      // Kick off the next job, if any
      _processQueue();
    });
  }

  Future<void> _runJob(_PaletteJob job) async {
    PaletteGenerator? palette;
    try {
      final provider = job.providerFactory();
      palette = await PaletteGenerator.fromImageProvider(
        provider,
        size: const Size(32, 32),
      );
    } catch (_) {
      // Ignore failures – preloading is best-effort
    }
    if (palette != null) {
      _globalCache.set(job.storyId, palette);
    }

    _preloadingStories.remove(job.storyId);
    _pendingJobs.remove(job.storyId);
    job.notify(palette);
  }

  _PaletteJob _scheduleJob({
    required String storyId,
    required ImageProvider Function() providerFactory,
  }) {
    final existing = _pendingJobs[storyId];
    if (existing != null) {
      return existing;
    }

    final job = _PaletteJob(
      storyId: storyId,
      providerFactory: providerFactory,
    );
    _pendingJobs[storyId] = job;
    _preloadingStories.add(storyId);
    _queue.add(job);
    return job;
  }

  ImageProvider _resolveImageProvider(ImageStoryData imageData) {
    if (imageData.image.hasLocalPreview != null && imageData.image.hasLocalPreview!) {
      return FileImage(File(imageData.image.getFilePath!));
    }
    // SMALL keeps quality sufficient for palette while reducing decode cost significantly
    return NetworkImage(imageData.image.getUrl(AmityImageSize.SMALL));
  }
}

class _PaletteJob {
  _PaletteJob({
    required this.storyId,
    required this.providerFactory,
  });

  final String storyId;
  final ImageProvider Function() providerFactory;
  final List<void Function(PaletteGenerator?)> _listeners = [];

  void addListener(void Function(PaletteGenerator?) listener) {
    _listeners.add(listener);
  }

  void notify(PaletteGenerator? palette) {
    for (final listener in _listeners) {
      listener(palette);
    }
  }
}
