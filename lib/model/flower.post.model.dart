class FlowerPostModel {
  String? userUid;
  String ? flowerDocId;

  FlowerPostModel({this.userUid , this.flowerDocId});

  FlowerPostModel.fromMap(Map<String, dynamic> map) {
    userUid = map['userUid'];
    flowerDocId  = map['flowerDocId'];
  }

  Map<String, dynamic> toMap() {
    return {
      'userUid': userUid,
      'flowerDocId' : flowerDocId
    };
  }
}
