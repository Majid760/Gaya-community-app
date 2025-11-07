class UserCommunitiesModel {
  String? communityId;
  String? communityName;

  UserCommunitiesModel({
    this.communityId,
    this.communityName,
  });

  UserCommunitiesModel.fromMap(Map<String, dynamic> map) {
    communityId = map['communityId'];
    communityName = map['communityName'];
  }

  Map<String, dynamic> toMap() {
    return {
      'communityId': communityId,
      'communityName': communityName,
    };
  }
}
