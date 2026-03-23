import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ReelUploadRemoteConfigService {
  ReelUploadRemoteConfigService(this._remoteConfig);

  final FirebaseRemoteConfig _remoteConfig;

  static const String _maxReelFileSizeMbKey = 'reel_file_size';
  static const int _defaultMaxReelFileSizeMb = 20;

  Future<void> initialize() async {
    try {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(hours: 1),
        ),
      );

      await _remoteConfig.setDefaults(<String, Object>{
        _maxReelFileSizeMbKey: _defaultMaxReelFileSizeMb,
      });

      await _remoteConfig.fetchAndActivate();
    } on Exception {
      // Keep defaults when fetch fails (offline/timeout/etc).
    }
  }

  int get maxReelFileSizeMb {
    final value = _remoteConfig.getInt(_maxReelFileSizeMbKey);
    if (value <= 0) {
      return _defaultMaxReelFileSizeMb;
    }

    return value;
  }

  int get maxReelFileSizeBytes => maxReelFileSizeMb * 1024 * 1024;
}
