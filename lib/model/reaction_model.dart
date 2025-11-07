class ReactionModel {
  String userId;
  String reaction;

  ReactionModel({
    required this.userId,
    required this.reaction,
  });

  @override
  bool operator ==(other) {
    if (identical(this, other)) return true;
    return other is ReactionModel && userId == other.userId;
  }

  @override
  int get hashCode => userId.hashCode;

  factory ReactionModel.fromMap(Map<String, dynamic> map) {
    return ReactionModel(
      userId: map['userId'],
      reaction: map['reaction'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'reaction': reaction,
    };
  }
}

class PostReactionDataModel {
  int like;
  int inLove;
  int sad;
  int angry;
  int surprized;
  int funny;

  PostReactionDataModel({this.like = 0, this.inLove = 0, this.sad = 0, this.angry = 0, this.surprized = 0, this.funny = 0});

  factory PostReactionDataModel.withLikes(int likes) =>
      PostReactionDataModel(like: likes, inLove: 0, sad: 0, angry: 0, surprized: 0, funny: 0);

  PostReactionDataModel copyWith({int? like, int? inLove, int? sad, int? angry, int? surprized, int? funny}) => PostReactionDataModel(
        like: like ?? this.like,
        inLove: inLove ?? this.inLove,
        sad: sad ?? this.sad,
        angry: angry ?? this.angry,
        surprized: surprized ?? this.surprized,
        funny: funny ?? this.funny,
      );

  int get totalReactions => like + inLove + sad + angry + surprized + funny;

  factory PostReactionDataModel.fromMap(Map<String, dynamic> map, {int? likedByCount}) {
    return PostReactionDataModel(
      like: ((map['like'] == null)
              ? 0
              : map['like'] == double.negativeInfinity
                  ? 0
                  : map['like']) +
          (likedByCount ?? 0),
      inLove: map['inLove'] ?? 0,
      sad: map['sad'] ?? 0,
      angry: map['angry'] ?? 0,
      surprized: map['surprized'] ?? 0,
      funny: map['funny'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'like': like,
      'inLove': inLove,
      'sad': sad,
      'angry': angry,
      'surprized': surprized,
      'funny': funny,
    };
  }

  bool get hasMixedReactions {
    final fields = [like, inLove, sad, angry, surprized, funny];

    return fields.where((value) => value > 0).length >= 2;
  }

  bool get isLikeOnly => !hasMixedReactions && like > 0;

  @override
  bool operator ==(other) {
    if (identical(this, other)) return true;
    return other is PostReactionDataModel && inLove == other.inLove;
  }

  @override
  int get hashCode => inLove.hashCode;
}
