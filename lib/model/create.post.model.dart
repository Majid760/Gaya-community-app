import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:gaya/model/community.model.dart';
import 'package:gaya/model/postType.model.dart';
import 'package:gaya/model/reaction_model.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/shared/service/dynamic_link_service/enums/dynamic_link_type.dart';
import 'package:gaya/shared/service/dynamic_link_service/model/dynamic_link_type_string.dart';
import 'package:gaya/utils/enum.dart';
import 'package:gaya/view/comments/models/comment_custom_model.dart';
import 'package:gaya/view/create_post/models/post_poll_model.dart';
import 'package:get/get.dart';

import '../shared/service/dynamic_link_service/utils/query_param_consts.dart';

/// [postedBy] and [community] are required and initialised as late.
class Post implements DynamicLinkTypeString {
  late UserModel postedBy;
  late Community community;
  String? communityId;
  String? postDescription;
  String? memberId;
  String? postid;
  String? postPicture;
  DateTime? postCreatedOn;
  String? totaltime;
  bool? approve;
  bool? isPostedAnonymously;
  bool? isDeleted;
  String? totalCommentsCount;
  List<String>? likedBy;
  List<String>? crownsBy;
  List<dynamic>? multipleImages;
  String? video;
  DateTime? approvedAt;
  List<String>? postTopicList;
  bool? isPinned;
  List<Map<String, dynamic>>? pdfFiles;

  PostType? postTypeData;
  Map<String, dynamic>? postReplyVibeData;

  // Reaction parameters
  ReactionModel? reactionModel;
  PostReactionDataModel? postReactionData;

  // Recent comments
  List<CommentCustomModel?>? recentComments;

  //for post poll
  PostPollModel? postPollModel;

  /// This is for guest feed
  /// if true, then it is guest feed so we will not show time for it.
  bool? forGuestFeed;

  Post({
    required this.postedBy,
    required this.community,
    this.communityId,
    this.likedBy = const [],
    this.crownsBy = const [],
    this.postDescription,
    this.memberId,
    this.postPicture,
    this.postCreatedOn,
    this.totaltime,
    this.approve,
    this.isDeleted,
    this.postid,
    this.isPostedAnonymously,
    this.multipleImages,
    this.totalCommentsCount = "0",
    this.video,
    this.pdfFiles = const [],
    this.approvedAt,
    this.postTopicList,
    this.isPinned = false,
    this.reactionModel,
    this.postPollModel,
    this.postReactionData,
    this.recentComments,
    this.postTypeData,
    this.postReplyVibeData,
    this.forGuestFeed = false,
  });

//for getting the data
  Post.fromMap(Map<String, dynamic> map, {bool? isForGuest}) {
    try {
      totalCommentsCount = map['totalCommentsCount']?.toString() ?? "0";
      postedBy = UserModel.fromMap(map['postedBy']);
      community = Community.fromMap(map['community']);
      likedBy = map['likedBy'] == null ? [] : List<String>.from(map['likedBy']);
      crownsBy = map['crownsBy'] == null ? [] : List<String>.from(map['crownsBy']);

      communityId = map['communityId'];
      postDescription = map['postDescription'];
      memberId = map['memberId'];
      postPicture = map['postPicture'];
      // preparationTime = map['preparationTime'];
      postCreatedOn = map['createdOn'] != null ? (map['createdOn'] as Timestamp).toDate() : null;
      // totaltime = map['totalTime'];
      postid = map['postId'];
      approve = map['approve'];
      isPinned = map['isPinned'] ?? false;

      isDeleted = map["isDeleted"];
      isPostedAnonymously = map['isPostedAnonymously'];
      multipleImages = map['multipleImages'];
      video = map['video'];
      reactionModel = map['reactionModel'] == null ? null : ReactionModel.fromMap(map['reactionModel']);
      postPollModel = map['postPollModel'] == null ? null : PostPollModel.fromMap(map['postPollModel']);
      postReactionData = map['postReactionData'] == null
          ? PostReactionDataModel.withLikes(likedBy?.length ?? 0)
          : PostReactionDataModel.fromMap(map['postReactionData'], likedByCount: likedBy?.isNotEmpty == true ? likedBy?.length : null);

      pdfFiles = map['pdfFiles'] != null
          ? (map['pdfFiles'] as List)
              .map<Map<String, dynamic>>((file) =>
                  {"title": file['title'], "fileUrl": file['fileUrl'], "fileName": file['fileName'], "thumbnail": file['thumbnail']})
              .toList()
          : [];
      postTopicList = map['postTopicList'] == null ? [] : List<String>.from(map['postTopicList']);
      approvedAt = (map['approvedAt'] ?? map['createdOn'] as Timestamp).toDate();
      forGuestFeed = isForGuest ?? false;
      assigningPostType(map);
    } catch (_) {
      debugPrint("Im occured at: postfromMap $_");
    }
  }

  void assigningPostType(Map<String, dynamic> map) {
    /// if not present, do nothing
    if (map['postTypeData'] == null) return;
    if (map['postTypeData']['postType'] == PostCreationFrom.postReply.name) {
      postTypeData = PostReplyDataType.fromJson(map['postTypeData'] ?? {});
    } else if (map['postTypeData']['postType'] == PostCreationFrom.vibe.name) {
      postTypeData = PostWithVibes.fromJson(map['postTypeData'] ?? {});
    } else if (map['postTypeData']['postType'] == PostCreationFrom.poll.name) {
      postTypeData = PostWithPoll.fromJson(map['postTypeData'] ?? {});
    }
  }

  /// * This is for test purpose, create post with older schema.
  Map<String, dynamic> toOldMap() {
    return {
      'communityId': communityId,
      'postDescription': postDescription,
      'memberId': memberId,
      'postPicture': postPicture,
      'createdOn': postCreatedOn,
      'approve': approve,
      'isPinned': isPinned,
      'totalTime': totaltime,
      'postId': postid,
      'isDeleted': isDeleted,
      'isPostedAnonymously': isPostedAnonymously,
      'multipleImages': multipleImages,
      'video': video,
      'pdfFiles': pdfFiles,
      'postTypeData': postTypeData,
    };
  }

  //for sending the data
  Map<String, dynamic> toMap() {
    return {
      'postedBy': postedBy.toPublicJson(),
      'community': community.toMap(),
      'likedBy': likedBy ?? [],
      'crownsBy': crownsBy ?? [],
      'communityId': communityId,
      'postDescription': postDescription,
      'memberId': memberId,
      'postPicture': postPicture,
      'createdOn': postCreatedOn,
      'approve': approve,
      'isPinned': isPinned ?? false,
      'totalTime': totaltime,
      'postId': postid,
      'isDeleted': isDeleted,
      'isPostedAnonymously': isPostedAnonymously,
      'multipleImages': multipleImages,
      "totalCommentsCount": totalCommentsCount ?? "0",
      'video': video,
      'approvedAt': approvedAt,
      'postTopicList': (postTopicList == null) ? [] : postTopicList,
      'pdfFiles': pdfFiles ?? [],
      'reactionModel': reactionModel,
      'postPollModel': postPollModel,
      'postReactionData': postReactionData,
      'recentComments': recentComments,
      'postTypeData': postReplyVibeData,
    };
  }

  bool get isCommunityPrivate => community.communityType == "Private";

  bool get isCommunityPublic => community.communityType == "Public";

  bool get isPostHaveImage => multipleImages == null
      ? false
      : multipleImages!.isEmpty == true
          ? false
          : true;

  int? get totalCommentsCountInt => int.tryParse(totalCommentsCount ?? "0");

  @override
  String get type => DynamicLinkType.shareCommunityPost.name;

  @override
  String get queryParams =>
      "?${QueryParamConst.id}=$postid&${QueryParamConst.type}=$type&${QueryParamConst.communityId}=$communityId&${QueryParamConst.isPrivate}=$isCommunityPrivate";

  bool get isPostIdOnly => memberId == null || !postedBy.isUserNameExists || community.communityName.isBlank == true;

  Post copyWith({
    UserModel? postedBy,
    Community? community,
    String? communityId,
    String? postDescription,
    String? memberId,
    String? postid,
    String? postPicture,
    DateTime? postCreatedOn,
    String? totaltime,
    bool? approve,
    bool? isPostedAnonymously,
    bool? isDeleted,
    String? totalCommentsCount,
    List<String>? likedBy,
    List<String>? crownsBy,
    List<dynamic>? multipleImages,
    String? video,
    DateTime? approvedAt,
    List<String>? postTopicList,
    bool? isPinned,
    List<Map<String, dynamic>>? pdfFiles,
    int? score,
  }) {
    return Post(
      postedBy: postedBy ?? this.postedBy,
      community: community ?? this.community,
      communityId: communityId ?? this.communityId,
      postDescription: postDescription ?? this.postDescription,
      memberId: memberId ?? this.memberId,
      postid: postid ?? this.postid,
      postPicture: postPicture ?? this.postPicture,
      postCreatedOn: postCreatedOn ?? this.postCreatedOn,
      totaltime: totaltime ?? this.totaltime,
      approve: approve ?? this.approve,
      isPostedAnonymously: isPostedAnonymously ?? this.isPostedAnonymously,
      isDeleted: isDeleted ?? this.isDeleted,
      totalCommentsCount: totalCommentsCount ?? this.totalCommentsCount,
      likedBy: likedBy ?? this.likedBy,
      crownsBy: crownsBy ?? this.crownsBy,
      multipleImages: multipleImages ?? this.multipleImages,
      video: video ?? this.video,
      approvedAt: approvedAt ?? this.approvedAt,
      postTopicList: postTopicList ?? this.postTopicList,
      isPinned: isPinned ?? this.isPinned,
      pdfFiles: pdfFiles ?? this.pdfFiles,
    );
  }
}

extension PostHelper on Post {
  bool get isPostedByMe => UserModel.to.uId != null && (postedBy.uId == UserModel.to.uId || memberId == UserModel.to.uId);
}
