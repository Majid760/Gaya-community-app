import 'package:cloud_firestore/cloud_firestore.dart';

class EngagementUtils {
  // post
  final int kCreatePostScore = 30;
  final int kPostCrownScore = 5;
  final int kPostLikeScore = 2;
  final int kPostDislikeScore = -1;

  // parent comments
  final int kCommentScore = 20;
  final int kCommentLikeScore = 15;
  final int kCommentDislikeScore = -1;

  // reply comments
  final int kCommentReplyScore = 20;
  final int kCommentReplyLikeScore = 3;
  final int kCommentReplyDislikeScore = -1;

  // reply crown comment
  final int kCommentCrownScore = 5;
  final int kCommentReplyCrownScore = 5;

  final int kDirectMessageScore = 5;

  // Friendship
  final int kRejectRequestScore = 20;
  final int kAcceptRequestScore = 20;
  final int kSendRequestScore = 35;

  // Share
  final int kShareScore = 100;

  // crown reward and profile compliment
  // final double kCrownRewardScore = 0.25;
  // final double kProfileComplimentScore = 0.25;
  // // Block, report and delete post
  // final int kBlockUserScore = -5;
  // final int kReportScore = -5;
  // final int kDeletePostScore = -5;

  /// Returns true if user is a sticky user (score >= 1000)
  bool isStickyUser(dynamic score) {
    if (score is int) return score >= 1000;
    return false;
  }
}

/// To overcome the redundant code of updating the score
/// A Class to hold the score and the list of document references to update
///* Benefit: less code, less error + single gateway [batchUpdateScore]
class BatchEngagement {
  /// The score to update
  final int score;

  /// The list of document references to update, default is empty because
  /// we don't need to update any document if its only related to the user entity so default = []
  final List<DocumentReference> refs;

  /// A document reference for the user entity
  final DocumentReference userRef;

  /// A payload to update the user entity
  final Map<String, dynamic> userActivity;

  BatchEngagement({required this.score, this.refs = const [], required this.userRef, required this.userActivity});
}

class ScoringValues {
  // post
  final int createPostScore;
  final int postCrownScore;
  final int postLikeScore;
  final int postDislikeScore;

  // parent comments
  final int commentScore;
  final int commentLikeScore;
  final int commentDislikeScore;

  // reply comments
  final int commentReplyScore;
  final int commentReplyLikeScore;
  final int commentReplyDislikeScore;

  // reply crown comment
  final int commentCrownScore;
  final int commentReplyCrownScore;

  final int directMessageScore;

  // Friendship
  final int rejectRequestScore;

  final int acceptRequestScore;
  final int sendRequestScore;

  // Share
  final int shareScore;

  // crown reward and profile compliment
  // final double crownRewardScore;
  // final double profileComplimentScore;

  // // Block, report and delete post
  // final int blockUserScore;
  // final int reportScore;
  // final int deletePostScore;

  ScoringValues({
    required this.createPostScore,
    required this.postCrownScore,
    required this.postLikeScore,
    required this.postDislikeScore,
    required this.commentScore,
    required this.commentLikeScore,
    required this.commentDislikeScore,
    required this.commentReplyScore,
    required this.commentReplyLikeScore,
    required this.commentReplyDislikeScore,
    required this.commentCrownScore,
    required this.commentReplyCrownScore,
    required this.directMessageScore,
    required this.rejectRequestScore,
    required this.acceptRequestScore,
    required this.sendRequestScore,
    required this.shareScore,
    // required this.crownRewardScore,
    // required this.profileComplimentScore,
    // required this.blockUserScore,
    // required this.reportScore,
    // required this.deletePostScore,
  });

  factory ScoringValues.defaultValues() {
    return ScoringValues(
      createPostScore: 30,
      postCrownScore: 5,
      postLikeScore: 2,
      postDislikeScore: -1,
      commentScore: 20,
      commentLikeScore: 15,
      commentDislikeScore: -1,
      commentReplyScore: 20,
      commentReplyLikeScore: 3,
      commentReplyDislikeScore: -1,
      commentCrownScore: 5,
      commentReplyCrownScore: 5,
      directMessageScore: 5,
      rejectRequestScore: 20,
      acceptRequestScore: 20,
      sendRequestScore: 35,
      shareScore: 100,
      // crownRewardScore: 0.25,
      // profileComplimentScore: 0.25,
      // blockUserScore: -5,
      // reportScore: -5,
      // deletePostScore: -5,
    );
  }

  factory ScoringValues.fromMap(Map<String, dynamic> map) {
    try {
      return ScoringValues(
        createPostScore: map['createPostScore'] ?? 30,
        postCrownScore: map['postCrownScore'] ?? 5,
        postLikeScore: map['postLikeScore'] ?? 2,
        postDislikeScore: map['postDislikeScore'] ?? -1,
        commentScore: map['commentScore'] ?? 20,
        commentLikeScore: map['commentLikeScore'] ?? 15,
        commentDislikeScore: map['commentDislikeScore'] ?? -1,
        commentReplyScore: map['commentReplyScore'] ?? 20,
        commentReplyLikeScore: map['commentReplyLikeScore'] ?? 3,
        commentReplyDislikeScore: map['commentReplyDislikeScore'] ?? -1,
        commentCrownScore: map['commentCrownScore'] ?? 5,
        commentReplyCrownScore: map['commentReplyCrownScore'] ?? 5,
        directMessageScore: map['directMessageScore'] ?? 5,
        rejectRequestScore: map['rejectRequestScore'] ?? 20,
        acceptRequestScore: map['acceptRequestScore'] ?? 20,
        sendRequestScore: map['sendRequestScore'] ?? 35,
        shareScore: map['shareScore'] ?? 100,
        // crownRewardScore: map['crownRewardScore'] ?? 0.25,
        // profileComplimentScore: map['profileComplimentScore'] ?? 0.25,
        // blockUserScore: map['blockUserScore'] ?? -5,
        // reportScore: map['reportScore'] ?? -5,
        // deletePostScore: map['deletePostScore'] ?? -5,
      );
    } catch (_) {
      return ScoringValues.defaultValues();
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'createPostScore': createPostScore,
      'postCrownScore': postCrownScore,
      'postLikeScore': postLikeScore,
      'postDislikeScore': postDislikeScore,
      'commentScore': commentScore,
      'commentLikeScore': commentLikeScore,
      'commentDislikeScore': commentDislikeScore,
      'commentReplyScore': commentReplyScore,
      'commentReplyLikeScore': commentReplyLikeScore,
      'commentReplyDislikeScore': commentReplyDislikeScore,
      'commentCrownScore': commentCrownScore,
      'commentReplyCrownScore': commentReplyCrownScore,
      'directMessageScore': directMessageScore,
      'rejectRequestScore': rejectRequestScore,
      'acceptRequestScore': acceptRequestScore,
      'sendRequestScore': sendRequestScore,
      'shareScore': shareScore,
      // 'crownRewardScore': crownRewardScore,
      // 'profileComplimentScore': profileComplimentScore,
      // 'blockUserScore': blockUserScore,
      // 'reportScore': reportScore,
      // 'deletePostScore': deletePostScore,
    };
  }
}
