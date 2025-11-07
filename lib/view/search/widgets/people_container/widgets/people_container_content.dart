import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../utils/theme/app_colors.dart';
import '../../../models/searched_person_item.dart';
import 'add_friend_or_request_sent_button.dart';
import 'user_about_info.dart';
import 'user_dp.dart';
import 'username.dart';

class PeopleContainerContent extends StatelessWidget {
  const PeopleContainerContent({
    super.key,
    required this.searchedPersonItem,
    required this.onPeopleContainerButtonTap,
    required this.showLoader,
  });

  final SearchedPersonItem searchedPersonItem;
  final VoidCallback onPeopleContainerButtonTap;
  final bool showLoader;

  @override
  Widget build(BuildContext context) {
    /* -------------------------------------------------------------------------- */
    /*                         main column widget [Column]                        */
    /* -------------------------------------------------------------------------- */
    return Column(
      children: [
        Row(
          crossAxisAlignment: searchedPersonItem.about.isEmpty ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: [
            /* --------------------------- user profile image --------------------------- */
            UserDp(profileImage: searchedPersonItem.profileImage),
            SizedBox(width: 12.0.w),
            Expanded(
              child: searchedPersonItem.about.isEmpty
                  ? Username(username: searchedPersonItem.username)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /* -------------------------------- username -------------------------------- */
                        Username(username: searchedPersonItem.username),
                        SizedBox(height: 4.0.h),
                        /* ---------------------------- user info / about --------------------------- */
                        UserAboutInfo(about: searchedPersonItem.about),
                      ],
                    ),
            ),
          ],
        ),
        SizedBox(height: 12.0.w),
        /* -------------------- add friend / request sent button -------------------- */
        showLoader
            ? SizedBox(
                width: 24.0.w,
                height: 24.0.w,
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              )
            : AddFriendOrRequestSentButton(
                onAddFriendOrRequestSentButtonTap: onPeopleContainerButtonTap,
                friendshipStatus: searchedPersonItem.friendshipStatus,
                showLoader: showLoader,
              ),
      ],
    );
  }
}
