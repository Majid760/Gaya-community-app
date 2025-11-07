class LikePostModel {
  String? userUid;
  String ? likeDocID;

  LikePostModel({this.userUid , this.likeDocID});

  LikePostModel.fromMap(Map<String, dynamic> map) {
    userUid = map['userUid'];
    likeDocID  = map['likeDocID'];
  }

  Map<String, dynamic> toMap() {
    return {
      'userUid': userUid,
      'likeDocID' : likeDocID
    };
  }
}
