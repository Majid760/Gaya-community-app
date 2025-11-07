import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'engagement_helpers/engagement_consts.dart';
import 'engagement_helpers/engagement_utils.dart';
import 'engagement_helpers/user_engagement_ref.dart';
import '../firebase_crashlytics_services.dart';
import '../../../utils/logger.dart';

abstract class IEngagementScore {
  Future<void> onPostCreated({required String communityId});

  Future<void> onComment({required String communityId, required String postId, required String? commentId});

  Future<void> onCrown({required String postId, required String communityId, required String? commentId, String? replyId});

  Future<void> onLike({required String communityId, required String postId, required String? commentId, String? replyId});

  Future<void> onDislike({required String communityId, required String postId, required String? commentId, String? replyId});

  Future<void> onShare({required String? communityId, required String? postId});

  /// Related to [UserEngagementRef]

  Future<void> onDirectMessage({required String toUserId});

  Future<void> onSendRequest({required String toUserId});

  Future<void> onAcceptRequest({required String fromUserId});

  Future<void> onRejectRequest({required String fromUserId});

  // Future<void> onBlockUser({required String toUserId});

  // Future<void> onReportUser({required String toUserId});
}

class EngagementScoreServices extends ImplUserEngagementRef implements IEngagementScore {
  final MyLoggerServices _logger;
  final CrashlyticsService _crashlyticsController;
  final ScoringValues scoringValues;
  EngagementScoreServices({
    required MyLoggerServices logger,
    required CrashlyticsService crashlyticsController,
    required this.scoringValues,
  })  : _logger = logger,
        _crashlyticsController = crashlyticsController;

  @override
  Future<void> onPostCreated({required String communityId}) async {
    if (communityId.isBlank == true) return;
    try {
      await _batchUpdateScore(
          batchEngagement: BatchEngagement(
        score: scoringValues.createPostScore,
        userRef: super.userRef,
        userActivity: super.userCreatePost(scoringValues.createPostScore),
        refs: [
          EngagementConsts.communityRef(communityId),
        ],
      ));
    } catch (e, s) {
      _logger.print("onPostCreated: $e");
      _crashlyticsController.recordError(e, stackTrace: s, reason: "onPostCreatedScore");
    }
  }

  @override
  Future<void> onComment({required String communityId, required String postId, String? commentId}) async {
    if (communityId.isBlank == true || postId.isBlank == true || postId.isBlank == true) return;
    try {
      ///
      if (commentId != null) {
        _batchUpdateScore(
          batchEngagement: BatchEngagement(
            score: scoringValues.commentReplyScore,
            userRef: super.userRef,
            userActivity: super.userCommentedReply(scoringValues.commentReplyScore),
            refs: [
              EngagementConsts.postRef(postId),
              EngagementConsts.communityRef(communityId),

              /// For future use - get top commenter's
              EngagementConsts.commentRef(postId: postId, commentId: commentId),
            ],
          ),
        );
      } else {
        /// If replyId is null, then it's a comment to a post
        _batchUpdateScore(
          batchEngagement: BatchEngagement(
            score: scoringValues.commentScore,
            userRef: super.userRef,
            userActivity: super.userCommented(scoringValues.commentScore),
            refs: [
              EngagementConsts.postRef(postId),
              EngagementConsts.communityRef(communityId),
            ],
          ),
        );
      }
    } catch (e, s) {
      _logger.print("onComment: $e");
      _crashlyticsController.recordError(e, stackTrace: s, reason: "onCommentScore");
    }
  }

  @override
  Future<void> onCrown({required String postId, required String communityId, String? commentId, String? replyId}) async {
    if (communityId.isBlank == true || postId.isBlank == true) return;
    try {
      /// Crown on comment reply
      if (replyId != null) {
        await _batchUpdateScore(
          batchEngagement: BatchEngagement(
            score: scoringValues.commentReplyCrownScore,
            userRef: super.userRef,
            userActivity: super.userCommentCrownedReply(scoringValues.commentReplyCrownScore),
            refs: [
              EngagementConsts.postRef(postId),
              EngagementConsts.communityRef(communityId),
              EngagementConsts.commentRef(postId: postId, commentId: commentId!),
            ],
          ),
        );
      }

      /// crown on comment
      else if (commentId != null) {
        await _batchUpdateScore(
          batchEngagement: BatchEngagement(
            score: scoringValues.commentCrownScore,
            userRef: super.userRef,
            userActivity: super.userCommentCrowned(scoringValues.commentCrownScore),
            refs: [
              EngagementConsts.postRef(postId),
              EngagementConsts.communityRef(communityId),
              EngagementConsts.commentRef(postId: postId, commentId: commentId),
            ],
          ),
        );
      }

      /// crown on post
      else {
        await _batchUpdateScore(
          batchEngagement: BatchEngagement(
            score: scoringValues.postCrownScore,
            userRef: super.userRef,
            userActivity: super.userPostCrowned(scoringValues.postCrownScore),
            refs: [
              EngagementConsts.postRef(postId),
              EngagementConsts.communityRef(communityId),
            ],
          ),
        );
      }
    } catch (e, s) {
      _logger.print("onCrown: $e");
      _crashlyticsController.recordError(e, stackTrace: s, reason: "onCrownScore");
    }
  }

  @override
  Future<void> onDislike({required String communityId, required String postId, String? commentId, String? replyId}) async {
    if (communityId.isBlank == true || postId.isBlank == true) return;
    try {
      /// Dislike on comment reply
      if (replyId != null) {
        await _batchUpdateScore(
          batchEngagement: BatchEngagement(
            score: scoringValues.commentReplyDislikeScore,
            userRef: super.userRef,
            userActivity: super.userCommentDislikedReply(scoringValues.commentReplyDislikeScore),
            refs: [
              EngagementConsts.postRef(postId),
              EngagementConsts.communityRef(communityId),
              EngagementConsts.commentRef(postId: postId, commentId: commentId!),
            ],
          ),
        );
      }

      /// Dislike on comment
      else if (commentId != null) {
        await _batchUpdateScore(
          batchEngagement: BatchEngagement(
            score: scoringValues.commentDislikeScore,
            userRef: super.userRef,
            userActivity: super.userCommentDisliked(scoringValues.commentDislikeScore),
            refs: [
              EngagementConsts.postRef(postId),
              EngagementConsts.communityRef(communityId),
              EngagementConsts.commentRef(postId: postId, commentId: commentId),
            ],
          ),
        );
      }

      /// Dislike on post
      else {
        await _batchUpdateScore(
          batchEngagement: BatchEngagement(
            score: scoringValues.postDislikeScore,
            userRef: super.userRef,
            userActivity: super.userPostDisliked(scoringValues.postDislikeScore),
            refs: [
              EngagementConsts.postRef(postId),
              EngagementConsts.communityRef(communityId),
            ],
          ),
        );
      }
    } catch (e, s) {
      _logger.print("onDislike: $e");
      _crashlyticsController.recordError(e, stackTrace: s, reason: "onDislikeScore");
    }
  }

  @override
  Future<void> onLike({required String communityId, required String postId, String? commentId, String? replyId}) async {
    if (communityId.isBlank == true || postId.isBlank == true) return;
    try {
      /// Like on comment reply
      if (replyId != null) {
        await _batchUpdateScore(
          batchEngagement: BatchEngagement(
            score: scoringValues.commentReplyLikeScore,
            userRef: super.userRef,
            userActivity: super.userCommentLikedReply(scoringValues.commentReplyLikeScore),
            refs: [
              EngagementConsts.postRef(postId),
              EngagementConsts.communityRef(communityId),
              EngagementConsts.commentRef(postId: postId, commentId: commentId!),
            ],
          ),
        );
      }

      /// Like on comment
      else if (commentId != null) {
        await _batchUpdateScore(
          batchEngagement: BatchEngagement(
            score: scoringValues.commentLikeScore,
            userRef: super.userRef,
            userActivity: super.userCommentLiked(scoringValues.commentLikeScore),
            refs: [
              EngagementConsts.postRef(postId),
              EngagementConsts.communityRef(communityId),
              EngagementConsts.commentRef(postId: postId, commentId: commentId),
            ],
          ),
        );
      }

      /// Like on post
      else {
        await _batchUpdateScore(
          batchEngagement: BatchEngagement(
            score: scoringValues.postLikeScore,
            userRef: super.userRef,
            userActivity: super.userPostLiked(scoringValues.postLikeScore),
            refs: [
              EngagementConsts.postRef(postId),
              EngagementConsts.communityRef(communityId),
            ],
          ),
        );
      }
    } catch (e, s) {
      _logger.print("onLike: $e");
      _crashlyticsController.recordError(e, stackTrace: s, reason: "onLikeScore");
    }
  }

  @override
  Future<void> onShare({
    String? communityId,
    String? postId,
  }) async {
    try {
      if (communityId != null) {
        await _batchUpdateScore(
          batchEngagement: BatchEngagement(
            score: scoringValues.shareScore,
            userRef: super.userRef,
            userActivity: super.userShared(scoringValues.shareScore),
            refs: [
              EngagementConsts.communityRef(communityId),
            ],
          ),
        );
      } else if (postId != null) {
        await _batchUpdateScore(
          batchEngagement: BatchEngagement(
            score: scoringValues.shareScore,
            userRef: super.userRef,
            userActivity: super.userShared(scoringValues.shareScore),
            refs: [
              EngagementConsts.postRef(postId),
            ],
          ),
        );
      }
    } catch (e, s) {
      _logger.print("onShare: $e");
      _crashlyticsController.recordError(e, stackTrace: s, reason: "onShareScore");
    }
  }

/////////////////////////////////////////////////////////////////////////
///////////////////// User Engagement Related ////////////////////////////
////////////////////////////////////////////////////////////////////////

  @override
  Future<void> onAcceptRequest({required String fromUserId}) async {
    try {
      _batchUpdateScore(
          batchEngagement: BatchEngagement(
        score: scoringValues.acceptRequestScore,
        userActivity: super.userAcceptRequested(scoringValues.acceptRequestScore),
        userRef: super.userRef,
      ));
    } catch (e, s) {
      _logger.print("onAcceptRequest: $e");
      _crashlyticsController.recordError(e, stackTrace: s, reason: "onAcceptRequestScore");
    }
  }

  @override
  Future<void> onRejectRequest({required String fromUserId}) async {
    try {
      await _batchUpdateScore(
        batchEngagement: BatchEngagement(
          score: scoringValues.rejectRequestScore,
          userRef: super.userRef,
          userActivity: super.userRejectRequested(scoringValues.rejectRequestScore),
        ),
      );
    } catch (e, s) {
      _logger.print("onRejectRequest: $e");
      _crashlyticsController.recordError(e, stackTrace: s, reason: "onRejectRequestScore");
    }
  }

  @override
  Future<void> onSendRequest({required String toUserId}) async {
    try {
      await _batchUpdateScore(
        batchEngagement: BatchEngagement(
          score: scoringValues.sendRequestScore,
          userRef: super.userRef,
          userActivity: super.userSendRequested(scoringValues.sendRequestScore),
        ),
      );
    } catch (e, s) {
      _logger.print("onSendRequest: $e");
      _crashlyticsController.recordError(e, stackTrace: s, reason: "onSendRequestScore");
    }
  }

  @override
  Future<void> onDirectMessage({required String toUserId}) async {
    try {
      _batchUpdateScore(
        batchEngagement: BatchEngagement(
          score: scoringValues.directMessageScore,
          userRef: super.userRef,
          userActivity: super.userDirectMessaged(scoringValues.directMessageScore),
        ),
      );
    } catch (e, s) {
      _logger.print("onDirectMessage: $e");
      _crashlyticsController.recordError(e, stackTrace: s, reason: "onDirectMessageScore");
    }
  }

  // -5 score incase of blocking user
  // @override
  // Future<void> onBlockUser({required String toUserId}) async {
  //   try {
  //     _batchUpdateScore(
  //       batchEngagement: BatchEngagement(
  //         score: scoringValues.blockUserScore,
  //         userRef: EngagementConsts.userActivityRef(toUserId),
  //         userActivity: super.userBlock(scoringValues.blockUserScore),
  //       ),
  //     );
  //   } catch (e, s) {
  //     _logger.print("onBlockUser: $e");
  //     _crashlyticsController.recordError(e, stackTrace: s, reason: "onBlockUser");
  //   }
  // }

  // -5 score incase of report user, user's post,comment or reply
  // @override
  // Future<void> onReportUser({required String toUserId}) async {
  //   try {
  //     _batchUpdateScore(
  //       batchEngagement: BatchEngagement(
  //         score: scoringValues.reportScore,
  //         userRef: EngagementConsts.userActivityRef(toUserId),
  //         userActivity: super.userReport(scoringValues.reportScore),
  //       ),
  //     );
  //   } catch (e, s) {
  //     _logger.print("onReportUser: $e");
  //     _crashlyticsController.recordError(e, stackTrace: s, reason: "onReportUser");
  //   }
  // }

  /// Single gateway to update score
  /// more on [BatchEngagement] class
  Future<void> _batchUpdateScore({required BatchEngagement batchEngagement}) async {
    final batch = FirebaseFirestore.instance.batch();

    /// Engagement entity update - post, community related
    for (var element in batchEngagement.refs) {
      batch.set(element, {EngagementConsts.scoreField: FieldValue.increment(batchEngagement.score)}, SetOptions(merge: true));
    }

    /// User entity update - userActivity
    batch.set(batchEngagement.userRef, batchEngagement.userActivity, SetOptions(merge: true));

    await batch.commit();
  }
}
