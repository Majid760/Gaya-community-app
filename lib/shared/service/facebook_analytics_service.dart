import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter/cupertino.dart';

/// A Singleton class to initialize and log events to Facebook Analytics using [FacebookAppEvents] package

class FacebookAnalyticsService {
  /// Factory constructor to create a singleton instance of [FacebookAnalyticsService]
  factory FacebookAnalyticsService() => _instance;

  /// Internal constructor to create the singleton instance of [FacebookAnalyticsService]
  FacebookAnalyticsService._internal();

  /// Singleton instance of [FacebookAnalyticsService]
  static final FacebookAnalyticsService _instance = FacebookAnalyticsService._internal();

  final FacebookAppEvents _facebookAppEvents = FacebookAppEvents();

  /// Initialize Facebook Analytics
  Future<void> init() async {
    try {
      // Enable auto logging of app events
      await _facebookAppEvents.setAutoLogAppEventsEnabled(true);
      // Setting advertiser tracking on iOS
      await _facebookAppEvents.setAdvertiserTracking(enabled: true);
    } catch (_) {
      debugPrint('Error in initializing Facebook Analytics: $_');
    }
  }

  /// Log an event with [eventName] and [parameters]
  void logEvent(
    String eventName, {
    required Map<String, dynamic> parameters,
  }) {}
}
