class FlowerReplyModel {
  String? userUid;
  String? flowerReplyId;

  FlowerReplyModel({this.userUid, this.flowerReplyId});

  FlowerReplyModel.fromMap(Map<String, dynamic> map) {
    userUid = map['userUid'];
    flowerReplyId = map['flowerDocId'];
  }

  Map<String, dynamic> toMap() {
    return {'userUid': userUid, 'flowerReplyId': flowerReplyId};
  }
}
