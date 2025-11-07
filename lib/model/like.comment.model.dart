class LikeCommentModel {
  String? userUid;
  String? likeCommentId;

  LikeCommentModel({this.userUid, this.likeCommentId});

  LikeCommentModel.fromMap(Map<String, dynamic> map) {
    userUid = map['userUid'];
    likeCommentId = map['flowerDocId'];
  }

  Map<String, dynamic> toMap() {
    return {'userUid': userUid, 'likeCommentId': likeCommentId};
  }
}
