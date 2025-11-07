class UserCommunities {
  String? communityName;
  String? communityId;
  bool? isPinned;
  bool? isHidden;
  bool? allowFingerprint;

  UserCommunities({this.communityName, this.communityId, this.isPinned = false, this.allowFingerprint = true, this.isHidden = false});

  UserCommunities.fromMap(Map<String, dynamic> map) {
    communityName = map['communityName'];
    communityId = map['communityId'];
    isPinned = map['isPinned'] ?? false;
    isHidden = map['isHidden'] ?? false;
    allowFingerprint = map['allowFingerprint'] ?? true;
  }

  Map<String, dynamic> toMap() {
    return {
      'communityName': communityName,
      'communityId': communityId,
      'isPinned': isPinned ?? false,
      'isHidden': isHidden ?? false,
      'allowFingerprint': allowFingerprint ?? true
    };
  }

  UserCommunities copyWith({
    bool? isPinned,
    bool? isHidden,
  }) {
    return UserCommunities(
      isPinned: isPinned ?? this.isPinned,
      isHidden: isHidden ?? this.isHidden,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserCommunities && other.communityId == communityId;
  }

  @override
  int get hashCode => communityId.hashCode;
}
