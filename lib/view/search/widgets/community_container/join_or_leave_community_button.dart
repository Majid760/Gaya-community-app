import 'package:flutter/material.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:get/get.dart';

import '../../../../utils/assets_icons.dart';
import '../../../../utils/const.dart';
import '../../../../utils/enum.dart';
import '../../../../utils/theme/app_colors.dart';
import '../../../../utils/theme/app_typography.dart';

class JoinOrLeaveCommunityButton extends StatelessWidget {
  const JoinOrLeaveCommunityButton({
    super.key,
    required this.communityJoiningStatus,
    required this.onJoinOrLeaveCommunityTap,
  });

  final VoidCallback onJoinOrLeaveCommunityTap;
  final CommunityJoiningStatus communityJoiningStatus;

  @override
  Widget build(BuildContext context) {
    /* -------------------------------------------------------------------------- */
    /*                 main elevated button [ElevatedButton.icon]                 */
    /* -------------------------------------------------------------------------- */
    return ElevatedButton.icon(
      style: TextButton.styleFrom(
        backgroundColor: backgroundColor,
        visualDensity: VisualDensity.compact,
      ),
      onPressed: onJoinOrLeaveCommunityTap,
      /* ------------------------------- button icon ------------------------------ */
      icon: icon,
      /* ------------------------------- button text ------------------------------ */
      label: Text(
        title,
        style: GayaTypography.subtitleMedium.copyWith(
          color: textColor,
        ),
      ),
    );
  }

  /// getter to get background color of button
  Color get backgroundColor {
    switch (communityJoiningStatus) {
      case CommunityJoiningStatus.joined:
        return kSecondaryLightColor;
      case CommunityJoiningStatus.waitingForApproval:
      case CommunityJoiningStatus.notJoined:
        return AppColors.primary;
    }
  }

  /// getter to get icon of the button
  Widget get icon {
    switch (communityJoiningStatus) {
      case CommunityJoiningStatus.joined:
        return SvgIconWidget.friendAdded;
      case CommunityJoiningStatus.waitingForApproval:
      case CommunityJoiningStatus.notJoined:
        return SvgIconWidget.addFriend;
    }
  }

  /// getter to get title of button
  String get title {
    switch (communityJoiningStatus) {
      case CommunityJoiningStatus.joined:
        return GayaStrings.joined.tr;
      case CommunityJoiningStatus.waitingForApproval:
        return GayaStrings.request_sent.tr;
      case CommunityJoiningStatus.notJoined:
        return GayaStrings.join.tr;
    }
  }

  /// getter to get text color of button
  Color get textColor {
    switch (communityJoiningStatus) {
      case CommunityJoiningStatus.joined:
        return AppColors.black;
      case CommunityJoiningStatus.waitingForApproval:
      case CommunityJoiningStatus.notJoined:
        return AppColors.white;
    }
  }
}
