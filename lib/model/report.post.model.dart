class ReportModel {
  String? reporterUid;
  String? communityId;
  String? postId;
  String  ? reportId;

  ReportModel({this.reporterUid, this.communityId, this.postId , this.reportId});

  ReportModel.fromMap(Map<String, dynamic> map) {
    reporterUid = map['reporterUid'];
    communityId = map['communityId'];
    postId = map['postId'];
    reportId = map['reportId'];
  }

  Map<String, dynamic> toMap() {
    return {
      'reporterUid': reporterUid,
      'communityId': communityId,
      'postId': postId,
      'reportId' : reportId
    };
  }
}
