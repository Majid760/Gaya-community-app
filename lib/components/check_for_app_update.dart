import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controller/firebase_analytics_controller.dart';
import '../shared/service/engagement_score_services/engagement_helpers/engagement_utils.dart';
import '../shared/service/service/version_platform_services.dart';
import '../utils/const.dart';
import '../utils/flavors/flavors.dart';
import '../utils/language/translation.dart';
import '../utils/logger.dart';
import '../utils/theme/app_typography.dart';

class GayaRemoteConfig extends GetxService {
  static GayaRemoteConfig get to => Get.find();

  FirebaseRemoteConfig get remoteConfig => FirebaseRemoteConfig.instance;

  // Initialize Remote Config
  Future<void> _initRemoteConfig() async {
    debugPrint("initRemoteConfig");
    try {
      remoteConfig.setDefaults(<String, dynamic>{
        'androidBuildVersion': '1.0.0',
        'iOSBuildVersion': '1.0.0',
        'isShowInviteHome': false,
        'scoringSystem': jsonEncode(ScoringValues.defaultValues().toMap()),
        RemoteConfigKeys.minimumCrownsToCreateCommunity: 0,
        RemoteConfigKeys.showInstagramShareStory: false,
        RemoteConfigKeys.showCreateGroupChat: false,
        RemoteConfigKeys.isPostDMEnabled: false,
        RemoteConfigKeys.isConnectyCubeEnabled: true,
      });
      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 30),
          minimumFetchInterval: const Duration(days: 1),
        ),
      );
      await remoteConfig.fetchAndActivate();
      getScoringSystem();
      debugPrint("remoteConfig::: ${remoteConfig.getString('androidBuildVersion')}");
    } catch (e) {
      MyLoggerServices.to.print(e);
    }
  }

  Future<void> checkAppVersion({required BuildContext context}) async {
    await _initRemoteConfig();

    final packageInfo = await VersionPlatformServices.to.getPlatformInfo();
    if (packageInfo == null) return;

    String version = packageInfo.version;
    MyLoggerServices.to.print('$version app buildverison');

    if (DeviceCheck.isWeb) return;

    if (DeviceCheck.isIOS) {
      String currentVersionString = version;

      String newVersionString = remoteConfig.getString('iOSBuildVersion');

      /// show dialog if current is less than new version
      bool showUpdateDialog = GayaRemoteConfigUtils.isCurrentVersionGreater(currentVersionString, newVersionString);
      if (!showUpdateDialog) {
        GayaRemoteConfigUtils.showVersionDialog(context);

        // Logging user with old version analytics event
        AnalyticsController.to.instance.logUserWithOldVersion(
          currentVersion: version,
          newVersion: newVersionString,
          userId: FirebaseAuth.instance.currentUser?.uid ?? '',
        );
      }
    } else if (DeviceCheck.isAndroid) {
      String currentVersionString = version;
      print("androidBuildVersion isnaroid");
      String newVersionString = remoteConfig.getString('androidBuildVersion');

      if (newVersionString.isEmpty) {
        await remoteConfig.fetchAndActivate();
        newVersionString = remoteConfig.getString('androidBuildVersion');
      }
      print("currentVersionString $currentVersionString newVersionString $newVersionString");

      /// show dialog if current is less than new version
      bool showUpdateDialog = GayaRemoteConfigUtils.isCurrentVersionGreater(currentVersionString, newVersionString);
      if (!showUpdateDialog) {
        GayaRemoteConfigUtils.showVersionDialog(context);

        // Logging user with old version analytics event
        AnalyticsController.to.instance.logUserWithOldVersion(
          currentVersion: version,
          newVersion: newVersionString,
          userId: FirebaseAuth.instance.currentUser?.uid ?? '',
        );
      }
    }
  }

  int get minimumCrownsToCreateCommunity {
    try {
      return GayaRemoteConfigUtils.getRemoteConfigIntValue(RemoteConfigKeys.minimumCrownsToCreateCommunity, remoteConfig: remoteConfig);
    } catch (_) {
      debugPrint("Error in get minimumCrownsToCreateCommunity $_");
      return 0;
    }
  }

  void getScoringSystem() {
    try {
      Map<String, dynamic> scoringSystem =
          jsonDecode(GayaRemoteConfigUtils.getRemoteConfigValue(RemoteConfigKeys.scoringSystem, remoteConfig: remoteConfig));
      ScoringValues scoringValues = ScoringValues.fromMap(scoringSystem);
      EngagementScoreController.to.setScoringValue(scoringValues: scoringValues);
    } catch (e) {
      MyLoggerServices.to.print("Error in getScoringSystem $e");
    }
  }

  bool get isShowInviteHome =>
      GayaRemoteConfigUtils.getRemoteConfigBoolValue(RemoteConfigKeys.isShowInviteHome, remoteConfig: remoteConfig);

  bool get isShowInstagramShareStory =>
      F.isDev ? true : GayaRemoteConfigUtils.getRemoteConfigBoolValue(RemoteConfigKeys.showInstagramShareStory, remoteConfig: remoteConfig);

  bool get isPostDMEnabled =>
      isConnectyCubeEnabled && GayaRemoteConfigUtils.getRemoteConfigBoolValue(RemoteConfigKeys.isPostDMEnabled, remoteConfig: remoteConfig);

  bool get isGroupChatFeatureEnabled =>
      GayaRemoteConfigUtils.getRemoteConfigBoolValue(RemoteConfigKeys.showCreateGroupChat, remoteConfig: remoteConfig);

  bool get isConnectyCubeEnabled =>
      GayaRemoteConfigUtils.getRemoteConfigBoolValue(RemoteConfigKeys.isConnectyCubeEnabled, remoteConfig: remoteConfig);
}

class GayaRemoteConfigUtils {
  static String getRemoteConfigValue(String key, {required FirebaseRemoteConfig remoteConfig}) {
    return remoteConfig.getString(key);
  }

  static String getRemoteConfigStringValue(String key, {required FirebaseRemoteConfig remoteConfig}) {
    return remoteConfig.getString(key);
  }

  static bool getRemoteConfigBoolValue(String key, {required FirebaseRemoteConfig remoteConfig}) {
    try {
      return remoteConfig.getBool(key);
    } catch (e) {
      MyLoggerServices.to.print("Error in getRemoteConfigBoolValue $e");
      return false;
    }
  }

  static int getRemoteConfigIntValue(String key, {required FirebaseRemoteConfig remoteConfig}) {
    return remoteConfig.getInt(key);
  }

  static double getRemoteConfigDoubleValue(String key, {required FirebaseRemoteConfig remoteConfig}) {
    return remoteConfig.getDouble(key);
  }

  /// Compare version
  /// version = currentVersion
  ///
  static bool isCurrentVersionGreater(String currentVersion, String newVersion) {
    try {
      List<int> v1 = currentVersion.split(".").map(int.parse).toList();
      List<int> v2 = newVersion.split(".").map(int.parse).toList();
      for (int i = 0; i < v1.length && i < v2.length; i++) {
        if (v1[i] < v2[i]) {
          debugPrint("currentVersion: $currentVersion > newVersion: $newVersion v1[i] < v2[i] : false");
          return false;
        } else if (v1[i] > v2[i]) {
          debugPrint("currentVersion: $currentVersion > newVersion: $newVersion v1[i] > v2[i] : true");
          return true;
        }
      }
      if (v1.length < v2.length) {
        debugPrint("currentVersion: $currentVersion > newVersion: $newVersion v1.length < v2.length : false");
        return false;
      }

      debugPrint("currentVersion: $currentVersion > newVersion: $newVersion equal equal case");
      return true;
    } catch (_) {
      return true;
    }
  }

  static getStringAndConvertToDouble(String key, {required FirebaseRemoteConfig remoteConfig}) {
    double version = 0;

    String versionString = remoteConfig.getString(key);
    try {
      debugPrint("VERSOON STRING: $versionString");
      version = double.parse(versionString.trim().replaceAll(".", ""));
    } catch (e) {
      MyLoggerServices.to.print("error: $e");
    }
    return version;
  }

  //Show Dialog to force user to update
  static showVersionDialog(context) async {
    await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        String title = GayaStrings.new_update.tr;
        String message = GayaStrings.update_access_gaya.tr;
        String btnLabel = GayaStrings.update_txt.tr;
        return WillPopScope(
          onWillPop: () async => false,
          child: DeviceCheck.isIOS
              ? CupertinoAlertDialog(
                  title: Text(title),
                  content: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(message),
                  ),
                  insetAnimationDuration: const Duration(milliseconds: 400),
                  insetAnimationCurve: Curves.easeInOut,
                  actions: <Widget>[
                    CupertinoDialogAction(
                      child: Text(btnLabel, style: TextStyle(color: kprimaryColor, fontWeight: FontWeight.bold, fontSize: 14.sp)),
                      onPressed: () => _launchURL(APP_STORE_URL),
                    ),
                  ],
                )
              : AlertDialog(
                  contentPadding: EdgeInsets.zero,
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 15),
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(message, style: const TextStyle(color: Colors.grey), textAlign: TextAlign.center),
                      ),
                      const SizedBox(height: 15),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: kprimaryColor, padding: EdgeInsets.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                            child: Text(btnLabel),
                            onPressed: () => _launchURL(DeviceCheck.isIOS == true ? APP_STORE_URL : PLAY_STORE_URL),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                    ],
                  ),
                ),
        );
      },
    );
  }

  static _launchURL(String url, {bool isRecursive = false}) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      MyLoggerServices.to.print('Could not launch url');
      if (!isRecursive) {
        _launchURL(url, isRecursive: true);
      }
    }
  }
}

class RemoteConfigKeys {
  static const String isShowInviteHome = 'isShowInviteHome';
  static const String dailyCrownAirdropTime = 'dailyCrownAirdropTime';
  static const String iOSBuildVersion = 'iOSBuildVersion';
  static const String androidBuildVersion = 'androidBuildVersion';
  static const String scoringSystem = 'scoringSystem';
  static const String minimumCrownsToCreateCommunity = 'minimumCrownsToCreateCommunity';
  static const String isPostDMEnabled = 'isPostDMEnabled';
  static const String showInstagramShareStory = 'showInstagramShareStory';
  static const String showCreateGroupChat = 'showCreateGroupChat';
  static const String isConnectyCubeEnabled = 'isConnectyCubeEnabled';
}
