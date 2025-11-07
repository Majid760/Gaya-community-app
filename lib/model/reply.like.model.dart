class LikeReplyModel {
  String? userUid;
  String? likeReplyId;

  LikeReplyModel({this.userUid, this.likeReplyId});

  LikeReplyModel.fromMap(Map<String, dynamic> map) {
    userUid = map['userUid'];
    likeReplyId = map['flowerDocId'];
  }

  Map<String, dynamic> toMap() {
    return {'userUid': userUid, 'likeReplyId': likeReplyId};
  }
}
