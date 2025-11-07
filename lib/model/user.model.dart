import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/model/topic.model.dart';
import 'package:gaya/shared/service/dynamic_link_service/utils/query_param_consts.dart';
import 'package:gaya/utils/assets_icons.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/logger.dart';
import 'package:get/get.dart';

import '../shared/service/dynamic_link_service/enums/dynamic_link_type.dart';
import '../shared/service/dynamic_link_service/model/dynamic_link_type_string.dart';

class UserModel extends GetxService implements DynamicLinkTypeString {
  static UserModel get to => Get.find();

  update(UserModel? user) {
    if (user == null) return;
    bio = user.bio;
    coverPhoto = user.coverPhoto;
    email = user.email;
    interests = user.interests;
    name = user.name;
    profilePicture = user.profilePicture;
    uId = user.uId ?? FirebaseAuth.instance.currentUser?.uid;
    fm_token = user.fm_token;
    admin = user.admin;
    allowToDm = user.allowToDm;
    phoneNumber = user.phoneNumber;
    createdOn = user.createdOn;
    isActive = user.isActive;
    dob = user.dob;
    gender = user.gender;
    userDailyCrowns = user.userDailyCrowns;
    userTotalCrowns = user.userTotalCrowns;
    totalScore = user.totalScore;
    influenceScore = user.influenceScore;
    dailyCrownRewardInfluencePoints = user.dailyCrownRewardInfluencePoints;
    dailyProfileComplimentInfluencePoints = user.dailyProfileComplimentInfluencePoints;
    streakDaysCount = user.streakDaysCount;
    lastVisitDate = user.lastVisitDate;
    debugPrint('UserModel updated ${user.dob}');
  }

  String? bio;
  String? coverPhoto;
  String? email;
  List<TopicsModel>? interests;
  String? name;
  String? profilePicture;
  String? uId;
  String? fm_token;
  bool? admin;
  bool? allowToDm;
  String? phoneNumber;
  DateTime? createdOn;
  DateTime? dob;
  String? gender;

  /// Whether the user is blocked or not, using this variable to check if the user is blocked or not
  bool? isActive;

  int? userTotalCrowns;
  int? userDailyCrowns;

  int? totalScore;
  double? influenceScore;
  double? dailyCrownRewardInfluencePoints;
  double? dailyProfileComplimentInfluencePoints;

  int? streakDaysCount;
  DateTime? lastVisitDate;

  // UserCrownsModel? userCrownsModel;

  UserModel({
    this.bio,
    this.coverPhoto,
    this.email,
    this.interests = const [],
    this.name,
    this.profilePicture,
    this.uId,
    this.fm_token,
    this.admin,
    this.allowToDm,
    this.phoneNumber,
    this.createdOn,
    this.dob,
    this.gender,
    this.isActive,
    this.userDailyCrowns,
    this.userTotalCrowns,
    this.totalScore,
    this.influenceScore,
    this.dailyCrownRewardInfluencePoints,
    this.dailyProfileComplimentInfluencePoints,
    this.streakDaysCount,
    this.lastVisitDate,
  });

//used for public post or any activity
  toPublicJson({bool shouldHaveEmail = true}) {
    Map<String, dynamic> map = {
      'name': name,
      'profilePic': profilePicture,
      'uid': uId ?? FirebaseAuth.instance.currentUser?.uid,
      'gender': gender,
    };
    if (shouldHaveEmail) {
      map.addAll({'email': email});
    }
    return map;
  }

  UserModel.fromSnapshot(DocumentSnapshot snapshot) : this.fromMap(snapshot.data() as Map<String, dynamic>, userId: snapshot.reference.id);

  UserModel.fromMap(Map<String, dynamic> map, {String? userId}) {
    bio = map['bio'] ?? "  ";
    coverPhoto = map['coverphoto'];
    email = map['email'];
    name = map['name'] ?? "User";
    profilePicture = map['profilePic'];
    fm_token = map['fm_token'];
    uId = userId ?? map['uid'];
    admin = map['isAdmin'];
    allowToDm = map['allowToDm'] ?? true;
    phoneNumber = map['phoneNumber'];
    isActive = map['isActive'];
    dob = map["dob"] is String
        ? map["dob"].toString().isEmpty
            ? null
            : DateTime.tryParse(map["dob"])
        : map["dob"] is Timestamp
            ? map["dob"].toDate()
            : null;

    gender = map["gender"];
    // createdOn = map['createdOn'];
    userDailyCrowns = map["userDailyCrowns"] ?? 0;
    userTotalCrowns = map["userTotalCrowns"] ?? 0;
    totalScore = map["totalScore"] ?? 0;
    influenceScore = (map["influenceScore"] != null) ? map["influenceScore"].toDouble() : 0.0;
    dailyCrownRewardInfluencePoints =
        (map["dailyCrownRewardInfluencePoints"] != null) ? map["dailyCrownRewardInfluencePoints"].toDouble() : 0.0;
    dailyProfileComplimentInfluencePoints =
        (map["dailyProfileComplimentInfluencePoints"] != null) ? map["dailyProfileComplimentInfluencePoints"].toDouble() : 0.0;
    streakDaysCount = map["streakDaysCount"];
    lastVisitDate = (map["lastVisitDate"] == null) ? null : DateTime.fromMillisecondsSinceEpoch(map["lastVisitDate"]);
    // userCrownsModel = (map['userCrownsModel'] == null) ? null : UserCrownsModel.fromMap(map['userCrownModel'] as Map<String, dynamic>);
    if (map['interests'] != null) {
      interests = <TopicsModel>[];
      List<String> topicNames = map['interests'].map<String>((e) => e["title"].toString().toLowerCase()).toList();

      /// make a new list of topics from the list of topic names
      /// and assign it to the interests list
      /// This case is for the user who has already created an account and they don't have  icon in their interests
      final data = topicsList.where((element) => topicNames.contains(element.title.toLowerCase())).toList();
      interests = data;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'bio': bio,
      'coverphoto': coverPhoto,
      'email': email,
      'name': name,
      'profilePic': profilePicture,
      'uid': uId,
      'fm_token': fm_token,
      'interests': interests ?? [],
      'admin': admin,
      'allowToDm': allowToDm ?? true,
      'phoneNumber': phoneNumber,
      'isActive': isActive,
      'dob': dob,
      'gender': gender,
      'userTotalCrowns': userTotalCrowns ?? 0,
      'userDailyCrowns': userDailyCrowns ?? 0,
      'streakDaysCount': streakDaysCount,
      'lastVisitDate': lastVisitDate?.millisecondsSinceEpoch,
      // 'userCrownsModel': (userCrownsModel == null) ? null : userCrownsModel?.toMap()
      // 'userCreatedOn' : createdOn,
    };
  }

  // to copyWith mehto
  UserModel copyWith({
    String? bio,
    String? coverPhoto,
    String? email,
    List<TopicsModel>? interests,
    String? name,
    String? profilePicture,
    String? uId,
    String? gender,
    DateTime? dob,
    String? phoneNumber,
    bool ismoderator = false,
    int? userTotalCrowns,
    int? userDailyCrowns,
    bool? allowToDm,
    int? totalScore,
    double? influenceScore,
    double? dailyCrownRewardInfluencePoints,
    double? dailyProfileComplimentInfluencePoints,
    int? streakDaysCount,
    DateTime? lastVisitDate,

    // UserCrownsModel? userCrownsModel,
  }) {
    return UserModel(
      bio: bio ?? this.bio,
      coverPhoto: coverPhoto ?? this.coverPhoto,
      interests: interests ?? this.interests ?? [],
      name: name ?? this.name,
      profilePicture: profilePicture ?? this.profilePicture,
      uId: uId ?? this.uId,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      userDailyCrowns: userDailyCrowns,
      userTotalCrowns: userTotalCrowns,
      allowToDm: allowToDm ?? this.allowToDm,
      totalScore: totalScore ?? this.totalScore,
      influenceScore: influenceScore ?? this.influenceScore,
      dailyCrownRewardInfluencePoints: dailyCrownRewardInfluencePoints ?? this.dailyCrownRewardInfluencePoints,
      dailyProfileComplimentInfluencePoints: dailyProfileComplimentInfluencePoints ?? this.dailyProfileComplimentInfluencePoints,
      streakDaysCount: streakDaysCount ?? this.streakDaysCount,
      lastVisitDate: lastVisitDate ?? this.lastVisitDate,
    );

    // userCrownsModel: (userCrownsModel == null)
    //     ? null
    //     : userCrownsModel.copyWith(userDailyCrowns: userCrownsModel.userDailyCrowns, userTotalCrowns: userCrownsModel.userTotalCrowns)
  }

  /// increaments total crowns
  UserModel updateCrown({bool shouldIncreament = false}) {
    MyLoggerServices.to
        .print("should increment $shouldIncreament and ${shouldIncreament ? (userTotalCrowns ?? 0) + 1 : (userTotalCrowns ?? 1) - 1}");
    return copyWith(userTotalCrowns: shouldIncreament ? (userTotalCrowns ?? 0) + 1 : (userTotalCrowns ?? 1) - 1);
  }

  // convert the algolia map to userModel ( we need just id,name,profilePicture)
  UserModel.fromAlgoliaMap(Map<String, dynamic> map) {
    try {
      uId = map['objectID'];
      name = map['name'].toString().capitalizeFirst;
      email = map['email'];
      profilePicture = map['profilePic'];
      coverPhoto = map['coverphoto'];
      phoneNumber = map['phoneNumber'];
      isActive = map['isActive'];
      bio = map['bio'];
    } catch (_) {}
  }

  void logOut() {
    update(UserModel());
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel && other.uId == uId;
  }

  String get userName => (name ?? "User").length > 20 ? "${(name ?? "User").substring(0, 20)}..." : name ?? "User";

  bool get isUserNameExists => name.isBlank == false;

  @override
  String get type => DynamicLinkType.userProfile.name;

  @override
  String get queryParams => "?${QueryParamConst.id}=$uId&${QueryParamConst.type}=$type";

  @override
  int get hashCode => uId.hashCode;
}

extension ParsingDateTime on DateTime {
  tryParseDate() {
    try {
      return DateTime.parse(toString());
    } catch (_) {
      return "";
    }
  }
}

class UserScoring {
  int? posts, comments, likes, followers, following, total;
}

extension UserModelExtension on UserModel {
  String dobAndGender() {
    return "${_isValidGender() ? "${gender?.capitalizeFirst ?? ""}," : ""} ${calculateAge != null ? "$calculateAge years old" : ""}";
  }

  bool _isValidGender() {
    return gender?.toLowerCase() == "male" || gender?.toLowerCase() == "female";
  }

  int? get calculateAge {
    if (dob == null) return null;
    final now = DateTime.now();
    final age = now.year - dob!.year;

    if (age > 0) {
      return age;
    }
    return null;
  }

  // check user is allowed to DM based on influence points < 40 or not
  bool get isUserAllowedToDM => (userInfluenceScoreWithCrowns < 40) ? false : true;

  // check and get influence widget according to user percentage points
  Widget get getUserInfluencePointsIndicator {
    return getInfluencePercentageIndicator(userInfluenceScoreWithCrowns);
  }
}

extension InfluenceBarExtension on UserModel {
  // check influence points validity
  bool get isUserInfluencePointsValid =>
      (influenceScore != null && userTotalCrowns != null && userInfluenceScoreWithCrowns > 20) ? true : false;

  // get user influence score 15 incase of 0 or negative or null
  int get userInfluenceScore => (influenceScore ?? 0) <= 0 ? 0 : influenceScore!.round();

  // get user influence score + Crowns x 0.25 incase of 0 or negative or null
  int get userInfluenceScoreWithCrowns =>
      (((influenceScore == null || influenceScore?.isNegative == true) ? 0 : influenceScore ?? 0) + (userTotalCrowns ?? 0)) <= 0
          ? 0
          : ((influenceScore?.isNegative == true) ? 0 : influenceScore!.round()) + ((userTotalCrowns ?? 0) * 0.25).round();

  // check user's influence scroe is less than or equal to 20
  bool isUserInfluenceScoreLessThanOrEqualTo20(int score) {
    return score <= 20;
  }

  // check score is between 20 and 40
  bool isUserInfluenceScoreBetween20And40(int score) {
    return score > 20 && score < 40;
  }

  // check user's influence scroe is >= 40 and < 50
  bool isUserInfluenceScoreBetween40And50(int score) {
    return score >= 40 && score < 50;
  }

  // check user's influence scroe is >= 50 and < 60
  bool isUserInfluenceScoreBetween50And60(int score) {
    return score >= 50 && score < 60;
  }

  // check user's influence scroe is >= 60 and < 70
  bool isUserInfluenceScoreBetween60And70(int score) {
    return score >= 60 && score < 70;
  }

  // check user's influence scroe is >= 70 and < 80
  bool isUserInfluenceScoreBetween70And80(int score) {
    return score >= 70 && score < 80;
  }

  // check user's influence scroe is >= 80 and < 90
  bool isUserInfluenceScoreBetween80And90(int score) {
    return score >= 80 && score < 90;
  }

  // check user's influence scroe is >= 90
  bool isUserInfluenceScoreGreaterThanOrEqualTo90(int score) {
    return score >= 90;
  }

  // check user's influence scroe is less than 90 ?
  bool isUserInfluenceScoreLessThan90(int score) {
    return score < 90;
  }

  // check user's influence score > 100
  bool isUserInfluenceScoreGreaterThan100(int score) {
    return score > 100;
  }

  // check user's score is or under 15 and 80
  bool isUserInfluenceScoreBetween15And80(int score) {
    return score >= 15 && score <= 80;
  }

  // check user's score >= 60
  bool isUserInfluenceScoreGreaterThanOrEqualTo60(int score) {
    return score >= 60;
  }

  // check user's scor < 60
  bool isUserInfluenceScoreLessThan60(int score) {
    return score < 60;
  }

  //check user's score >= 15 and < 90
  bool isUserInfluenceScoreBetween15And90(int score) {
    return score >= 15 && score < 90;
  }

  // check and get influence widget according to user percentage points
  Widget getInfluencePercentageIndicator(int score) {
    Widget influenceIconWidget = SvgIconWidget.closeRed;
    if (isUserInfluenceScoreLessThanOrEqualTo20(score)) {
      influenceIconWidget = SvgIconWidget.closeRed;
    } else if (isUserInfluenceScoreBetween20And40(score)) {
      influenceIconWidget = SvgIconWidget.emojiYellow;
    } else if (isUserInfluenceScoreBetween40And50(score)) {
      influenceIconWidget = SvgIconWidget.emojiBlue;
    } else if (isUserInfluenceScoreBetween50And60(score)) {
      influenceIconWidget = SvgIconWidget.tickBlue;
    } else if (isUserInfluenceScoreBetween60And70(score)) {
      influenceIconWidget = SvgIconWidget.tickGreen;
    } else if (isUserInfluenceScoreBetween70And80(score)) {
      influenceIconWidget = SvgIconWidget.tickGreen;
    } else if (isUserInfluenceScoreBetween80And90(score)) {
      influenceIconWidget = SvgIconWidget.tickGreen;
    } else if (isUserInfluenceScoreGreaterThanOrEqualTo90(score)) {
      influenceIconWidget = SvgIconWidget.heartPrimary;
    }
    return SizedBox(height: 13.r, width: 13.r, child: influenceIconWidget);
  }
}

extension UserStreakExtension on UserModel {
  // check user streak days count validity
  bool get isUserStreakValid => (streakDaysCount ?? 0) > 0 ? true : false;

  // user Continues Streak Days
  int get userContinuesStreakDays {
    if (!isUserStreakValid) return 0;
    return streakDaysCount ?? 0;
  }

  // user remaining Streak Days
  int get userRemainingStreakDays {
    if (!isUserStreakValid) return 3;
    return getUserRemainingStreakDaysCount(streakDaysCount ?? 0);
  }

  // calculate user remaining streak days count method
  int getUserRemainingStreakDaysCount(int daysCount) {
    if (daysCount <= 0) {
      return 3;
    } else if (daysCount < 3) {
      return (3 - daysCount);
    } else if (daysCount < 7) {
      return (7 - daysCount);
    } else if (daysCount < 30) {
      return (30 - daysCount);
    } else if (daysCount < 90) {
      return (90 - daysCount);
    } else {
      return 0;
    }
  }

  // get user streak percentage
  int get userStreakPercentage => (userContinuesStreakDays > 0) ? getUserStreakPercentage(streakDaysCount ?? 0).round() : 0;

  // calculate user streak percentage method
  int getUserStreakPercentage(int daysCount) {
    if (daysCount <= 0) {
      return 0;
    }
    int percentage = ((userContinuesStreakDays / userOngoingStreakTotalDays) * 100).round();

    if (percentage < 0) {
      return 0;
    }
    if (percentage > 100) {
      return 100;
    }
    return percentage;
  }

  // check user ongoing streak
  int get userOngoingStreakTotalDays {
    if (!isUserStreakValid) {
      return 3;
    } else if (streakDaysCount == null || streakDaysCount == 0 || (streakDaysCount ?? 0) < 3) {
      return 3;
    } else if (streakDaysCount! < 7) {
      return 7;
    } else if (streakDaysCount! < 30) {
      return 30;
    } else if (streakDaysCount! > 30) {
      return 90;
    } else {
      return 3;
    }
  }

  // check user ongoing streak is 3 days
  bool isUserOnThreeDaysStreak(int streakCount) {
    return (streakCount < 3) ? true : false;
  }

  // check user ongoing streak is 7 days
  bool isUserOnSevenDaysStreak(int streakCount) {
    return (streakCount < 7) ? true : false;
  }

  // check user ongoing streak is 30 days
  bool isUserOnThirtyDaysStreak(int streakCount) {
    return (streakCount < 30) ? true : false;
  }

  // check user ongoing streak is 90 days
  bool isUserOnNinetyDaysStreak(int streakCount) {
    return (streakCount >= 30) ? true : false;
  }

  // get continue streak days count according to singular/plural days count
  String get getContinuesStreakDaysAccordingToSingularPlugarCount {
    int daysCount = userContinuesStreakDays;
    return (daysCount == 1)
        ? "$daysCount ${GayaStrings.day_of_activity_in_a_row_txt.tr}"
        : "$daysCount ${GayaStrings.days_of_activity_in_a_row_txt.tr}";
  }

  // get remaining streak days count according to singular/plural days count
  String get getRemainingStreakDaysAccordingToSingularPlugarCount {
    int daysCount = userRemainingStreakDays;
    return (daysCount == 1)
        ? "$daysCount ${GayaStrings.more_day_to_get_your_streak_tag_txt.tr}"
        : "$daysCount ${GayaStrings.more_days_to_get_your_streak_tag_txt.tr}";
  }
}
