import 'package:flutter_test/flutter_test.dart';
import 'package:gaya/components/check_for_app_update.dart';

void main() {
  /// Test for version comparison

  const String androidRemoteConfigVersion = "1.0.191";
  const iosRemoteConfig = "2.3.3294";
  test('currentVersion: 2.3.3292 > newVersion: 2.4.0 false', () {
    print("ios");
    expect(GayaRemoteConfigUtils.isCurrentVersionGreater("2.3.3292", iosRemoteConfig), false);
  });

  test('currentVersion: 2.4.0 > newVersion: 2.3.1 true" ', () {
    expect(GayaRemoteConfigUtils.isCurrentVersionGreater("2.4.0", iosRemoteConfig), true);
  });

  test('currentVersion: 2.3.3291 > newVersion: 2.3.3294 false', () {
    expect(GayaRemoteConfigUtils.isCurrentVersionGreater("2.3.3291", iosRemoteConfig), false);
  });

  test('currentVersion: 2.3.328 > newVersion: 2.1.0 true', () {
    expect(GayaRemoteConfigUtils.isCurrentVersionGreater("2.3.328", "2.1.0"), true);
  });

  /// android
  test('currentVersion: 1.0.192 > newVersion: $androidRemoteConfigVersion false', () {
    expect(GayaRemoteConfigUtils.isCurrentVersionGreater("1.0.200", androidRemoteConfigVersion), true);
    expect(GayaRemoteConfigUtils.isCurrentVersionGreater("1.0.192", "1.0.200"), false);
    expect(GayaRemoteConfigUtils.isCurrentVersionGreater("1.0.196", androidRemoteConfigVersion), true);
  });

}
