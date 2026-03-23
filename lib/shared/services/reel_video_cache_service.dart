import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ReelVideoCacheService {
  ReelVideoCacheService()
    : _cacheManager = CacheManager(
        Config(
          _cacheKey,
          stalePeriod: const Duration(days: 3),
          maxNrOfCacheObjects: 20,
        ),
      );

  static const String _cacheKey = 'reel_video_cache';

  final CacheManager _cacheManager;

  Future<File> getVideoFile(String url) async {
    final cached = await _cacheManager.getFileFromCache(url);
    if (cached != null && await cached.file.exists()) {
      return cached.file;
    }

    final downloaded = await _cacheManager.downloadFile(url, key: url);
    return downloaded.file;
  }

  Future<void> clear() => _cacheManager.emptyCache();
}
