import 'package:cloud_firestore/cloud_firestore.dart' show QuerySnapshot;
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:gaya/utils/language/translation.dart';
import 'package:get/get.dart';

import '../../../../model/community_analytics.dart';
import '../services/community_analytics_firestore_service.dart';

class CommunityAnalyticsController extends GetxController {
  /// static getter to get instance of CommunityAnalyticsController
  static CommunityAnalyticsController get instance => Get.find();

  /* -------------------------------------------------------------------------- */
  /*                               STATE VARIABLES                              */
  /* -------------------------------------------------------------------------- */
  /// boolean variable for loaders
  bool isLoading = false;

  /// index of the analytics timeline (0 = day, 1 = week, 2 = month, 3 = year)
  int? tabIndex = 0;

  /// id of the opened community
  String? communityId;

  /// communityAnalytics instance to show data on the screen
  CommunityAnalytics? communityAnalytics;

  /* -------------------------------------------------------------------------- */
  /*                                 MAIN API'S                                 */
  /* -------------------------------------------------------------------------- */
  /// invoke to change timeline tab bar index using [index]
  void changeTimelineTabBarTab(int? index) {
    tabIndex = index;
    // invoking fetch community analytics for analytics fetching
    fetchCommunityAnalytics();
    update();
  }

  /// invoke to fetch community analytics with [communityID]
  Future<void> fetchCommunityAnalytics() async {
    // starting loader
    _startLoader();

    try {
      // fetching analytics data
      final results = await Future.wait([
        _getCommunityMembersCount(),
        _getCommunityLikesCount(),
        _getCommunityPostsCount(),
        _getCommunityCrownsCount(),
        _getCommunityViewsCount(),
        _getCommunityCommentsCount(),
        _getCommunityCommonKeywords(),
      ]);

      // fetching previous analytics data for comparison
      final oldResults = await Future.wait([
        _getOldCommunityPostsCount(),
      ]);

      // returning CommunityAnalytics instance
      communityAnalytics = CommunityAnalytics(
        members: results[0] as int,
        likes: results[1] as int,
        likesComparisonPercentage: 0.0,
        posts: results[2] as int,
        postsComparisonPercentage: _getComparisonPercentage(
          currentValue: results[2] as int,
          previousValue: oldResults[0] == 0 ? 1 : oldResults[0],
        ),
        crowns: results[3] as int,
        crownsComparisonPercentage: 0.0,
        views: results[4] as int,
        viewsComparisonPercentage: 0.0,
        comments: results[5] as int,
        commentsComparisonPercentage: 0.0,
        commonKeywords: results[6] as List<String>,
        mostActiveUser: null,
      );
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      // stopping the loader
      _stopLoader();
    }
  }

  /// invoke to get community members count of a selected timeline
  Future<int> _getCommunityMembersCount() async {
    try {
      // getting ending time dateTime list according to
      // selected timeline tab
      List<DateTime> startingAndEndTimeStrings = _getStartAndEndTimeByTimeline();
      // time where to start checking
      DateTime startingTime = startingAndEndTimeStrings[0];
      // time where to end checking
      DateTime endingTime = startingAndEndTimeStrings[1];

      // querying community members according to [startingTime] and [endingTime]
      QuerySnapshot<Map<String, dynamic>> communityMembersQuerySnapshot =
          await CommunityAnalyticsFirestoreService.instance.getCommunityMembersViaTime(
        communityId: communityId!,
        startingTime: startingTime,
        endingTime: endingTime,
      );

      return communityMembersQuerySnapshot.docs.length;
    } catch (e) {
      debugPrint(e.toString());
      return 0;
    }
  }

  /// invoke to get posts count of a selected timeline
  Future<int> _getCommunityPostsCount() async {
    try {
      // getting ending time dateTime list according to
      // selected timeline tab
      List<DateTime> startingAndEndDateTimeList = _getStartAndEndTimeByTimeline();
      // time where to start checking
      DateTime startingTime = startingAndEndDateTimeList[0];
      // time where to end checking
      DateTime endingTime = startingAndEndDateTimeList[1];

      // querying community posts according to [startingTime] and [endingTime]
      QuerySnapshot<Map<String, dynamic>> communityPostsQuerySnapshot =
          await CommunityAnalyticsFirestoreService.instance.getCommunityPostsViaTime(
        communityId: communityId!,
        startingTime: startingTime,
        endingTime: endingTime,
      );

      return communityPostsQuerySnapshot.docs.length;
    } catch (e) {
      debugPrint(e.toString());
      return 0;
    }
  }

  /// invoke to get old posts count of a selected timeline
  Future<int> _getOldCommunityPostsCount() async {
    try {
      // getting ending time dateTime list according to
      // selected timeline tab
      List<DateTime> startingAndEndDateTimeList = _getComparisonStartAndEndTimeByTimeline();
      // time where to start checking
      DateTime startingTime = startingAndEndDateTimeList[0];
      // time where to end checking
      DateTime endingTime = startingAndEndDateTimeList[1];

      // querying community posts according to [startingTime] and [endingTime]
      QuerySnapshot<Map<String, dynamic>> communityPostsQuerySnapshot =
          await CommunityAnalyticsFirestoreService.instance.getCommunityPostsViaTime(
        communityId: communityId!,
        startingTime: startingTime,
        endingTime: endingTime,
      );

      return communityPostsQuerySnapshot.docs.length;
    } catch (e) {
      debugPrint(e.toString());
      return 0;
    }
  }

  /// invoke to get community likes count of a selected timeline
  Future<int> _getCommunityLikesCount() async {
    return Future.delayed(
      const Duration(seconds: 1),
      () => 0,
    );
  }

  /// invoke to get community crows count of a selected timeline
  Future<int> _getCommunityCrownsCount() async {
    return Future.delayed(
      const Duration(seconds: 1),
      () => 0,
    );
  }

  /// invoke to get community views count of a selected timeline
  Future<int> _getCommunityViewsCount() async {
    return Future.delayed(
      const Duration(seconds: 1),
      () => 0,
    );
  }

  /// invoke to get community comments count of a selected timeline
  Future<int> _getCommunityCommentsCount() async {
    return Future.delayed(
      const Duration(seconds: 1),
      () => 0,
    );
  }

  /// invoke to get community common keyword
  Future<List<String>> _getCommunityCommonKeywords() async {
    return Future.delayed(
      const Duration(seconds: 1),
      () => [],
    );
  }

  /* -------------------------------------------------------------------------- */
  /*                                HELPER API'S                                */
  /* -------------------------------------------------------------------------- */
  /// invoke to start the loader
  void _startLoader() {
    isLoading = true;
    update();
  }

  /// invoke to stop the loader
  void _stopLoader() {
    isLoading = false;
    update();
  }

  /// invoke to get time duration to show on tiles according to selected time
  String getTimeDuration() {
    switch (tabIndex) {
      case 0:
        return GayaStrings.vsYesterday.tr;
      case 1:
        return GayaStrings.vsLastWeek.tr;
      case 2:
        return GayaStrings.vsLastMonth.tr;
      case 3:
        return GayaStrings.vsLastYear.tr;
      default:
        return GayaStrings.vsYesterday.tr;
    }
  }

  /// invoke to get starting and ending time
  /// according to selected timeline (e.g day, week, month, year)
  List<DateTime> _getStartAndEndTimeByTimeline() {
    // current date and time instance
    DateTime now = DateTime.now();

    // start and ending time for query on the basis of time
    DateTime? startingTime;
    DateTime? endingTime;

    if (tabIndex == 0) {
      /* ----------------------- if user selected today tab ----------------------- */
      // starting time in DateTime
      startingTime = DateTime(now.year, now.month, now.day);
      // ending time in DateTime
      endingTime = DateTime(now.year, now.month, now.day, 23, 59, 59);
    } else if (tabIndex == 1) {
      /* ------------------------ if user selected week tab ----------------------- */
      // starting week day
      int daysToStartOfWeek = now.weekday % 7;
      // starting time in DateTime
      startingTime = DateTime(now.year, now.month, now.day).subtract(
        Duration(days: daysToStartOfWeek),
      );
      // ending time in DateTime
      endingTime = startingTime.add(
        const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
      );
    } else if (tabIndex == 2) {
      /* ----------------------- if user selected month tab ----------------------- */
      // starting time in DateTime
      startingTime = DateTime(now.year, now.month, 1);
      // ending time in DateTime
      endingTime = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    } else if (tabIndex == 3) {
      /* ------------------------ if user selected year tab ----------------------- */
      // starting time in DateTime
      startingTime = DateTime(now.year, 1, 1);
      // ending time in DateTime
      endingTime = DateTime(now.year, 12, 31, 23, 59, 59);
    }

    return [startingTime!, endingTime!];
  }

  /// invoke to get previous starting and ending time according to selected timeline
  /// (e.g previous day, previous week, previous month, previous year)
  List<DateTime> _getComparisonStartAndEndTimeByTimeline() {
    // current date and time instance
    DateTime now = DateTime.now();

    // start and ending time for query on the basis of time
    DateTime? startingTime;
    DateTime? endingTime;

    if (tabIndex == 0) {
      /* ----------------------- if user selected today tab ----------------------- */
      // starting time in DateTime
      startingTime = DateTime(now.year, now.month, now.day - 1);
      // ending time in DateTime
      endingTime = DateTime(now.year, now.month, now.day - 1, 23, 59, 59);
    } else if (tabIndex == 1) {
      /* ------------------------ if user selected week tab ----------------------- */
      // starting last week day
      int daysToStartOfLastWeek = now.weekday % 7 + 7;
      // starting time in DateTime
      startingTime = DateTime(now.year, now.month, now.day).subtract(
        Duration(days: daysToStartOfLastWeek),
      );
      // ending time in DateTime
      endingTime = startingTime.add(
        const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
      );
    } else if (tabIndex == 2) {
      /* ----------------------- if user selected month tab ----------------------- */
      // starting time in DateTime
      startingTime = DateTime(now.year, now.month - 1, 1);
      // ending time in DateTime
      endingTime = DateTime(now.year, now.month, 0, 23, 59, 59);
    } else if (tabIndex == 3) {
      /* ------------------------ if user selected year tab ----------------------- */
      // starting time in DateTime
      startingTime = DateTime(now.year - 1, 1, 1);
      // ending time in DateTime
      endingTime = DateTime(now.year - 1, 12, 31, 23, 59, 59);
    }

    return [startingTime!, endingTime!];
  }

  /// invoke to get comparison percentage
  double _getComparisonPercentage({
    required int currentValue, // 3
    required int previousValue, // 1
  }) =>
      currentValue == 0 && previousValue == 1 ? 0.0 : ((currentValue - previousValue) / previousValue) * 100;
}
