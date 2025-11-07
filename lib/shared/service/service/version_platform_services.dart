import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:package_info/package_info.dart';

class VersionPlatformServices extends GetxService {
  static VersionPlatformServices get to => Get.find();
  PackageInfo? packageInfo;

  /// Get the package info from the platform.
  /// This is a singleton, so it will only be called once.
  Future<PackageInfo?> getPlatformInfo() async {
    if (kIsWeb) return null;

    /// try catch but still generate fromPlatform function
    try {
      packageInfo ??= await PackageInfo.fromPlatform();
    } catch (_) {
      packageInfo ??= await PackageInfo.fromPlatform();
    }

    return packageInfo;
  }
}
