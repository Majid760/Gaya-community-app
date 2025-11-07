import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../utils/assets_icons.dart';
import '../../../../../utils/const.dart';
import '../../../../../utils/enum.dart';
import '../../../../../utils/language/translation.dart';
import '../../../../../utils/textstyles.dart';
import '../../../../../utils/theme/app_colors.dart';

class AddFriendOrRequestSentButton extends StatelessWidget {
  const AddFriendOrRequestSentButton({
    super.key,
    required this.onAddFriendOrRequestSentButtonTap,
    required this.friendshipStatus,
    required this.showLoader,
  });

  final VoidCallback onAddFriendOrRequestSentButtonTap;
  final FriendshipStatus friendshipStatus;
  final bool showLoader;

  @override
  Widget build(BuildContext context) {
    /* -------------------------------------------------------------------------- */
    /*                      main sized box widget [SizedBox]                      */
    /* -------------------------------------------------------------------------- */
    return SizedBox(
      width: double.infinity,
      /* -------------------------- icon elevated button -------------------------- */
      child: ElevatedButton.icon(
        style: TextButton.styleFrom(
          backgroundColor: _getFriendshipButtonColor(),
          visualDensity: VisualDensity.compact,
        ),
        onPressed: onAddFriendOrRequestSentButtonTap,
        /* ------------------------------- button icon ------------------------------ */
        icon: _getButtonIcon(),
        /* ------------------------------- button text ------------------------------ */
        label: Text(
          _getFriendshipButtonTitle(),
          style: _getFriendshipButtonTextStyle(),
        ),
      ),
    );
  }

  /// Invoke to get button icon
  Widget _getButtonIcon() {
    switch (friendshipStatus) {
      case FriendshipStatus.addFriend:
        return SvgIconWidget.addFriend;
      case FriendshipStatus.unFriend:
        return SvgIconWidget.unFriendRequest;
      case FriendshipStatus.acceptRequest:
        return SvgIconWidget.requestSentWhite;
      case FriendshipStatus.requestSent:
        return SvgIconWidget.requestSentBlack;
    }
  }

  /// invoke to get button color
  Color _getFriendshipButtonColor() {
    switch (friendshipStatus) {
      case FriendshipStatus.addFriend:
        return kprimaryColor;
      case FriendshipStatus.unFriend:
        return kBaseGrey;
      case FriendshipStatus.acceptRequest:
        return kprimaryColor;
      case FriendshipStatus.requestSent:
        return AppColors.black5;
    }
  }

  /// invoke to get button text style
  TextStyle _getFriendshipButtonTextStyle() {
    switch (friendshipStatus) {
      case FriendshipStatus.addFriend:
        return CustomTypography.body4StyleWhite;
      case FriendshipStatus.unFriend:
        return CustomTypography.bodyStyle;
      case FriendshipStatus.acceptRequest:
        return CustomTypography.body4StyleWhite;
      case FriendshipStatus.requestSent:
        return CustomTypography.body4StyleBlack;
    }
  }

  /// invoke to get title of button
  String _getFriendshipButtonTitle() {
    switch (friendshipStatus) {
      case FriendshipStatus.addFriend:
        return GayaStrings.add_friend.tr;
      case FriendshipStatus.unFriend:
        return GayaStrings.unfriend.tr;
      case FriendshipStatus.acceptRequest:
        return GayaStrings.accept_request.tr;
      case FriendshipStatus.requestSent:
        return GayaStrings.request_sent.tr;
    }
  }
}
