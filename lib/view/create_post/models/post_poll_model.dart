class PostPollModel {
  String userId;
  int pollOptionId;

  PostPollModel({
    required this.userId,
    required this.pollOptionId,
  });

  @override
  bool operator ==(other) {
    if (identical(this, other)) return true;
    return other is PostPollModel && userId == other.userId;
  }

  @override
  int get hashCode => userId.hashCode;

  factory PostPollModel.fromMap(Map<String, dynamic> map) {
    return PostPollModel(
      userId: map['userId'],
      pollOptionId: map['pollOptionId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'pollOptionId': pollOptionId,
    };
  }
}