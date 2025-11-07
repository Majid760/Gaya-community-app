import 'package:flutter/foundation.dart' show immutable;

@immutable
class SearchedPostItem {
  const SearchedPostItem({
    required this.postId,
    required this.caption,
    required this.communityId,
    required this.postedBy,
  });

  final String postId;
  final String caption;
  final String communityId;
  final String postedBy;

  factory SearchedPostItem.fromAlgoliaMap(Map<String, dynamic> map) {
    return SearchedPostItem(
      postId: map['objectID'] as String,
      caption: map['caption'] as String,
      communityId: map['communityId'] as String,
      postedBy: map['postedBy'] as String,
    );
  }
}
