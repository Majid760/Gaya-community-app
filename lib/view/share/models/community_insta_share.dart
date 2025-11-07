import 'package:flutter/foundation.dart' show immutable;

import '../../../model/community.model.dart';
import 'insta_share.dart';

/// Date holder class for community insta share
@immutable
class CommunityInstaShare implements InstaShare {
  const CommunityInstaShare({
    this.communityName,
    this.communityDp,
    this.communityCover,
    this.communityInfo,
    this.communityMembers,
    this.communityType,
    this.community,
  });

  final String? communityName;
  final String? communityDp;
  final String? communityCover;
  final String? communityType;
  final String? communityInfo;
  final int? communityMembers;
  final Community? community;
}
