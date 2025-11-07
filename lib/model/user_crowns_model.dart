class UserCrownsModel {
  int? userTotalCrowns;
  int? userDailyCrowns;

  UserCrownsModel({this.userTotalCrowns, this.userDailyCrowns});

  // to copyWith mehto
  UserCrownsModel copyWith({
    int? userTotalCrowns,
    int? userDailyCrowns,
  }) {
    return UserCrownsModel(
        userTotalCrowns: userTotalCrowns ?? this.userTotalCrowns, userDailyCrowns: userDailyCrowns ?? this.userDailyCrowns);
  }

  UserCrownsModel.fromMap(Map<String, dynamic> map) {
    userTotalCrowns = map['userTotalCrowns'];
    userDailyCrowns = map['userDailyCrowns'];
  }

  Map<String, dynamic> toMap() {
    return {
      'userTotalCrowns': userTotalCrowns,
      'userDailyCrowns': userDailyCrowns,
    };
  }
}
