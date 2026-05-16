import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageCacheService {
  ImageCacheService._();
  static final ImageCacheService _instance = ImageCacheService._();
  static ImageCacheService get instance => _instance;

  void preloadImages(BuildContext context, List<String> urls) {
    for (final url in urls) {
      if (url.isNotEmpty) {
        precacheImage(CachedNetworkImageProvider(url), context);
      }
    }
  }

  void clearCache() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }

  void setCacheSize(int maximumSize, int maximumSizeBytes) {
    PaintingBinding.instance.imageCache.maximumSize = maximumSize;
    PaintingBinding.instance.imageCache.maximumSizeBytes = maximumSizeBytes;
  }
}
