class FlowerCommentModel {
  String? userUid;
  String? flowerCommentId;

  FlowerCommentModel({this.userUid, this.flowerCommentId});

  FlowerCommentModel.fromMap(Map<String, dynamic> map) {
    userUid = map['userUid'];
    flowerCommentId = map['flowerDocId'];
  }

  Map<String, dynamic> toMap() {
    return {'userUid': userUid, 'flowerCommentId': flowerCommentId};
  }
}
