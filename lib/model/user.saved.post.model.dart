class UserSavedPostsModel {
  String? postId;
  String? communityId;
  String? userUid;

  UserSavedPostsModel({this.postId, this.communityId, this.userUid});

  UserSavedPostsModel.fromMap(Map<String, dynamic> map) {
    postId = map['postId'];
    communityId = map['communityId'];
    userUid = map['userUid'];
  }

  Map<String, dynamic> toMap() {
    return {'postId': postId, 'communityId': communityId, 'userUid': userUid};
  }
}
