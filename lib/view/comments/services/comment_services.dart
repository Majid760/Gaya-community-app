import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:gaya/model/reaction_model.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/services/storage_servies.dart';
import 'package:gaya/utils/extension.dart';
import 'package:gaya/utils/logger.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../../services/services.dart';
import '../models/comment_custom_model.dart';

class CommentsServices extends CommentUtilsImpl {
  static const int commentLimit = kDebugMode ? 8 : 8;
  DocumentSnapshot? _lastDocument;
  bool _hasMoreComment = true;

  bool get hasMoreComments => _hasMoreComment;

  void reset() {
    _lastDocument = null;
    _hasMoreComment = true;
  }

  Future<List<MultiCommentModel>> loadPostsComments(String postId) async {
    List<MultiCommentModel> comments = [];
    try {
      var postCommentQuery = FirebaseFirestore.instance
          .collection('communityposts')
          .doc(postId)
          .collection('comments')
          .orderBy('commentTime', descending: false)
          .limit(commentLimit);
      if (_lastDocument != null) {
        postCommentQuery = postCommentQuery.startAfterDocument(_lastDocument!);
      }
      //if no comments
      if (_hasMoreComment == false) {
        return [];
      }
      // final stopWatch = Stopwatch()..start();
      final postComments = await postCommentQuery.get();

      postComments.docs.isNotEmpty ? _lastDocument = postComments.docs.last : _hasMoreComment = false;

      // make comment meaningful
      comments = await loadCommentsFromQuerySnapshot(postComments, postId: postId);
      // stopWatch.stop();
      // debugPrint("Time taken to load comments: ${stopWatch.elapsedMilliseconds} ms");
      _hasMoreComment = comments.length == commentLimit;
      // debugPrint("has more posts: $_hasMoreComment");
    } catch (_) {
      // debugPrint("Handled Error loading comments: $getAllCommentException");
    }
    comments.removeWhere((element) => element.comment.user.uId == null);
    return comments;
  }
}

abstract class CommentUtilsImpl {
  final User? _firebaseUser = FirebaseAuth.instance.currentUser;
  Services commonService = Services();

  // List<UserModel> cachedUsers = [];

  Future<List<MultiCommentModel>> loadCommentsFromQuerySnapshot(QuerySnapshot<Map<String, dynamic>> parentComments,
      {required String postId}) async {
    final List<MultiCommentModel> comments = [];

    for (final QueryDocumentSnapshot<Map<String, dynamic>> parentComment in parentComments.docs) {
      final List<CommentCustomModel> replies = [];
      try {
        final batchQueryParentResult = await Future.wait([
          //get parentUserModel user.
          getUserById(parentComment.data()['userId'], forcefullyServer: true),
          //parentComment comment likes
          // countTotalLikesOnComment(postId, parentComment.id),

          // get current user vibe/reaction on parent comment
          getCurrentUserReactionOnParentComment(postId, parentComment.id),

          //parentComment comment Crowns
          countTotalCrownsOnComment(postId, parentComment.id),
          //child comments
          FirebaseFirestore.instance
              .collection('communityposts')
              .doc(postId)
              .collection('comments')
              .doc(parentComment.id)
              .collection('replies')
              .orderBy('replyTime', descending: false)
              .get()
        ]);

        final parentUserModel = batchQueryParentResult[0] as UserModel;
        // Map<String, dynamic> parentCommentLikes = batchQueryParentResult[1] as Map<String, dynamic>;
        ReactionModel? parentReactionModel = batchQueryParentResult[1] as ReactionModel?;
        Map<String, dynamic> parentCommentCrowns = batchQueryParentResult[2] as Map<String, dynamic>;

        //iterate for child comments/replies
        final childComments = batchQueryParentResult[3] as QuerySnapshot<Map<String, dynamic>>;

        for (final childComment in childComments.docs) {
          try {
            final batchQueryChildResult = await Future.wait([
              //get childUserModel user.
              getUserById(
                childComment.data()['userUid'] ?? childComment.data()['userId'],
              ), //incase if typo

              // get current user vibe/reaction on child comment/reply
              getCurrentUserReactionOnChildComment(postId, parentComment.id, childComment.data()['replyId']),
              //childComment comment Crowns
              countTotalCrownsOnCommentReply(postId, parentComment.id, childComment.data()['replyId'])
            ]);
            final childUserModel = batchQueryChildResult[0] as UserModel;
            // Map<String, dynamic> childCommentLikes = batchQueryChildResult[1] as Map<String, dynamic>;
            ReactionModel? childCommentReactionModel = batchQueryChildResult[1] as ReactionModel?;

            Map<String, dynamic> childCommenCrowns = batchQueryChildResult[2] as Map<String, dynamic>;

            /// if user is deleted
            if (childUserModel.uId == null) {
              continue;
            }

            replies.add(CommentCustomModel(
              id: childComment.id,
              comment: childComment.data()['reply'],
              user: childUserModel,
              createdAt: childComment.data()['replyTime'].toDate(),
              // totalLikes: childCommentLikes['totalLikes'],
              reactionModel: childCommentReactionModel,
              totalCrowns: childCommenCrowns['totalCrowns'] ?? 0,
              // isLiked: childCommentLikes['isLiked'],
              isLiked: false,
              // commentReactionData: childComment.data()['commentReactionData'],
              commentReactionData: (childComment.data()['commentReactionData'] != null)
                  ? PostReactionDataModel.fromMap(childComment.data()['commentReactionData'] as Map<String, dynamic>)
                  : null,

              isCrown: childCommenCrowns['isCrown'],
              photoUrl: childComment.data()['photoUrl'],
              videoUrl: childComment.data()['videoUrl'],
              mentionedUsers: childComment.data()['mentionedUsers'] != null
                  ? (childComment.data()['mentionedUsers'] as List)
                      .map<Map<String, dynamic>>((user) => {
                            "display": user['display'],
                            "senderUid": user['senderUid'],
                            "senderProfile": user['senderProfile'],
                            "id": user['id'],
                            "isCommunity": user['isCommunity'] ?? false
                          })
                      .toList()
                  : null,
              pdfFiles: childComment.data()['pdfFiles'] != null
                  ? (childComment.data()['pdfFiles'] as List)
                      .map<Map<String, dynamic>>((file) => {
                            "title": file['title'],
                            "fileUrl": file['fileUrl'],
                            "fileName": file['fileName'],
                            "thumbnail": file['thumbnail']
                          })
                      .toList()
                  : [],
            ));
          } catch (repliesError) {
            // debugPrint("Handled Error getting replies: $repliesError");
          }
        }

        /// if user is deleted
        if (parentUserModel.uId == null || !parentUserModel.isUserNameExists) {
          continue;
        }

        comments.add(MultiCommentModel(
          comment: CommentCustomModel(
            id: parentComment.id,
            comment: parentComment.data()['comment'],
            user: parentUserModel,
            createdAt: parentComment.data()['commentTime'].toDate(),
            // totalLikes: parentCommentLikes['totalLikes'],
            reactionModel: parentReactionModel,
            totalCrowns: parentCommentCrowns['totalCrowns'] ?? 0,
            // isLiked: parentCommentLikes['isLiked'],
            commentReactionData: (parentComment.data()['commentReactionData'] != null)
                ? PostReactionDataModel.fromMap(parentComment.data()['commentReactionData'] as Map<String, dynamic>)
                : null,
            isLiked: false,
            isCrown: parentCommentCrowns['isCrown'],
            photoUrl: parentComment.data()['photoUrl'],
            videoUrl: parentComment.data()['videoUrl'],
            mentionedUsers: parentComment.data()['mentionedUsers'] != null
                ? (parentComment.data()['mentionedUsers'] as List)
                    .map<Map<String, dynamic>>((user) => {
                          "display": user['display'],
                          "senderUid": user['senderUid'],
                          "senderProfile": user['senderProfile'],
                          "id": user['id'],
                          "isCommunity": user['isCommunity'] ?? false
                        })
                    .toList()
                : null,
            pdfFiles: parentComment.data()['pdfFiles'] != null
                ? (parentComment.data()['pdfFiles'] as List)
                    .map<Map<String, dynamic>>((file) =>
                        {"title": file['title'], "fileUrl": file['fileUrl'], "fileName": file['fileName'], "thumbnail": file['thumbnail']})
                    .toList()
                : [],
          ),
          replies: replies,
        ));
      } catch (parentException) {
        MyLoggerServices.to.print('error thruwo due to ${parentException.toString()}');
      }
    }
    return comments;
  }

  Future<UserModel?> getUserById(String? userId, {bool forcefullyServer = false}) async {
    return await commonService.getUserById(
      userId,
      forcefullyServer: forcefullyServer,
    );
  }

  // Future<Map<String, dynamic>> countTotalLikesOnComment(String postId, String commentId) async {
  //   int totalLikes = 0;
  //   bool isLiked = false;
  //   try {
  //     final query = (await FirebaseFirestore.instance
  //         .collection('communityposts')
  //         .doc(postId)
  //         .collection('comments')
  //         .doc(commentId)
  //         .collection('likeOnComment')
  //         .get());

  //     totalLikes = query.docs.length;

  //     query.docs.firstWhere((element) {
  //       if (element.data()['userUid'] == _firebaseUser?.uid) {
  //         isLiked = true;
  //         return true;
  //       } else {
  //         return false;
  //       }
  //     });
  //   } catch (_) {}

  //   return {
  //     "totalLikes": totalLikes,
  //     "isLiked": isLiked,
  //   };
  // }
  Future<ReactionModel?> getCurrentUserReactionOnParentComment(String postId, String commentId) async {
    try {
      final query = (await FirebaseFirestore.instance
          .collection('communityposts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .collection('reactions')
          .doc(UserModel.to.uId)
          .get());

      if (query.exists) {
        return ReactionModel.fromMap(query.data() as Map<String, dynamic>);
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  Future<Map<String, dynamic>> countTotalCrownsOnComment(String postId, String commentId) async {
    int totalLikes = 0;
    bool isCrown = false;
    final ref = FirebaseFirestore.instance
        .collection('communityposts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .collection('crownOnComment');
    final response = await calculateAndIfReacted(ref);
    totalLikes = response.$1;
    isCrown = response.$2;

    return {
      "totalCrowns": totalLikes,
      "isCrown": isCrown,
    };
  }

  // Future<Map<String, dynamic>> countTotalLikesOnCommentReply(String postId, String commentId, String replyId) async {
  //   int totalLikes = 0;
  //   bool isLiked = false;
  //   try {
  //     final query = (await FirebaseFirestore.instance
  //         .collection('communityposts')
  //         .doc(postId)
  //         .collection('comments')
  //         .doc(commentId)
  //         .collection('replies')
  //         .doc(replyId)
  //         .collection('likeOnComment')
  //         .get());

  //     totalLikes = query.docs.length;
  //     query.docs.firstWhere((element) {
  //       if (element.data()['userUid'] == _firebaseUser?.uid) {
  //         isLiked = true;
  //         return true;
  //       } else {
  //         return false;
  //       }
  //     });
  //   } catch (_) {}
  //   return {
  //     "totalLikes": totalLikes,
  //     "isLiked": isLiked,
  //   };
  // }
  Future<ReactionModel?> getCurrentUserReactionOnChildComment(String postId, String commentId, String replyId) async {
    try {
      final query = (await FirebaseFirestore.instance
          .collection('communityposts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .collection('replies')
          .doc(replyId)
          .collection('reactions')
          .doc(UserModel.to.uId)
          .get());

      if (query.exists) {
        return ReactionModel.fromMap(query.data() as Map<String, dynamic>);
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  Future<Map<String, dynamic>> countTotalCrownsOnCommentReply(String postId, String commentId, String replyId) async {
    int totalLikes = 0;
    bool isCrown = false;
    final ref = FirebaseFirestore.instance
        .collection('communityposts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .collection('replies')
        .doc(replyId)
        .collection('crownOnComment');
    final response = await calculateAndIfReacted(ref);
    totalLikes = response.$1;
    isCrown = response.$2;
    return {
      "totalCrowns": totalLikes,
      "isCrown": isCrown,
    };
  }

  // upload the comment media to storage
  Future<String?> uploadPhoto({required File file}) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;
      UploadTask uploadTask = StoragePaths.commentPhoto(user.uid).putFile(file);
      StreamSubscription listenEvent = uploadTask.snapshotEvents.listen((data) {
        // percentage = (data.bytesTransferred / data.totalBytes);
        // // notifyListeners();
        // if (data.state == TaskState.success) {
        //   percentage = null;
        //
        // }
      });
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      listenEvent.cancel();
      debugPrint('UPLOAD SUCCCESSFULL');
      return downloadUrl;
    } catch (e) {
      return null;
    }
  }

  //upload  video to firebaseStorage
  Future<String?> uploadVideo({required File file}) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;
      UploadTask uploadTask = StoragePaths.commentVideo(user.uid).putFile(file);

      TaskSnapshot taskSnapshot = await uploadTask;
      String videoDownloadLink = await taskSnapshot.ref.getDownloadURL();
      return videoDownloadLink;
    } catch (e) {
      return null;
    }
  }

  //get  video thumbnail
  Future<File?> getThumbnailFromVideoUrl({required String videoUrl}) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;
      String? fileName = await VideoThumbnail.thumbnailFile(video: videoUrl, imageFormat: ImageFormat.PNG, quality: 100);
      return fileName != null ? File(fileName) : null;
    } catch (e) {
      return null;
    }
  }

  //upload  document to firebaseStorage
  Future<String?> uploadDocument({required File file}) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;
      UploadTask uploadTask = StoragePaths.commentDocuments(user.uid, file.path.split('/').last).putFile(file);
      TaskSnapshot taskSnapshot = await uploadTask;
      String documentDownloadLink = await taskSnapshot.ref.getDownloadURL();
      return documentDownloadLink;
    } catch (e) {
      return null;
    }
  }

  //upload  document to firebaseStorage
  Future<String?> uploadDocumentThumbnail({required File file}) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;
      UploadTask uploadTask = StoragePaths.commentDocumentPhoto(user.uid).putFile(file);
      TaskSnapshot taskSnapshot = await uploadTask;
      String documentThumbnailDownloadLink = await taskSnapshot.ref.getDownloadURL();
      return documentThumbnailDownloadLink;
    } catch (e) {
      return null;
    }
  }

  //get  video thumbnail from video file
  Future<File?> getThumbnailFromVideoFile({required File videoFile}) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;
      Uint8List? uint8list = await VideoThumbnail.thumbnailData(video: videoFile.path, imageFormat: ImageFormat.PNG, quality: 100);
      return uint8list != null ? File.fromRawPath(uint8list) : null;
    } catch (e) {
      return null;
    }
  }

  /// Generic method to calculate total reacted and if user reacted
  ///[ref] is the reference of the collection
  Future<(int, bool)> calculateAndIfReacted(CollectionReference ref) async {
    final _firebaseUser = FirebaseAuth.instance.currentUser;
    int count = 0;
    bool isReacted = false;

    try {
      /// get total reaction count
      List<Future<dynamic>> futures = [
        ref.getCount(),
      ];

      /// Check if user is logged in
      if (_firebaseUser != null) {
        futures.add(ref.where('userId', isEqualTo: _firebaseUser!.uid).get());
        futures.add(ref.where('userUid', isEqualTo: _firebaseUser!.uid).get());
      }

      /// wait for all futures to complete
      final results = await Future.wait(futures);

      /// get total count
      count = (results[0] as int? ?? 0);

      /// might be a case where we don't have user logged in
      /// so need to check the length of results
      /// if it is greater than 1 then we have user logged in and we need to check if user reacted
      if (results.length > 1) {
        final snap = results[1] as QuerySnapshot<Map<String, dynamic>>?;
        isReacted = ((results[1] as QuerySnapshot<Map<String, dynamic>>?)?.size ?? 0) > 0;

        /// inCase if typo for userId, so checking for userUid as well
        /// if userUid is present then we need to set isReacted to true
        if (!isReacted) {
          isReacted = ((results[2] as QuerySnapshot<Map<String, dynamic>>?)?.size ?? 0) > 0;
        }
      }
    } catch (_, s) {
      MyLoggerServices.to.printError(s);
    }
    return (count, isReacted);
  }
}
