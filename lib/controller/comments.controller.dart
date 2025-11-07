// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:gaya/app.dart';
// import 'package:gaya/model/flower..comment.model.dart';
// import 'package:gaya/model/like.comment.model.dart';
// import 'package:gaya/model/replies.model.dart';
// import 'package:gaya/model/reply.flower.model.dart';
// import 'package:gaya/model/reply.like.model.dart';
// import 'package:gaya/services/services.dart';
//
// import '../components/replies.model.dart';
// import '../model/comment.model.dart';
//
// class CommentsController extends ChangeNotifier {
//   Services services = Services();
//   final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
//
//   late List<Data> replyList;
//
//   bool isLikedFun(index) {
//     commentList[index].isLiked = !commentList[index].isLiked;
//     notifyListeners();
//     return commentList[index].isLiked;
//   }
//
//   bool isFloweredFun(index) {
//     commentList[index].isFlower = !commentList[index].isFlower;
//     notifyListeners();
//     return commentList[index].isFlower;
//   }
//
//
//
//
//
//
//
//
//   //set the comment like
//   Future commentLike(String postId, String commentId) async {
//     User? user = _firebaseAuth.currentUser;
//
//     LikeCommentModel likeCommentModel = LikeCommentModel(userUid: user!.uid, likeCommentId: uuid.v1());
//
//     return await FirebaseFirestore.instance
//         .collection('communityposts')
//         .doc(postId)
//         .collection('comments')
//         .doc(commentId)
//         .collection('likeOnComment')
//         .doc(likeCommentModel.likeCommentId)
//         .set(likeCommentModel.toMap());
//   }
//
//   //set the flower like
//   Future commentFlower(String postId, String commentId) async {
//     User? user = _firebaseAuth.currentUser;
//
//     FlowerCommentModel flowerCommentModel = FlowerCommentModel(userUid: user!.uid, flowerCommentId: uuid.v1());
//
//     return await FirebaseFirestore.instance
//         .collection('communityposts')
//         .doc(postId)
//         .collection('comments')
//         .doc(commentId)
//         .collection('flowerOnComment')
//         .doc(flowerCommentModel.flowerCommentId)
//         .set(flowerCommentModel.toMap());
//   }
//
//   //unlike the comment like
//   Future<QuerySnapshot?> unlikeComment(String postId, String commentDocId) async {
//     User? user = _firebaseAuth.currentUser;
//
//     return await FirebaseFirestore.instance
//         .collection('communityposts')
//         .doc(postId)
//         .collection('comments')
//         .doc(commentDocId)
//         .collection('likeOnComment')
//         .where('userUid', isEqualTo: user!.uid)
//         .get()
//         .then((value) {
//       value.docs.first.reference.delete();
//       return value;
//     });
//   }
//
//   //unlike the comment flower
//   Future unflowerComment(String postId, String commentDocId) async {
//     User? user = _firebaseAuth.currentUser;
//     return await FirebaseFirestore.instance
//         .collection('communityposts')
//         .doc(postId)
//         .collection('comments')
//         .doc(commentDocId)
//         .collection('flowerOnComment')
//         .where('userUid', isEqualTo: user!.uid)
//         .get()
//         .then((value) {
//       value.docs.first.reference.delete();
//       return value;
//     });
//   }
//
//   // ************* //
//
//   //check whether the current user like the post
//   Stream<QuerySnapshot?> checkReplyLike(String postId, String commentId, String replyDocId) async* {
//     User? user = _firebaseAuth.currentUser;
//
//     yield* FirebaseFirestore.instance
//         .collection('communityposts')
//         .doc(postId)
//         .collection('comments')
//         .doc(commentId)
//         .collection('replies')
//         .doc(replyDocId)
//         .collection('likeOnReply')
//         .where("userUid", isEqualTo: user!.uid)
//         .snapshots();
//   }
//
//   //check whether the current user flower the post
//   Stream<QuerySnapshot?> checkReplyFlower(String postId, String commentId, String replyDocId) async* {
//     User? user = _firebaseAuth.currentUser;
//
//     yield* FirebaseFirestore.instance
//         .collection('communityposts')
//         .doc(postId)
//         .collection('comments')
//         .doc(commentId)
//         .collection('replies')
//         .doc(replyDocId)
//         .collection('flowerOnReply')
//         .where("userUid", isEqualTo: user!.uid)
//         .snapshots();
//   }
//
//   // set the reply like
//   Future replyLike(String postId, String commentId, String replyDocId) async {
//     User? user = _firebaseAuth.currentUser;
//
//     LikeReplyModel likeReplyModel = LikeReplyModel(userUid: user!.uid, likeReplyId: uuid.v1());
//
//     return await FirebaseFirestore.instance
//         .collection('communityposts')
//         .doc(postId)
//         .collection('comments')
//         .doc(commentId)
//         .collection('replies')
//         .doc(replyDocId)
//         .collection('likeOnReply')
//         .doc(likeReplyModel.likeReplyId)
//         .set(likeReplyModel.toMap());
//   }
//
//   //set the flower like
//   Future replyFlower(String postId, String commentId, replyDocId) async {
//     User? user = _firebaseAuth.currentUser;
//
//     FlowerReplyModel flowerReplyModel = FlowerReplyModel(userUid: user!.uid, flowerReplyId: uuid.v1());
//
//     return await FirebaseFirestore.instance
//         .collection('communityposts')
//         .doc(postId)
//         .collection('comments')
//         .doc(commentId)
//         .collection('replies')
//         .doc(replyDocId)
//         .collection('flowerOnReply')
//         .doc(flowerReplyModel.flowerReplyId)
//         .set(flowerReplyModel.toMap());
//   }
//
//   //unlike the reply like
//   Future<QuerySnapshot?> unlikeReply(String postId, String commentDocId, String replyDocId) async {
//     User? user = _firebaseAuth.currentUser;
//
//     return await FirebaseFirestore.instance
//         .collection('communityposts')
//         .doc(postId)
//         .collection('comments')
//         .doc(commentDocId)
//         .collection('replies')
//         .doc(replyDocId)
//         .collection('likeOnReply')
//         .where('userUid', isEqualTo: user!.uid)
//         .get()
//         .then((value) {
//       value.docs.first.reference.delete();
//       return value;
//     });
//   }
//
//   //unlike the reply flower
//   Future unflowerReply(String postId, String commentDocId, String replyDocId) async {
//     User? user = _firebaseAuth.currentUser;
//     return await FirebaseFirestore.instance
//         .collection('communityposts')
//         .doc(postId)
//         .collection('comments')
//         .doc(commentDocId)
//         .collection('replies')
//         .doc(replyDocId)
//         .collection('flowerOnReply')
//         .where('userUid', isEqualTo: user!.uid)
//         .get()
//         .then((value) {
//       value.docs.first.reference.delete();
//       return value;
//     });
//   }
// }
