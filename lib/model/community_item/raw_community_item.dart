import 'package:flutter/foundation.dart' show immutable;

import 'community_item.dart';

@immutable
class RawCommunityItem extends CommunityItem {
  const RawCommunityItem({
    required super.communityId,
    required super.communityCover,
    required super.communityDp,
    required super.communityName,
    required super.communityType,
    required super.communityBioContent,
    required super.communityJoiningStatus,
  });
}
