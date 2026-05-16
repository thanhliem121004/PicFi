import 'package:flutter/material.dart';

export 'debouncer.dart';

class LazyLoadingMixin {
  bool _hasLoaded = false;

  bool get hasLoaded => _hasLoaded;

  void markLoaded() {
    _hasLoaded = true;
  }

  void reset() {
    _hasLoaded = false;
  }

  Widget buildLazy({
    required Widget loaded,
    required Widget loading,
  }) {
    return _hasLoaded ? loaded : loading;
  }
}

class ImageCacheManager {
  ImageCacheManager._();

  static const int defaultMaxSize = 100;
  static const int defaultMaxSizeBytes = 100 << 20;

  static void configure({int? maxSize, int? maxSizeBytes}) {
    PaintingBinding.instance.imageCache.maximumSize = maxSize ?? defaultMaxSize;
    PaintingBinding.instance.imageCache.maximumSizeBytes = maxSizeBytes ?? defaultMaxSizeBytes;
  }

  static void clear() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }

  static int get currentSize => PaintingBinding.instance.imageCache.currentSize;
  static int get currentSizeBytes => PaintingBinding.instance.imageCache.currentSizeBytes;
}
