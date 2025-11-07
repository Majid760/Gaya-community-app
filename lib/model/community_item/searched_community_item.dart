import 'package:flutter/foundation.dart' show immutable;

import 'community_item.dart';

/// data holder class for searched community item
@immutable
class SearchedCommunityItem extends CommunityItem {
  const SearchedCommunityItem({
    required super.communityId,
    required super.communityCover,
    required super.communityDp,
    required super.communityName,
    required super.communityType,
    required super.communityBioContent,
    required super.communityJoiningStatus,
  });
}
