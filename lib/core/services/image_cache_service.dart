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
    paintingBinding?.imageCache?.clear();
    paintingBinding?.imageCache?.clearLiveImages();
  }

  PaintingBinding? get paintingBinding => PaintingBinding.instance;

  void setCacheSize(int maximumSize, int maximumSizeBytes) {
    paintingBinding?.imageCache?.maximumSize = maximumSize;
    paintingBinding?.imageCache?.maximumSizeBytes = maximumSizeBytes;
  }
}
