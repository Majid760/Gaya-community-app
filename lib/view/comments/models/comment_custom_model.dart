import 'dart:io';

import 'package:gaya/model/reaction_model.dart';
import 'package:gaya/model/user.model.dart';

import '../../../utils/methods.dart';

enum MediaSource { local, network, idle }

class MultiCommentModel {
  CommentCustomModel comment;
  List<CommentCustomModel> replies;

  MultiCommentModel({required this.comment, this.replies = const []});

  void addReply(CommentCustomModel reply) {
    replies.add(reply);
  }
}

class CommentCustomModel {
  final String id;
  final String comment;
  final UserModel user;
  int totalLikes;
  int totalCrowns;

  // int totalFlowers;
  bool isLiked;

  // bool isFlower;
  bool isCrown;
  final DateTime createdAt;
  final String? photoUrl;
  final Map<String, dynamic>? videoUrl;
  final File? photoFile;
  final File? videoFile;
  final MediaSource mediaSource;
  final File? documentFile;
  final List<Map<String, dynamic>>? mentionedUsers;
  final List<Map<String, dynamic>>? pdfFiles;
  final bool isRTLText;

  // Reaction parameters
  ReactionModel? reactionModel;
  PostReactionDataModel? commentReactionData;

  CommentCustomModel(
      {required this.id,
      required this.comment,
      required this.user,
      required this.createdAt,
      this.totalLikes = 0,
      this.totalCrowns = 0,
      // this.totalFlowers = 0,
      this.isLiked = false,
      this.isCrown = false,
      // this.isFlower = false
      this.photoUrl,
      this.videoUrl,
      this.videoFile,
      this.photoFile,
      this.mediaSource = MediaSource.network,
      this.mentionedUsers,
      this.documentFile,
      this.pdfFiles,
      this.reactionModel,
      this.commentReactionData,
      this.isRTLText = false});

  //for getting the data
  // CommentCustomModel.fromMap(Map<String, dynamic> map, String id) {
  //   try {
  //     comment = UserModel.fromMap(map['postedBy']);
  //     user = UserModel.fromSnapshot(_userSnap);
  //     id = id;
  //     createdAt = map['commentTime'].toDate();
  //     totalLikes = 0;
  //     reactionModel = null;
  //     commentReactionData = null;
  //     totalLikes = 0;
  //     isLiked = false;
  //     isCrown = false;
  //     photoUrl = map['photoUrl'];
  //     videoUrl = map['videoUrl'];
  //     documentFile = map['isPostedAnonymously'];
  //     pdfFiles = map['multipleImages'];
  //     pdfFiles = map['pdfFiles'] != null
  //         ? (map['pdfFiles'] as List)
  //             .map<Map<String, dynamic>>((file) =>
  //                 {"title": file['title'], "fileUrl": file['fileUrl'], "fileName": file['fileName'], "thumbnail": file['thumbnail']})
  //             .toList()
  //         : [];
  //   } catch (_) {}
  // }

  CommentCustomModel copyWithLike({bool shouldUnlike = false}) {
    return CommentCustomModel(
      id: this.id,
      comment: this.comment,
      user: this.user,
      createdAt: this.createdAt,
      totalLikes: shouldUnlike == false
          ? this.totalLikes + 1
          : this.totalLikes > 0
              ? this.totalLikes - 1
              : this.totalLikes,
      totalCrowns: this.totalCrowns,
      isLiked: !this.isLiked,
      isCrown: this.isCrown,
      photoUrl: photoUrl ?? this.photoUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      photoFile: photoFile ?? this.photoFile,
      videoFile: videoFile ?? this.videoFile,
      mediaSource: mediaSource,
      mentionedUsers: mentionedUsers ?? this.mentionedUsers,
      pdfFiles: pdfFiles,
      documentFile: documentFile,
      // isFlower: this.isFlower,
      reactionModel: reactionModel,
      commentReactionData: commentReactionData,
    );
  }

  CommentCustomModel copyWithFlower({bool shouldUnCrown = false}) {
    return CommentCustomModel(
      id: this.id,
      comment: this.comment,
      user: this.user,
      createdAt: this.createdAt,
      totalLikes: this.totalLikes,
      totalCrowns: shouldUnCrown == false
          ? this.totalCrowns + 1
          : this.totalCrowns > 0
              ? this.totalCrowns - 1
              : this.totalCrowns,
      isLiked: this.isLiked,
      isCrown: !this.isCrown,
      photoUrl: photoUrl ?? this.photoUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      photoFile: photoFile ?? this.photoFile,
      videoFile: videoFile ?? this.videoFile,
      mediaSource: mediaSource,
      mentionedUsers: mentionedUsers ?? this.mentionedUsers,
      pdfFiles: pdfFiles ?? this.pdfFiles,
      documentFile: documentFile,
      reactionModel: reactionModel,
      commentReactionData: commentReactionData,
      // isFlower: !this.isFlower,
    );
  }

  CommentCustomModel copyWith({
    String? id,
    String? comment,
    UserModel? user,
    int? totalLikes,
    int? totalCrowns,
    // int? totalFlowers,
    bool? isLiked,
    bool? isCrown,
    // bool? isFlower,
    DateTime? createdAt,
    String? photoUrl,
    Map<String, dynamic>? videoUrl,
    File? photoFile,
    File? videoFile,
    File? documentFile,
    MediaSource? mediaSource,
    List<Map<String, dynamic>>? mentionedUsers,
    List<Map<String, dynamic>>? pdfFiles,

    // Reaction parameters
    ReactionModel? reactionModel,
    PostReactionDataModel? commentReactionData,
  }) {
    return CommentCustomModel(
      id: id ?? this.id,
      comment: comment ?? this.comment,
      user: user ?? this.user,
      totalLikes: totalLikes ?? this.totalLikes,
      totalCrowns: totalCrowns ?? this.totalCrowns,
      isLiked: isLiked ?? this.isLiked,
      isCrown: isCrown ?? this.isCrown,
      createdAt: createdAt ?? this.createdAt,
      photoUrl: photoUrl ?? this.photoUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      mediaSource: mediaSource ?? this.mediaSource,
      mentionedUsers: mentionedUsers ?? this.mentionedUsers,
      pdfFiles: pdfFiles ?? this.pdfFiles,
      documentFile: documentFile ?? this.documentFile,

      reactionModel: reactionModel,
      commentReactionData: commentReactionData,
      //
    );
  }

  factory CommentCustomModel.fromJson(Map comment, UserModel? author) {
    return CommentCustomModel(
      id: comment['commentId'],
      photoUrl: comment['photoUrl'],
      videoUrl: comment['videoUrl'],
      pdfFiles: comment['pdfFiles'] != null
          ? (comment['pdfFiles'] as List)
              .map<Map<String, dynamic>>((file) =>
                  {"title": file['title'], "fileUrl": file['fileUrl'], "fileName": file['fileName'], "thumbnail": file['thumbnail']})
              .toList()
          : [],
      user: comment['author'] != null ? UserModel.fromMap(comment['author']) : (author ?? UserModel()),
      mentionedUsers: comment['mentionedUsers'] != null
          ? (comment['mentionedUsers'] as List)
              .map<Map<String, dynamic>>((user) => {
                    "display": user['display'],
                    "senderUid": user['senderUid'],
                    "senderProfile": user['senderProfile'],
                    "id": user['id'],
                    "isCommunity": user['isCommunity'] ?? false
                  })
              .toList()
          : null,
      createdAt: comment['commentTime'].toDate(),
      comment: comment['comment'],
      isRTLText: Methods.isRTL(comment['comment']),
    );
  }
}
