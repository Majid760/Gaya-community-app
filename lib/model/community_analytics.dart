import 'dart:convert';

import 'package:flutter/foundation.dart' show immutable, listEquals;

import 'user.model.dart';

@immutable
class CommunityAnalytics {
  const CommunityAnalytics({
    required this.members,
    required this.likes,
    required this.likesComparisonPercentage,
    required this.posts,
    required this.postsComparisonPercentage,
    required this.crowns,
    required this.crownsComparisonPercentage,
    required this.views,
    required this.viewsComparisonPercentage,
    required this.comments,
    required this.commentsComparisonPercentage,
    required this.commonKeywords,
    required this.mostActiveUser,
  });

  /// members added to community according to selected timeline
  final int members;

  /// users likes to community posts/comments etc according to selected timeline
  final int likes;

  /// likes comparison from selected timeline (e.g. today as compare to yesterday etc)
  final double likesComparisonPercentage;

  /// new posts added to community according to selected timeline
  final int posts;

  /// posts comparison from selected timeline (e.g. today as compare to yesterday etc)
  final double postsComparisonPercentage;

  /// community got crowns on posts/comments etc according to selected timeline
  final int crowns;

  /// crowns comparison from selected timeline (e.g. today as compare to yesterday etc)
  final double crownsComparisonPercentage;

  /// numbers of views of community according to selected timeline
  final int views;

  /// views comparison from selected timeline (e.g. today as compare to yesterday etc)
  final double viewsComparisonPercentage;

  /// new comments added to community post etc according to selected timeline
  final int comments;

  /// comments comparison from selected timeline (e.g. today as compare to yesterday etc)
  final double commentsComparisonPercentage;

  /// common keyword circulation around community according to selected timeline
  final List<String> commonKeywords;

  /// most active user in a community according to selected timeline
  final UserModel? mostActiveUser;

  CommunityAnalytics copyWith({
    int? members,
    int? likes,
    double? likesComparisonPercentage,
    int? posts,
    double? postsComparisonPercentage,
    int? crowns,
    double? crownsComparisonPercentage,
    int? views,
    double? viewsComparisonPercentage,
    int? comments,
    double? commentsComparisonPercentage,
    List<String>? commonKeywords,
    UserModel? mostActiveUser,
  }) {
    return CommunityAnalytics(
      members: members ?? this.members,
      likes: likes ?? this.likes,
      likesComparisonPercentage:
          likesComparisonPercentage ?? this.likesComparisonPercentage,
      posts: posts ?? this.posts,
      postsComparisonPercentage:
          postsComparisonPercentage ?? this.postsComparisonPercentage,
      crowns: crowns ?? this.crowns,
      crownsComparisonPercentage:
          crownsComparisonPercentage ?? this.crownsComparisonPercentage,
      views: views ?? this.views,
      viewsComparisonPercentage:
          viewsComparisonPercentage ?? this.viewsComparisonPercentage,
      comments: comments ?? this.comments,
      commentsComparisonPercentage:
          commentsComparisonPercentage ?? this.commentsComparisonPercentage,
      commonKeywords: commonKeywords ?? this.commonKeywords,
      mostActiveUser: mostActiveUser ?? this.mostActiveUser,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'members': members,
      'likes': likes,
      'likesComparisonPercentage': likesComparisonPercentage,
      'posts': posts,
      'postsComparisonPercentage': postsComparisonPercentage,
      'crowns': crowns,
      'crownsComparisonPercentage': crownsComparisonPercentage,
      'views': views,
      'viewsComparisonPercentage': viewsComparisonPercentage,
      'comments': comments,
      'commentsComparisonPercentage': commentsComparisonPercentage,
      'commonKeywords': commonKeywords,
      'mostActiveUser': mostActiveUser?.toMap(),
    };
  }

  factory CommunityAnalytics.fromMap(Map<String, dynamic> map) {
    return CommunityAnalytics(
      members: map['members'] as int,
      likes: map['likes'] as int,
      likesComparisonPercentage: map['likesComparisonPercentage'] as double,
      posts: map['posts'] as int,
      postsComparisonPercentage: map['postsComparisonPercentage'] as double,
      crowns: map['crowns'] as int,
      crownsComparisonPercentage: map['crownsComparisonPercentage'] as double,
      views: map['views'] as int,
      viewsComparisonPercentage: map['viewsComparisonPercentage'] as double,
      comments: map['comments'] as int,
      commentsComparisonPercentage: map['commentsComparisonPercentage'] as double,
      commonKeywords: List<String>.from((map['commonKeywords'] as List<String>)),
      mostActiveUser: UserModel.fromMap(map['mostActiveUser'] as Map<String, dynamic>, userId: map['mostActiveUser']['docId'] as String),
    );
  }

  String toJson() => json.encode(toMap());

  factory CommunityAnalytics.fromJson(String source) =>
      CommunityAnalytics.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'CommunityAnalytics(members: $members, likes: $likes, likesComparisonPercentage: $likesComparisonPercentage, posts: $posts, postsComparisonPercentage: $postsComparisonPercentage, crowns: $crowns, crownsComparisonPercentage: $crownsComparisonPercentage, views: $views, viewsComparisonPercentage: $viewsComparisonPercentage, comments: $comments, commentsComparisonPercentage: $commentsComparisonPercentage, commonKeywords: $commonKeywords, mostActiveUser: $mostActiveUser)';
  }

  @override
  bool operator ==(covariant CommunityAnalytics other) {
    if (identical(this, other)) return true;

    return other.members == members &&
        other.likes == likes &&
        other.likesComparisonPercentage == likesComparisonPercentage &&
        other.posts == posts &&
        other.postsComparisonPercentage == postsComparisonPercentage &&
        other.crowns == crowns &&
        other.crownsComparisonPercentage == crownsComparisonPercentage &&
        other.views == views &&
        other.viewsComparisonPercentage == viewsComparisonPercentage &&
        other.comments == comments &&
        other.commentsComparisonPercentage == commentsComparisonPercentage &&
        listEquals(other.commonKeywords, commonKeywords) &&
        other.mostActiveUser == mostActiveUser;
  }

  @override
  int get hashCode {
    return members.hashCode ^
        likes.hashCode ^
        likesComparisonPercentage.hashCode ^
        posts.hashCode ^
        postsComparisonPercentage.hashCode ^
        crowns.hashCode ^
        crownsComparisonPercentage.hashCode ^
        views.hashCode ^
        viewsComparisonPercentage.hashCode ^
        comments.hashCode ^
        commentsComparisonPercentage.hashCode ^
        commonKeywords.hashCode ^
        mostActiveUser.hashCode;
  }
}
