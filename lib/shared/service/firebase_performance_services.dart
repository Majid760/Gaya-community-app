import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';

class PerformanceServices {
  final splashTrace = FirebasePerformance.instance.newTrace('load_post_time');
  final loginTrace = FirebasePerformance.instance.newTrace('login_screen_load_time');
  final registerTrace = FirebasePerformance.instance.newTrace('register_screen_load_time');
  final communityTrace = FirebasePerformance.instance.newTrace('community_screen_load_time');
  final communitiesTrace = FirebasePerformance.instance.newTrace('communities_view_screen_load_time');
  final userTrace = FirebasePerformance.instance.newTrace('user_profile_view_screen_load_time');
  final feedTrace = FirebasePerformance.instance.newTrace('feed_load_time');
  final communityFeedTrace = FirebasePerformance.instance.newTrace('community_feed_load_time');
  final postTrace = FirebasePerformance.instance.newTrace('load_post_time');
  final commentTrace = FirebasePerformance.instance.newTrace('load_comments_time');

  static Future<void> init() async {
    if (kIsWeb || kDebugMode) return;
    try {
      await FirebasePerformance.instance.setPerformanceCollectionEnabled(true);
    } catch (_) {}
  }

  Future<void> startSplashLoadTime() async {
    if (kIsWeb || kDebugMode) return;
    await splashTrace.start();
  }

  Future<void> stopSplashLoadTime() async {
    if (kIsWeb || kDebugMode) return;
    await splashTrace.stop();
  }

  Future<void> startLoginLoadTime() async {
    if (kIsWeb || kDebugMode) return;
    await loginTrace.start();
  }

  Future<void> stopLoginLoadTime() async {
    if (kIsWeb || kDebugMode) return;
    await loginTrace.stop();
  }

  Future<void> startRegisterLoadTime() async {
    if (kIsWeb || kDebugMode) return;
    await registerTrace.start();
  }

  Future<void> stopRegisterLoadTime() async {
    if (kIsWeb || kDebugMode) return;
    await registerTrace.stop();
  }

  Future<void> startHomeFeedLoadTime() async {
    if (kIsWeb || kDebugMode) return;
    await feedTrace.start();
  }

  Future<void> stopHomeFeedLoadTime() async {
    if (kIsWeb || kDebugMode) return;
    await feedTrace.stop();
  }

  Future<void> startCommunitiesViewLoadTime() async {
    if (kIsWeb || kDebugMode) return;
    await communitiesTrace.start();
  }

  Future<void> stopCommunitiesViewLoadTime() async {
    if (kIsWeb || kDebugMode) return;
    await communitiesTrace.stop();
  }

  Future<void> startCommunityLoadTime() async {
    if (kIsWeb || kDebugMode) return;
    await communityTrace.start();
  }

  Future<void> stopCommunityLoadTime() async {
    if (kIsWeb || kDebugMode) return;
    await communityTrace.stop();
  }

  Future<void> startCommunityFeedLoadTime() async {
    if (kIsWeb || kDebugMode) return;
    await communityFeedTrace.start();
  }

  Future<void> stopCommunityFeedLoadTime() async {
    if (kIsWeb || kDebugMode) return;
    await communityFeedTrace.stop();
  }

  Future<void> startLoadPostTime() async {
    if (kIsWeb || kDebugMode) return;
    await postTrace.start();
  }

  Future<void> stopLoadPostTime() async {
    if (kIsWeb || kDebugMode) return;
    await postTrace.stop();
  }

  Future<void> startUserProfileViewLoadTime() async {
    if (kIsWeb || kDebugMode) return;
    await userTrace.start();
  }

  Future<void> stopUserProfileViewLoadTime() async {
    if (kIsWeb || kDebugMode) return;
    await userTrace.stop();
  }

  Future<void> startLoadCommentsTime() async {
    if (kIsWeb || kDebugMode) return;
    await commentTrace.start();
  }

  Future<void> stopLoadCommentsTime() async {
    if (kIsWeb || kDebugMode) return;
    await commentTrace.stop();
  }
}
