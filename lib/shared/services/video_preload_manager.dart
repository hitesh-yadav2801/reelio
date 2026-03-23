import 'dart:math' as math;

import 'package:injectable/injectable.dart';
import 'package:reelio/features/feed/domain/entities/reel.dart';
import 'package:reelio/shared/services/reel_video_cache_service.dart';
import 'package:video_player/video_player.dart';

@lazySingleton
class VideoPreloadManager {
  VideoPreloadManager(this._cacheService);

  static const int preloadAheadCount = 4;
  static const int keepBehindCount = 1;
  static const int keepAheadCount = 4;

  final ReelVideoCacheService _cacheService;

  final Map<int, VideoPlayerController> _controllers = {};
  final Map<int, Future<VideoPlayerController>> _pendingControllers = {};

  VideoPlayerController? controllerFor(int index) => _controllers[index];

  Future<VideoPlayerController> getOrCreateController({
    required int index,
    required String videoUrl,
  }) {
    final existing = _controllers[index];
    if (existing != null) {
      return Future.value(existing);
    }

    final pending = _pendingControllers[index];
    if (pending != null) {
      return pending;
    }

    final future = _createController(index: index, videoUrl: videoUrl);
    _pendingControllers[index] = future;

    return future.whenComplete(() {
      _pendingControllers.remove(index);
    });
  }

  Future<void> onPageChanged({
    required int currentIndex,
    required List<Reel> reels,
    int? previousIndex,
  }) async {
    if (reels.isEmpty || currentIndex < 0 || currentIndex >= reels.length) {
      return;
    }

    final currentController = await getOrCreateController(
      index: currentIndex,
      videoUrl: reels[currentIndex].videoUrl,
    );

    if (previousIndex != null && previousIndex != currentIndex) {
      await _controllers[previousIndex]?.pause();
    }

    for (final entry in _controllers.entries) {
      if (entry.key != currentIndex) {
        await entry.value.pause();
      }
    }

    if (currentController.value.isInitialized) {
      await currentController.play();
    }

    await _preloadAhead(currentIndex: currentIndex, reels: reels);
    await _disposeOutsideWindow(currentIndex: currentIndex);
  }

  Future<void> pauseAll() async {
    for (final controller in _controllers.values) {
      await controller.pause();
    }
  }

  Future<void> resetAndDispose() async {
    for (final controller in _controllers.values) {
      await controller.dispose();
    }
    _controllers.clear();
    _pendingControllers.clear();
  }

  Future<VideoPlayerController> _createController({
    required int index,
    required String videoUrl,
  }) async {
    VideoPlayerController? controller;

    try {
      final file = await _cacheService.getVideoFile(videoUrl);
      controller = VideoPlayerController.file(file);
      await controller.initialize();
    } on Exception {
      await controller?.dispose();
      controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      await controller.initialize();
    }

    await controller.setLooping(true);
    await controller.setVolume(1);
    await controller.pause();

    _controllers[index] = controller;
    return controller;
  }

  Future<void> _preloadAhead({
    required int currentIndex,
    required List<Reel> reels,
  }) async {
    final preloadLimit = math.min(
      reels.length - 1,
      currentIndex + preloadAheadCount,
    );

    final futures = <Future<void>>[];

    for (var index = currentIndex + 1; index <= preloadLimit; index++) {
      futures.add(
        getOrCreateController(
          index: index,
          videoUrl: reels[index].videoUrl,
        ).then((_) {}).catchError((_) {}),
      );
    }

    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }
  }

  Future<void> _disposeOutsideWindow({required int currentIndex}) async {
    final minKeep = currentIndex - keepBehindCount;
    final maxKeep = currentIndex + keepAheadCount;

    final toDispose = _controllers.keys
        .where((index) => index < minKeep || index > maxKeep)
        .toList(growable: false);

    for (final index in toDispose) {
      final controller = _controllers.remove(index);
      await controller?.dispose();
    }

    final stalePending = _pendingControllers.keys
        .where((index) => index < minKeep || index > maxKeep)
        .toList(growable: false);

    for (final index in stalePending) {
      final pending = _pendingControllers.remove(index);
      if (pending == null) {
        continue;
      }

      await pending
          .then((controller) => controller.dispose())
          .catchError((_) {});
    }
  }
}
