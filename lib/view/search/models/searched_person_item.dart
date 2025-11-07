import 'package:flutter/foundation.dart' show immutable;

import '../../../utils/enum.dart';

/// data holder class for searched person item
@immutable
class SearchedPersonItem {
  const SearchedPersonItem({
    required this.username,
    required this.profileImage,
    required this.about,
    required this.friendshipStatus,
  });

  final String username;
  final String profileImage;
  final String about;
  final FriendshipStatus friendshipStatus;
}
