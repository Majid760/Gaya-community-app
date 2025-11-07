import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class CrashlyticsService {
  Future<void> log(String message) async {
    if (kDebugMode) print('CrashlyticsService.log: $message');
    await FirebaseCrashlytics.instance.log(message);
  }

  Future<void> setCustomKey(String key, dynamic value) async {
    await FirebaseCrashlytics.instance.setCustomKey(key, value);
  }

  Future<void> setUserIdentifier(String identifier) async {
    await FirebaseCrashlytics.instance.setUserIdentifier(identifier);
  }

  Future<void> recordError(dynamic error, {StackTrace? stackTrace, String? reason, bool isFatal = false}) async {
    if (kDebugMode) {
      print('CrashlyticsService.recordError: $error');
      print('CrashlyticsService.recordError: $stackTrace');
      print('CrashlyticsService.recordError: $reason');
      print('CrashlyticsService.recordError: $isFatal');
      return;
    }
    stackTrace ??= StackTrace.current;
    await FirebaseCrashlytics.instance.recordError(error, stackTrace, reason: reason, fatal: isFatal);
    print('CrashlyticsService.recordError: done');
  }
}
