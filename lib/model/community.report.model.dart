class CommunityReport {
  String? reporterUid;
  String? communityId;
  String? reportMsg;
  String? reportId;

  CommunityReport({this.reporterUid, this.communityId, this.reportId, this.reportMsg});

  CommunityReport.fromMap(Map<String, dynamic> map) {
    reporterUid = map['reporterUid'];
    communityId = map['communityId'];
    reportId = map['reportId'];
    reportMsg = map['reportMsg'];
  }

  Map<String, dynamic> toMap() {
    return {
      'reporterUid': reporterUid,
      'communityId': communityId,
      'reportId': reportId,
      'isReportHandled': false,
      'reportMsg': reportMsg,
      'createdAt': DateTime.now(),
    };
  }
}
