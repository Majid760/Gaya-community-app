import 'package:flutter/foundation.dart' show immutable;

import '../../../utils/enum.dart';

/// data holder class for searched community item
@immutable
class SearchedCommunityItem {
  const SearchedCommunityItem({
    required this.communityId,
    required this.communityCover,
    required this.communityDp,
    required this.communityName,
    required this.communityType,
    required this.communityBioContent,
    required this.communityJoiningStatus,
  });

  final String communityId;
  final String communityCover;
  final String communityDp;
  final String communityName;
  final String communityType;
  final String communityBioContent;
  final CommunityJoiningStatus communityJoiningStatus;
}
