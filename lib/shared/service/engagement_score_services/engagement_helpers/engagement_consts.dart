import 'package:cloud_firestore/cloud_firestore.dart';

class EngagementConsts {
  static const _usersC = "users";
  static const _userActivityC = "userActivities";
  static const _postsC = "communityposts";
  static const _communitiesC = "communities";

  /// score fields
  static const scoreField = "score";
  static const createPostScoreField = "createPostScore";

  static const commentScoreField = "commentScore";
  static const commentReplyScoreField = "commentReplyScore";

  static const postLikeScoreField = "likePostScore";
  static const commentLikeScoreField = "likeCommentScore";
  static const commentReplyLikeScoreField = "likeCommentReplyScore";

  static const postDislikeScoreField = "dislikeScore";
  static const commentDislikeScoreField = "dislikeCommentScore";
  static const commentReplyDislikeScoreField = "dislikeCommentReplyScore";

  static const postCrownScoreField = "PostCrownScore";
  static const commentCrownScoreField = "commentCrownScore";
  static const commentReplyCrownScoreField = "commentReplyCrownScore";

  static const shareScoreField = "shareScore";

  static const directMessageScoreField = "directMessageScore";
  static const sendRequestScoreField = "sendRequestScore";
  static const acceptRequestScoreField = "acceptRequestScore";
  static const rejectRequestScoreField = "rejectRequestScore";
  static const totalScoreField = "totalScore";

  static const blockUserField = "blockUserScore";
  static const reportField = "reportScore";
  static const deletePostField = "deletePostScore";

  /// Collection References

  /// User Entity
  static DocumentReference userRef(String userId) => FirebaseFirestore.instance.collection(_usersC).doc(userId);

  static DocumentReference userActivityRef(String userId) => FirebaseFirestore.instance.collection(_userActivityC).doc(userId);

  /// Posts Entity
  static DocumentReference postRef(String postId) => FirebaseFirestore.instance.collection(_postsC).doc(postId);

  static DocumentReference communityRef(String communityId) => FirebaseFirestore.instance.collection(_communitiesC).doc(communityId);

  static DocumentReference commentRef({required String postId, required String commentId}) =>
      FirebaseFirestore.instance.collection(_postsC).doc(postId).collection('comments').doc(commentId);
}
