import 'package:flutter/foundation.dart' show immutable;

import '../../../model/create.post.model.dart';
import 'insta_share.dart';

/// Date holder class for post insta share
@immutable
class PostInstaShare implements InstaShare {
  const PostInstaShare({
    this.communityName,
    this.communityImage,
    this.postPostedUserImage,
    this.postPostedUsername,
    this.postPostedUserReceivedCrowns,
    this.postDescription,
    this.postImage,
    this.post,
    this.isAnonymousPost,
  });

  final String? communityName;
  final String? communityImage;
  final String? postPostedUserImage;
  final String? postPostedUsername;
  final int? postPostedUserReceivedCrowns;
  final String? postDescription;
  final String? postImage;
  final Post? post;
  final bool? isAnonymousPost;
}
