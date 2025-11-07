import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'engagement_consts.dart';
import 'engagement_utils.dart';

/// This class is used to get the user activity reference + the user activity {map}
abstract class ImplUserEngagementRef extends EngagementUtils {
  final userId = FirebaseAuth.instance.currentUser?.uid;

  DocumentReference get userRef => EngagementConsts.userActivityRef(userId!);

  /// creation
  Map<String, dynamic> userCreatePost(int score) => {EngagementConsts.createPostScoreField: FieldValue.increment(score)};

  /// Comments
  Map<String, dynamic> userCommented(int score) => {EngagementConsts.commentScoreField: FieldValue.increment(score)};
  Map<String, dynamic> userCommentedReply(int score) => {EngagementConsts.commentReplyScoreField: FieldValue.increment(score)};

  //// Crowns
  Map<String, dynamic> userPostCrowned(int score) => {EngagementConsts.postCrownScoreField: FieldValue.increment(score)};
  Map<String, dynamic> userCommentCrowned(int score) => {EngagementConsts.commentCrownScoreField: FieldValue.increment(score)};
  Map<String, dynamic> userCommentCrownedReply(int score) => {EngagementConsts.commentReplyCrownScoreField: FieldValue.increment(score)};

  /// Likes
  Map<String, dynamic> userPostLiked(int score) => {EngagementConsts.postLikeScoreField: FieldValue.increment(score)};
  Map<String, dynamic> userCommentLiked(int score) => {EngagementConsts.commentLikeScoreField: FieldValue.increment(score)};
  Map<String, dynamic> userCommentLikedReply(int score) => {EngagementConsts.commentReplyLikeScoreField: FieldValue.increment(score)};

  /// Dislikes
  Map<String, dynamic> userPostDisliked(int score) => {EngagementConsts.postDislikeScoreField: FieldValue.increment(score)};
  Map<String, dynamic> userCommentDisliked(int score) => {EngagementConsts.commentDislikeScoreField: FieldValue.increment(score)};
  Map<String, dynamic> userCommentDislikedReply(int score) => {EngagementConsts.commentReplyDislikeScoreField: FieldValue.increment(score)};

  /// Shares
  Map<String, dynamic> userShared(int score) => {EngagementConsts.shareScoreField: FieldValue.increment(score)};

  /// friendship
  Map<String, dynamic> userAcceptRequested(int score) => {EngagementConsts.acceptRequestScoreField: FieldValue.increment(score)};
  Map<String, dynamic> userRejectRequested(int score) => {EngagementConsts.rejectRequestScoreField: FieldValue.increment(score)};
  Map<String, dynamic> userSendRequested(int score) => {EngagementConsts.sendRequestScoreField: FieldValue.increment(score)};

  /// Direct Message
  Map<String, dynamic> userDirectMessaged(int score) => {EngagementConsts.directMessageScoreField: FieldValue.increment(score)};

  // Block user
  Map<String, dynamic> userBlock(int score) => {EngagementConsts.blockUserField: FieldValue.increment(score)};
  // Reprt on user, user's comment, post or reply
  Map<String, dynamic> userReport(int score) => {EngagementConsts.reportField: FieldValue.increment(score)};
}
