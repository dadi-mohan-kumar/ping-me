// import 'package:firebase_remote_config/firebase_remote_config.dart';

// class RemoteConfigService {

//   static final FirebaseRemoteConfig _remoteConfig =
//       FirebaseRemoteConfig.instance;

//   static Future<void> initialize() async {

//     await _remoteConfig.setConfigSettings(
//       RemoteConfigSettings(
//         fetchTimeout: const Duration(seconds: 10),
//         minimumFetchInterval: Duration.zero,
//       ),
//     );

//     await _remoteConfig.fetchAndActivate();
//   }

//   static bool get forceUpdate =>
//       _remoteConfig.getBool('force_update');

//   static String get minVersion =>
//       _remoteConfig.getString('min_version');

//   static String get playStoreUrl =>
//       _remoteConfig.getString('playstore_url');
// }
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ForceUpdateService {
  static final FirebaseRemoteConfig _remoteConfig =
      FirebaseRemoteConfig.instance;

  static Future<void> initialize() async {
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: Duration.zero,
      ),
    );

    await _remoteConfig.setDefaults({
      'min_version': '1.0.0',
      'playstore_url': '',
    });

    await _remoteConfig.fetchAndActivate();
  }

  static Future<bool> isUpdateRequired() async {
    final packageInfo =
        await PackageInfo.fromPlatform();

    final currentVersion =
        packageInfo.version;

    final minimumVersion =
        _remoteConfig.getString(
      'min_version',
    );

    return _compareVersions(
      currentVersion,
      minimumVersion,
    );
  }

  static bool _compareVersions(
    String current,
    String minimum,
  ) {
    final currentParts =
        current.split('.').map(int.parse).toList();

    final minimumParts =
        minimum.split('.').map(int.parse).toList();

    for (int i = 0; i < minimumParts.length; i++) {
      if (currentParts[i] <
          minimumParts[i]) {
        return true;
      }

      if (currentParts[i] >
          minimumParts[i]) {
        return false;
      }
    }

    return false;
  }

  static String getStoreUrl() {
    return _remoteConfig.getString(
      'playstore_url',
    );
  }
}
