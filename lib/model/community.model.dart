// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:gaya/shared/service/dynamic_link_service/enums/dynamic_link_type.dart';
import 'package:gaya/shared/service/dynamic_link_service/model/dynamic_link_type_string.dart';
import 'package:gaya/shared/service/dynamic_link_service/utils/query_param_consts.dart';
import 'package:gaya/view/community/create_community/models/community_theme_model.dart';
import 'package:get/get.dart';

import '../controller/app_config_controller.dart';
import '../utils/const.dart';
import '../utils/theme/app_colors.dart';

class Community implements DynamicLinkTypeString {
  String? communityId;
  String? CommunityPic;
  String? communityDescription;
  String? communityName;
  String? communityType;
  int? communityMembers;
  DateTime? createdon;
  String? coverPicture;
  String? adminUid;
  DateTime? lastPostAt;
  List<String>? moderators;

  Map<String, dynamic>? communityTopics;
  Map<String, dynamic>? moderatorTagData;
  CommunityThemeModel? communityThemeModel;

  // todo we need to apply for loop to convert all 'communityTopics' to List of CommunityTopics
  // List<Map<String, dynamic>>? communityTopicList;
  List<String>? communityTopicList;
  List<String>? pinnedPostList;

  bool? isPostApprovalNeeded;

  /// A variable to see if questionnaire is required to apply to this community
  bool? isCommQNeeded;

  /// A variable to check how much posts are unseen in a community
  int? totalUnseenPosts;

  bool? isArchived;

  Community({
    this.communityId,
    this.CommunityPic,
    this.communityDescription,
    this.communityName,
    this.communityType,
    this.communityMembers,
    this.communityTopics,
    this.createdon,
    this.adminUid,
    this.lastPostAt,
    this.coverPicture,
    this.communityTopicList,
    this.pinnedPostList = const [],
    this.moderatorTagData,
    this.moderators = const [],
    this.communityThemeModel,
    this.isPostApprovalNeeded = false,
    this.isCommQNeeded = false,
    this.totalUnseenPosts = 0,
    this.isArchived = false,
  });

  factory Community.id({required String communityId}) {
    return Community(communityId: communityId);
  }

  factory Community.empty() {
    return Community();
  }

  Community.fromMap(Map<String, dynamic> map, {int? totalUnseenPosts = 0}) {
    if (map.isEmpty) return;
    try {
      communityId = map['communityId'];
      CommunityPic = map['communitypic'];
      communityDescription = map['description'];
      communityName = map['name'];
      communityTopics = map['topics'];
      communityMembers = map['totalmembers'] ?? 0;
      communityType = map['type'];
      coverPicture = map['profilePicture'];
      adminUid = map['adminUid'];
      moderators = map['moderators'] == null ? [] : List<String>.from(map['moderators']);
      pinnedPostList = map['pinnedPostList'] == null ? [] : List<String>.from(map['pinnedPostList']);

      moderatorTagData = map['moderatorTagData'] == null ? moderatorDefaultTag : map['moderatorTagData'] as Map<String, dynamic>;
      communityThemeModel =
          (map['communityThemeModel'] == null) ? null : CommunityThemeModel.fromMap(map['communityThemeModel'] as Map<String, dynamic>);
      lastPostAt = (map['lastPostCreatedAt'] == null) ? null : map['lastPostCreatedAt'].toDate();
      communityTopicList = map['communityTopicList'] == null ? [] : List<String>.from(map['communityTopicList']);
      isPostApprovalNeeded = (map['isPostApprovalNeeded'] == null) ? false : map['isPostApprovalNeeded'];

      /// by default it will be false
      isCommQNeeded = map["isCommQNeeded"] ?? false;
      this.totalUnseenPosts = totalUnseenPosts;
      isArchived = map['isArchived'] ?? false;
    } catch (_) {}
  }

  toPublicJson() => {
        'communityId': communityId,
        'communitypic': CommunityPic,
        'name': communityName,
        'totalmembers': communityMembers,
        'type': communityType,
        'isCommQNeeded': isCommQNeeded,
      };

  Map<String, dynamic> toMap() {
    return {
      'communityId': communityId,
      'communitypic': CommunityPic,
      'description': communityDescription,
      'name': communityName,
      'topics': communityTopics,
      'totalmembers': communityMembers,
      'type': communityType,
      'createdOn': createdon,
      'profilePicture': coverPicture,
      'adminUid': adminUid,
      'communityTopicList': communityTopicList ?? [],
      'pinnedPostList': pinnedPostList ?? [],
      'communityThemeModel': (communityThemeModel == null) ? null : communityThemeModel?.toMap(),
      'isPostApprovalNeeded': isPostApprovalNeeded ?? false,

      /// by default it will false
      'isCommQNeeded': isCommQNeeded ?? false,
    };
  }

  Map<String, dynamic> toUpdateFirestore() {
    return {
      if (communityName.isBlank == false) 'name': communityName,
      'communitypic': CommunityPic,
      'description': communityDescription,
      'topics': communityTopics,
      'totalmembers': communityMembers,
      'type': communityType,
      'profilePicture': coverPicture,
      'adminUid': adminUid,
      'communityTopicList': communityTopicList ?? [],
      'pinnedPostList': pinnedPostList ?? [],
      'communityThemeModel': (communityThemeModel == null) ? null : communityThemeModel?.toMap(),
      'isPostApprovalNeeded': isPostApprovalNeeded ?? false,

      /// by default it will false
      'isCommQNeeded': isCommQNeeded ?? false
    };
  }

  Community updateWith({required Community community}) {
    return Community(
      communityId: community.communityId,
      CommunityPic: community.CommunityPic,
      communityDescription: community.communityDescription,
      communityName: community.communityName,
      communityType: community.communityType,
      communityMembers: community.communityMembers,
      communityTopics: community.communityTopics,
      createdon: community.createdon,
      coverPicture: community.coverPicture,
      adminUid: community.adminUid,
      communityTopicList: community.communityTopicList,
      pinnedPostList: community.pinnedPostList,
      communityThemeModel: community.communityThemeModel,
      moderatorTagData: community.moderatorTagData,
      moderators: community.moderators,
      lastPostAt: community.lastPostAt,
      isPostApprovalNeeded: community.isPostApprovalNeeded ?? false,
      isCommQNeeded: community.isCommQNeeded ?? false,
      totalUnseenPosts: community.totalUnseenPosts ?? 0,
    );
  }

  Community copyWith({
    String? communityId,
    String? CommunityPic,
    String? communityDescription,
    String? communityName,
    String? communityType,
    int? communityMembers,
    Map<String, dynamic>? communityTopics,
    DateTime? createdon,
    String? coverPicture,
    String? adminUid,
    List<String>? communityTopicList,
    List<String>? pinnedPostList,
    CommunityThemeModel? communityThemeModel,
    Map<String, dynamic>? moderatorTagData,
    List<String>? moderators,
    DateTime? lastPostAt,
    bool? isPostApprovalNeeded,
    bool? isCommQNeeded,
    int? totalUnseenPosts,
  }) {
    return Community(
      communityId: communityId ?? this.communityId,
      CommunityPic: CommunityPic ?? this.CommunityPic,
      communityDescription: communityDescription ?? this.communityDescription,
      communityName: communityName ?? this.communityName,
      communityType: communityType ?? this.communityType,
      communityMembers: communityMembers ?? this.communityMembers,
      communityTopics: communityTopics ?? this.communityTopics,
      createdon: createdon ?? this.createdon,
      coverPicture: coverPicture ?? this.coverPicture,
      adminUid: adminUid ?? this.adminUid,
      communityTopicList: communityTopicList ?? this.communityTopicList,
      pinnedPostList: pinnedPostList ?? this.pinnedPostList,
      communityThemeModel: communityThemeModel ?? this.communityThemeModel,
      moderatorTagData: moderatorTagData ?? this.moderatorTagData,
      moderators: moderators ?? this.moderators,
      lastPostAt: lastPostAt ?? this.lastPostAt,
      isPostApprovalNeeded: isPostApprovalNeeded ?? this.isPostApprovalNeeded,
      isCommQNeeded: isCommQNeeded ?? this.isCommQNeeded,
      totalUnseenPosts: totalUnseenPosts ?? this.totalUnseenPosts,
    );
  }

  // convert the algolia map to community model( required id,name,pic,totalMembers,
  Community.fromAlgoliaMap(Map<String, dynamic> map) {
    if (map.isEmpty) return;
    try {
      communityId = map['objectID'];
      CommunityPic = map['communitypic'];
      communityName = map['name'];
      communityMembers = map['totalmembers'] ?? 0;
      communityType = map['type'];
      coverPicture = map['profilePicture'];
      communityDescription = map['description'];
      //TODO: Add cloud function (Algolia to index this variable as-well.
      isCommQNeeded = map['isCommQNeeded'] ?? false;
    } catch (_) {}
  }

  bool get isCommunityPrivate => communityType == "Private" || communityType == "Secret";

  bool get isCommunityPublic => communityType == "Public";

  bool get isCommunitySecret => communityType == "Secret";

  bool get canUserPostDirectly =>
      !(isPostApprovalNeeded ?? false) ||
      (moderators ?? []).contains(FirebaseAuth.instance.currentUser?.uid) ||
      (adminUid == FirebaseAuth.instance.currentUser?.uid);

  @override
  String toString() {
    return 'Community(communityId: $communityId, CommunityPic: $CommunityPic, communityDescription: $communityDescription, communityName: $communityName, communityType: $communityType, communityMembers: $communityMembers, createdon: $createdon, coverPicture: $coverPicture, adminUid: $adminUid, lastPostAt: $lastPostAt, moderators: $moderators, communityTopics: $communityTopics, moderatorTagData: $moderatorTagData, communityTopicList: $communityTopicList, pinnedPostList: $pinnedPostList, isPostApprovalNeeded: $isPostApprovalNeeded, isCommQNeeded: $isCommQNeeded, totalUnseenPosts: $totalUnseenPosts, isArchived: $isArchived)';
  }

  @override
  String get type => DynamicLinkType.shareCommunityProfile.name;

  @override
  String get queryParams =>
      "?${QueryParamConst.id}=$communityId&${QueryParamConst.type}=$type&${QueryParamConst.isPrivate}=$isCommunityPrivate";

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Community && other.communityId == communityId;
  }

  @override
  int get hashCode => communityId.hashCode;
}

Map<String, dynamic>? moderatorDefaultTag = {
  'moderatorTag': 'Moderator',
  'tagColor': 'FF8500D6',
};

extension CommunityExtension on Community {
  // get color from hex color
  Color getThemeColor() {
    if (communityThemeModel?.color != null) {
      return getColorFromHex(communityThemeModel?.color ?? 'FFD28AFF');
    }
    return communityThemeModelOrDefault().toColor;
  }

  CommunityThemeModel communityThemeModelOrDefault() {
    return communityThemeModel ?? CommunityThemeModel.defaultTheme();
  }

  Color get moderatorTagColorOrDefault =>
      moderatorTagData?['tagColor'] != null ? getColorFromHex(moderatorTagData?['tagColor']) : AppColors.chipLightPink;
}

class Questionnaire {
  final String _fieldQuestion = "question";
  late String question;

  Questionnaire({required this.question});

  Questionnaire.fromMap(Map<String, dynamic> map) {
    question = map[_fieldQuestion];
  }

  Map<String, dynamic> toMap() {
    return {_fieldQuestion: question};
  }
}

extension CommunityHelpers on Community {
  bool get isAdmin => adminUid == FirebaseAuth.instance.currentUser?.uid && adminUid != null || AppConfigurationController.to.isSuperAdmin;

  /// return null, if user is not moderator, logic on FEED TILES
  bool get isModeratorOrAdmin => (moderators ?? []).contains(FirebaseAuth.instance.currentUser?.uid) || isAdmin;

  bool get isArchive => isArchived == true;
}
