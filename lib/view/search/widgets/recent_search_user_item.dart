import 'package:flutter/material.dart';

import '../../../utils/assets_icons.dart';
import '../../../utils/textstyles.dart';

class RecentSearchUserItem extends StatelessWidget {
  const RecentSearchUserItem({
    super.key,
    required this.username,
    required this.profileImage,
    required this.onDeleteItemTap,
    required this.onRecentSearchItemTap,
  });

  final String username;
  final String profileImage;
  final VoidCallback onDeleteItemTap;
  final VoidCallback onRecentSearchItemTap;

  @override
  Widget build(BuildContext context) {
    /* -------------------------------------------------------------------------- */
    /*                      main list Tile widget [ListTile]                      */
    /* -------------------------------------------------------------------------- */
    return ListTile(
      dense: true,
      onTap: onRecentSearchItemTap,
      minLeadingWidth: 0.0,
      /* -------------------------------- user name ------------------------------- */
      title: Text(
        username,
        style: CustomTypography.body2EnableStyle1,
      ),
      /* ---------------------- delete user from search icon ---------------------- */
      trailing: IconButton(
        onPressed: onDeleteItemTap,
        icon: SvgIconWidget.delete,
      ),
    );
  }
}
