class SavePostModel {
  String? userUid;
  String ? saveDocID;

  SavePostModel({this.userUid , this.saveDocID});

  SavePostModel.fromMap(Map<String, dynamic> map) {
    userUid = map['userUid'];
    saveDocID  = map['saveDocID'];
  }

  Map<String, dynamic> toMap() {
    return {
      'userUid': userUid,
      'saveDocID' : saveDocID
    };
  }
}
